# Plan — Funnel Doctor

## Week 1: Set up and plan
- [X] Define funnel steps: Visit → View product → Add to cart → Start checkout → Pay
- [X] Write the one core question: "Why do users quit before paying, and what fix would help?"
- [X] Create GitHub repo with folders: data, sql, notebooks, docs
- [X] Write project-overview.md (this file's sibling)

## Week 2: Create the data
- [X] Generate ~100,000 users and events in Python (user ID, event, timestamp, device, city, source); event names: visit, view_product, add_to_cart, start_checkout, payment_success
- [X] Build in realistic patterns (mobile drops more at checkout, slow pages lose more users)
- [X] Add intentional mess: duplicate events, missing values, bot-like users
- [X] Load into PostgreSQL

## Week 3: Clean and find the leak
- [X] Write SQL/Python checks to find and remove duplicates and bots
- [X] Write SQL to count users per funnel step and drop-off %
- [X] Break down drop-off by device, city, source
- [X] Try a cohort query: do same-week signups return?

## Week 4: A/B test
- [X] Add experiment flag: old checkout vs. new checkout
- [X] Run significance test in SciPy comparing payment rates
- [X] Report result with confidence interval in plain language
- [X] Check for issues (uneven group sizes, novelty effects)

## Week 5: Dashboard and portfolio
- [ ] Build Power BI/Tableau dashboard: funnel, drop-off by segment, test result, recommendation
- [ ] Write README: problem, data generation method, findings, limitations
- [ ] Practice 10-minute walkthrough
- [ ] Write 3 resume bullets using only real project numbers

## Backlog / stretch goals
- [ ] Automated data-quality report
- [ ] Scheduled pipeline (simple script or Airflow)
