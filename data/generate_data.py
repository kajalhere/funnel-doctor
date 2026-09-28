"""
Funnel Doctor - synthetic data generator (Parts 1-2: users and events)

Funnel: visit -> view_product -> add_to_cart -> start_checkout -> payment_success
Part 1 creates the users. Part 2 creates the events (how far each user gets in the funnel).
Later parts will add experiment groups and intentional mess.
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


if __name__ == "__main__":
    users = generate_users()
    events = generate_events(users)

    print(events.head(8))
    print("\nUsers:", len(users), "| Events:", len(events))

    # quick sanity check: users per funnel step and drop-off
    counts = events.groupby("event")["user_id"].nunique().reindex(FUNNEL)
    summary = pd.DataFrame({"users": counts,
                            "drop_off_%": (100 * (1 - counts / counts.shift(1))).round(1)})
    print("\nFunnel:\n", summary)