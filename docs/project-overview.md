# Project Overview — Funnel Doctor

## One-line goal
Diagnose where users drop off in a product funnel, find why, test a fix with an A/B test, and recommend an action backed by data.

## Business problem
A company (simulated: an online shopping app/website) wants to know why users visit but don't complete a purchase. The funnel:

Visit → View product → Add to cart → Start checkout → Pay

Event names: `visit`, `view_product`, `add_to_cart`, `start_checkout`, `payment_success`

At each step, some users quit. The project finds where the biggest drop-off is, what's driving it, and whether a proposed fix (a redesigned checkout) actually improves payment rates.

## Why this project (not a typical dashboard)
- Uses raw event-level data, not a pre-aggregated summary table.
- Requires cleaning real-world messiness: duplicate events, bot-like users, missing values.
- Includes an actual A/B test with a significance check, not just a bar chart comparison.
- Ends in a costed recommendation, not just a chart.

## Scope
- **In scope:** funnel analysis, segment breakdown (device/city/source), data-quality cleaning, one A/B test, one dashboard.
- **Out of scope (v1):** real-time pipelines, machine learning models, cloud deployment.

## Data
- Synthetic event data generated in Python (~100,000 users), designed to mimic real messiness (duplicates, bots, missing values) and a real drop-off pattern by device and page speed.
- Rationale for synthetic data documented in `decisions.md`.

## Tech stack
| Tool | Purpose |
|---|---|
| Python (Pandas, NumPy) | Generate and clean event data |
| PostgreSQL | Store events, run funnel/cohort SQL |
| SciPy / Statsmodels | A/B test significance testing |
| Power BI / Tableau | Dashboard |
| Jupyter Notebook | Analysis documentation |
| GitHub | Portfolio hosting |

## Background context
- Existing resume project: Air Quality Sensors Reliability Analysis (sensor-level reliability scoring, Python + PostgreSQL). Funnel Doctor is meant to complement it by adding business-metrics and experimentation skills rather than repeating station/sensor-style analysis.

## Status
The analysis, A/B test and dashboard are complete. Remaining: walkthrough practice and resume bullets.