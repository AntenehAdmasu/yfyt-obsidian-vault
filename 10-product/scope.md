# Scope

## Current phase: Phase 1 — Foundation

Building the real backend: Supabase, Claude Opus 4.6 API, live market data, paper trading with risk engine. UI is already built (mocked) from April 14-17.

## In scope (Phase 1)

- Supabase schema + auth (magic link) — replacing localStorage
- Real signal generation via Claude Opus 4.6 API
- Real market data via Alpaca Markets (preferred) or Alpha Vantage (fallback)
- Risk engine: min 1:2 R:R, max 10% position size, max 2% portfolio risk per trade
- Trade execution with live prices
- Streaming chat follow-ups about signals
- Portfolio P&L with live prices
- End-to-end test: 10 full cycles with zero manual intervention

## Four-phase roadmap

| Phase | What | Weeks @ 15h/wk | Gate |
|---|---|---|---|
| Phase 1 | Foundation — real Opus signals, market data, Supabase, paper sim, risk engine | ~3 | Run signal → take trade → see outcome tracked. 10 times, zero manual intervention |
| Phase 2 | Context & Intelligence — screener, multi-TF, news, Reddit, FinBERT, RAG | ~4 | Signal reasoning references specific news, sentiment, and methodology |
| Phase 3 | Autonomous Agent — WhatsApp alerts on Railway, two-way Claude dialogue | ~3 | WhatsApp alert arrives when away from laptop, reply with question, Claude answers |
| Phase 4 | Learning System — backtester, journal, behaviour pattern detection | ~3 | Wingman surfaces a behavioural pattern about your trading that you didn't know — and is right |

## Out of scope (hard NOs)

- Real money / brokerage connection — not until 3+ months of consistent paper profit
- FCA authorisation — deferred until public launch consideration
- Mobile native app — web-first
- Social features, leaderboards, copy trading
- Crypto or options/derivatives
- Payment/subscription system
- Custom charting library — using lightweight-charts v5

## Constraints

- **Regulatory:** UK FCA rules mean any personalised financial advice requires authorisation. All signals must carry "not financial advice" disclaimers. Paper trading only.
- **Budget:** ~£10-20/month for personal use (Claude API + hosting)
- **Time:** 15h/week (5h weekdays + 10h weekends). ~13 weeks to Phase 4 complete.
- **Build method:** Claude Code (VS Code) with Claude Opus 4.6. Anti/Elsh direct AI agents — minimal direct coding.

## Dependencies

- Alpaca Markets account (signup currently blocked — email domain issue)
- Anthropic API credits ($24/month Build tier)
- Supabase project (created: `fbddjonlgqkcznamgztw`)

---

*Ground rule: finish each phase before the next. No "80% done" skipping. Out-of-scope ideas → [[parking-lot]].*
