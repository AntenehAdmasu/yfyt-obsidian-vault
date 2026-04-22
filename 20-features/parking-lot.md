# Parking Lot

Ideas and temptations that arise mid-phase but do not belong to the current phase. Write them here the moment they appear. Return to them only after Phase 4 gate passes.

---

## Public launch (Phase 5+)

- FCA authorisation / appointed representative arrangement
- Legal review of disclaimers and financial promotion compliance
- Onboarding flow for non-technical users
- Stripe payment integration + subscription tier gating
- Marketing site, landing page, pricing page

## Scale concerns (deferred until real user demand exists)

- Horizontal scaling, load balancing, multi-tenancy performance
- Admin dashboards, user analytics
- Live broker integration (Alpaca OAuth, IBKR)
- Mobile native app (iOS / Android)
- Social features, copy trading, leaderboards

## Interesting-but-not-now ideas

- **Ticker knowledge base** — persistent per-ticker notes in DB. Short dated entries ("AAPL: product launch May 2026", "AMZN: antitrust suit ongoing"). Auto-expire stale entries. Feed into signal prompts so Claude knows what's happening beyond price action. Living memory per ticker that builds over time.

- **Weekly pool re-evaluation** — auto-review the base ticker universe (~50 stocks) weekly. Detect stale tickers (no setups for 2+ weeks) and trending mid-caps gaining momentum. Suggest swaps to keep the universe fresh without manual curation.

---

*Ground rule: out-of-scope ideas go here, not into the sprint. See [[scope]] for what's in/out.*
