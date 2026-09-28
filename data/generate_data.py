"""
Funnel Doctor - synthetic data generator (Parts 1-3: users, events and intentional mess)

Funnel: visit -> view_product -> add_to_cart -> start_checkout -> payment_success
Part 1 creates the users. Part 2 creates the events (how far each user gets in the funnel).
Part 3 adds intentional mess (bots, duplicate events, missing values).
Later parts will add the A/B test groups.
"""

import numpy as np
import pandas as pd

SEED = 42            # same seed = same data every run (repeatable)
N_USERS = 100_000

rng = np.random.default_rng(SEED)


def generate_users(n=N_USERS):
    """One row per user with the attributes we will break the funnel down by."""
    users = pd.DataFrame({"user_id": np.arange(1, n + 1)})

    users["device"] = rng.choice(
        ["mobile", "desktop", "tablet"], size=n, p=[0.65, 0.30, 0.05]
    )
    users["city"] = rng.choice(
        ["Mumbai", "Delhi", "Bengaluru", "Hyderabad", "Pune", "Indore", "Bhopal", "Jaipur"],
        size=n,
        p=[0.18, 0.18, 0.16, 0.12, 0.10, 0.09, 0.09, 0.08],
    )
    users["source"] = rng.choice(
        ["organic_search", "paid_ads", "social", "email", "direct"],
        size=n,
        p=[0.30, 0.25, 0.20, 0.10, 0.15],
    )
    # 30% of users get a slow page (used later: slow pages lose more users)
    users["page_speed"] = rng.choice(["fast", "slow"], size=n, p=[0.70, 0.30])

    # first visit spread over 60 days
    start = pd.Timestamp("2026-07-01")
    users["first_visit"] = start + pd.to_timedelta(
        rng.integers(0, 60 * 24 * 60, size=n), unit="m"
    )
    return users


# ---------- Part 2: events ----------
FUNNEL = ["visit", "view_product", "add_to_cart", "start_checkout", "payment_success"]

# Chance a user moves on to this step, given they reached the step before it.
# The big gap is at checkout: mobile users quit much more often than desktop users.
STEP_PROB = {
    "view_product":    {"desktop": 0.60, "mobile": 0.55, "tablet": 0.55},
    "add_to_cart":     {"desktop": 0.30, "mobile": 0.25, "tablet": 0.27},
    "start_checkout":  {"desktop": 0.50, "mobile": 0.45, "tablet": 0.47},
    "payment_success": {"desktop": 0.70, "mobile": 0.45, "tablet": 0.50},
}
# Slow pages reduce the chance of moving on (checkout is hit hardest).
SLOW_PAGE_FACTOR = {"view_product": 0.85, "add_to_cart": 0.85,
                    "start_checkout": 0.85, "payment_success": 0.80}


def generate_events(users):
    """One row per event. A user only reaches a step if they passed all steps before it."""
    n = len(users)
    alive = np.ones(n, dtype=bool)               # everyone starts with a visit
    last_time = users["first_visit"].copy()
    frames = [pd.DataFrame({"user_id": users["user_id"], "event": "visit",
                            "timestamp": users["first_visit"]})]

    for step in FUNNEL[1:]:
        p = users["device"].map(STEP_PROB[step]).to_numpy()
        p = np.where(users["page_speed"] == "slow", p * SLOW_PAGE_FACTOR[step], p)
        alive = alive & (rng.random(n) < p)      # drop out here with probability 1 - p

        # each step happens 1-30 minutes after the previous one
        last_time = last_time + pd.to_timedelta(rng.integers(1, 31, size=n), unit="m")
        frames.append(pd.DataFrame({"user_id": users.loc[alive, "user_id"],
                                    "event": step,
                                    "timestamp": last_time[alive]}))

    events = pd.concat(frames, ignore_index=True)
    return events.sort_values(["user_id", "timestamp"]).reset_index(drop=True)


# ---------- Part 3: intentional mess ----------
N_BOTS = 2_000          # extra bot-like users (about 2% on top of real users)
DUPLICATE_RATE = 0.03   # share of event rows that get copied (double-fired events)
MISSING_RATE = 0.04     # share of users with a missing city or device


def add_bots(users, events):
    """Bots: many events, seconds apart, they browse but never pay."""
    bot_ids = np.arange(N_USERS + 1, N_USERS + N_BOTS + 1)
    bot_users = pd.DataFrame({
        "user_id": bot_ids,
        "device": rng.choice(["desktop", "mobile"], size=N_BOTS, p=[0.8, 0.2]),
        "city": rng.choice(users["city"].unique(), size=N_BOTS),
        "source": rng.choice(["direct", "paid_ads"], size=N_BOTS, p=[0.6, 0.4]),
        "page_speed": "fast",
        "first_visit": pd.Timestamp("2026-07-01")
        + pd.to_timedelta(rng.integers(0, 60 * 24 * 60, size=N_BOTS), unit="m"),
    })

    n_events = rng.integers(20, 61, size=N_BOTS)             # 20-60 events per bot
    ids = np.repeat(bot_ids, n_events)
    gaps = rng.integers(1, 6, size=len(ids))                 # 1-5 seconds apart
    bot_events = pd.DataFrame({"user_id": ids, "gap": gaps})
    bot_events["timestamp"] = bot_events["user_id"].map(
        bot_users.set_index("user_id")["first_visit"]
    ) + pd.to_timedelta(bot_events.groupby("user_id")["gap"].cumsum(), unit="s")
    bot_events["event"] = rng.choice(["visit", "view_product"], size=len(ids))
    bot_events = bot_events[["user_id", "event", "timestamp"]]

    return (pd.concat([users, bot_users], ignore_index=True),
            pd.concat([events, bot_events], ignore_index=True),
            bot_ids)


def add_duplicates(events):
    """Some events are recorded twice (same user, event and timestamp)."""
    dupes = events.sample(frac=DUPLICATE_RATE, random_state=SEED)
    events = pd.concat([events, dupes], ignore_index=True)
    return events.sort_values(["user_id", "timestamp"]).reset_index(drop=True)


def add_missing_values(users):
    """Blank out some cities and devices, like tracking that failed to capture them."""
    users = users.copy()
    users.loc[rng.random(len(users)) < MISSING_RATE, "city"] = np.nan
    users.loc[rng.random(len(users)) < MISSING_RATE, "device"] = np.nan
    return users


if __name__ == "__main__":
    users = generate_users()
    events = generate_events(users)

    # add the mess
    users, events, bot_ids = add_bots(users, events)
    events = add_duplicates(events)
    users = add_missing_values(users)

    # save raw data (the messy version an analyst would receive)
    users.to_csv("data/users.csv", index=False)
    events.to_csv("data/events.csv", index=False)
    # answer key: kept separately so you can check your cleaning later
    pd.DataFrame({"user_id": bot_ids}).to_csv("data/answer_key_bots.csv", index=False)

    print("Users:", len(users), "| Events:", len(events))
    print("Duplicate rows:", events.duplicated().sum())
    print("Missing city:", users["city"].isna().sum(), "| Missing device:", users["device"].isna().sum())
    print("Bot users:", len(bot_ids))