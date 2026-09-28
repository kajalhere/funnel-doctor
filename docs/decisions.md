# Decisions — Funnel Doctor

Record of key choices and the reasoning behind them.

---

### Decision: Use fully synthetic event data (not Kaggle or Maven Analytics)
**Date:** 2026-09-27
**Options considered:**
1. Kaggle "eCommerce behavior data from multi-category store" — real, messy, but no built-in A/B test.
2. Maven Analytics dataset — clean and well-documented, but lacks realistic messiness and event-level granularity for this use case.
3. Fully synthetic data generated in Python.

**Decision:** Option 3 — fully synthetic data.
**Reasoning:** Full control over both the messiness (duplicates, bots, missing values) and the A/B test outcome, which no public dataset provides together. Avoids dataset-hunting delays. Requires documenting the generation logic clearly so the project's realism is defensible in interviews.

---

### Decision: Funnel Doctor as the next project (not StationPulse)
**Date:** 2026-09-27 (from planning discussion)
**Reasoning:** Existing resume project (Air Quality Sensors Reliability Analysis) is already station/sensor-level, using Python and PostgreSQL. Funnel Doctor adds distinct skills — A/B testing, business/product metrics, funnel SQL — rather than repeating a similar project shape.

---

### Decision: Shopping app/website as the simulated business (not a food-ordering app)
**Date:** 2026-09-28
**Decision:** The simulated company is an online shopping app/website. Funnel: Visit → View product → Add to cart → Start checkout → Pay.
**Reasoning:** Shopping/e-commerce funnels are a more common and widely recognised case in data analyst roles, so the project is easier to explain in interviews. The plan, data design and A/B test stay the same; only names and wording change.
