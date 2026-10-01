# Work Log — Funnel Doctor

Newest entries at top. One entry per work session.

---

### 2026-10-01
- Created notebooks 01_ab_test_setup and 02_ab_test_analysis. Randomly split 100,000 users into old/new checkout (50,089 new, 49,911 old) and saved results to `experiment_results` in PostgreSQL.
- Overall test (users who started checkout): new 56.0% vs old 51.7%, lift 4.3 points, 95% CI 1.8 to 6.8, p = 0.0008, so the result is significant.
- By device: mobile +5.1 points (p = 0.003, significant); desktop +2.6 (p = 0.19), tablet and unknown not significant (small groups).
- Limitations: synthetic data with a built-in effect, smaller groups within each device, novelty effects could not be measured.
- Completed all Week 4 tasks in plan.md.
- **Next:** Week 5, the dashboard (funnel, drop-off by segment, test result, recommendation).

### 2026-09-30
- Cleaned the data: removed 7,720 duplicate events and 2,000 bots (rule: more than 10 events per user) using SQL views. Clean data has 100,000 users.
- Built the funnel: 100,000 visits → 3,181 payments (3.2% overall). Biggest drop is view_product → add_to_cart (74.6% lost); 48.5% of users who start checkout don't pay.
- Segment breakdown: mobile checkout → pay is 42.5% vs 65.7% on desktop; slow pages convert at 1.8% vs 3.8% on fast pages; both effects hold when checked together. Source and city show no meaningful difference (about 3.1–3.5%).
- Cohort analysis: only 842 users (0.8%) return on another day; weekly conversion is stable at 2.9–3.3%.
- Completed all Week 3 tasks in plan.md.
- **Next:** Week 4 — design the A/B test (experiment flag: old vs. new checkout).

### 2026-09-29
- Generated 100,000 users plus 2,000 bots with duplicate events and missing values, and loaded everything into PostgreSQL.
- Ran raw-data checks in PostgreSQL (before cleaning):
  - 265,061 events from 102,000 users (100,000 real + 2,000 bots)
  - Events table: 0 missing values
  - Users table: 4,028 missing device, 4,059 missing city (about 4% each); source and page_speed complete
  - 7,720 exact duplicate event rows (same user, event and timestamp)
- Plan: remove duplicates with a view (`events_dedup`), label missing device/city as "Unknown" (`users_clean`), then detect bots.
- **Next:** Find the bot rule (events per user), then build the funnel counts.

### 2026-09-28
- Changed project topic from a food-ordering app to an online shopping app/website (funnel: Visit → View product → Add to cart → Start checkout → Pay).
- Updated plan.md, project-overview.md and learning-notes.md to match; logged the decision in decisions.md.
- **Next:** Create GitHub repo (folders: data, sql, notebooks, docs) and finish Week 1 tasks.
- "Created the funnel-doctor repo in VS Code and pushed it to GitHub."

### 2026-09-27
- Decided on project scope: funnel diagnosis + A/B test on synthetic event data.
- Decided against Kaggle/Maven datasets in favor of fully synthetic data, for full control over messiness and the experiment.
- Set up documentation structure (this file and its siblings).
- **Next:** Start Week 1 tasks — define funnel steps formally and create GitHub repo.
