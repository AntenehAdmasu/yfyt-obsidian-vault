# Pitfalls

## Known risks

### Regulatory
- UK FCA: personalised financial advice requires authorisation. Wingman must never say "I think you should buy X." Educational + paper trading only.
- All signals must carry disclaimers: "Paper trade only. Educational. Not financial advice."
- If we ever move to real money or public launch, need FCA authorisation or appointed representative arrangement.

### Behavioural
- **Overtrading** — generating too many signals and trading impulsively. Mitigated by: max 5 trades/day in risk engine.
- **Revenge trading** — trading to recover losses after a bad trade. Phase 4 journal system should detect this pattern.
- **Ignoring stop losses** — paper trading makes it easy to pretend losses didn't happen. All trades are immutable in the database.
- **Confirmation bias** — only asking Wingman about stocks we already want to buy. Phase 2 screener will push tickers we didn't pick.

### Technical
- **Alpha Vantage rate limits** — free tier is 25 requests/day. Not viable for monitoring. Need Alpaca (free WebSocket streaming) or Alpha Vantage premium ($50/mo).
- **Claude API costs** — at aggressive usage (~30 calls/day), ~$1.75/day. The $24/mo Build plan may not cover heavy usage. Monitor.
- **Hallucinated price levels** — Claude might invent support/resistance levels. Mitigated by: Zod schema validation + risk engine checks.

### Scope creep
- Anti's self-identified weakness: "I don't trust myself in patiently building one by one. I get excited and jump here and there."
- Mitigated by: 4-phase roadmap with decision gates, `parking-lot.md` for out-of-scope ideas, ground rules.

## Past mistakes to avoid

- Don't build features before the foundation is solid (DB, auth, real data)
- Don't skip paper trading validation — 3 months minimum before considering real money
- Don't default to Sonnet for cost savings — Opus 4.6 quality is worth the premium for signal generation

## Open watchlist

- Alpaca signup blocked — if unresolved, need alternative (Polygon.io, Finnhub, or Alpha Vantage premium)
- Anthropic $24/mo plan usage — monitor if it's enough or needs top-up
- R:R quality of Claude signals — the test run returned 1:1 which is bad. System prompt needs enforcement of 1:2 minimum

---

*Pair with [[scope]] — pitfalls often clarify hard NOs.*
