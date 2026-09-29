# Work Log — Funnel Doctor

Newest entries at top. One entry per work session.

---
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
