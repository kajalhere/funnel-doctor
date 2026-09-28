"""
Funnel Doctor - synthetic data generator (Part 1: users)

Funnel: visit -> view_product -> add_to_cart -> start_checkout -> payment_success
Part 1 creates the users. Later parts will add events, experiment groups and intentional mess.
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


if __name__ == "__main__":
    users = generate_users()
    print(users.head())
    print("\nRows:", len(users))
    print("\nDevice share:\n", users["device"].value_counts(normalize=True).round(3))
