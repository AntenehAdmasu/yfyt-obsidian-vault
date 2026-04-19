# Signal Strategy

**Status:** Approved design — implementation in progress  
**Date:** April 20, 2026  
**Budget:** ~$4/day (~$80/month)  
**Canonical source:** `docs/signal-strategy.md` in the code repo

---

## Overview

Two-pass morning screener → 10 shortlisted tickers → 15-min code monitoring → Claude deep signal on entry zone triggers → trade execution → auto-stop when limits hit.

---

## Morning Routine (1x daily, before market open)

### Pass 1 — Code Filters (no AI, free)

75 tickers → fetch overnight data (Alpaca WebSocket or Alpha Vantage) → filter:

- Volume > 1.5x 20-day average
- Gap up/down > 1%
- RSI(14) < 30 or > 70
- Price within 1% of SMA 20 or SMA 50
- New 20-day high or low

Result: ~20-25 candidates pass.

### Pass 2 — Claude Ranks (1 call, ~$0.25)

Send all 25 candidates to Claude in one call with:
- Each ticker's key stats (price, volume ratio, RSI, gap %)
- Week's news headlines per ticker
- SPY/QQQ/VIX context
- User's current positions (avoid overlap)

Instruction: *"Rank top 10 by setup quality. Flag any that look like traps (earnings proximity, news-driven spikes, low-conviction breakouts). For each, give an entry zone to watch and a 1-sentence thesis."*

Result: 10 tickers for the day, each with an entry zone and thesis.

---

## Deep Signal Analysis (on demand)

Triggered when:
- User manually requests a signal on a ticker
- Monitoring detects price entering an entry zone Claude flagged

### Enriched Prompt — 6,600 tokens (~3.3% of 200K context)

| Layer | What | Tokens |
|---|---|---|
| **1. System prompt** | Wingman identity, swing trading methodology, risk rules, output schema | ~400 |
| **2. Market data** | 100 OHLCV candles, RSI(14) trend, SMA 20/50, MACD, Bollinger Bands, ATR, volume vs average | ~1,800 |
| **3. Market context** | SPY + QQQ + VIX current data (20 candles each), sector ETF, earnings proximity, 5 recent news headlines | ~1,300 |
| **4. User context** | Portfolio value, cash balance, open positions, today's trades so far, risk budget remaining | ~600 |
| **5. Knowledge base** | Past signals on this ticker, trading journal patterns, methodology docs (Phase 2 — RAG) | ~500 |

Cost per signal: ~$0.14 (3,000 input + 800 output at Opus pricing).

### Output

Zod-validated JSON: action, confidence, entry, SL, TP, R:R, position size, summary, 3-4 reasoning points, 2-3 concepts explained.

If R:R < 2 on first attempt → auto-retry with correction prompt.

---

## Monitoring Loop (every 15 min, code only)

Check prices for the 10 shortlisted tickers. No Claude calls unless something triggers.

```
Every 15 min:
  1. Are we still allowed to trade?
     - Under 5 trades today?
     - Under 2% daily loss (£200)?
     - Market still open?
     - Any tickers left to watch?

     → If NO to any → stop monitoring, run end-of-day review.

  2. For each active ticker:
     - Has price entered the entry zone Claude flagged?
     - Has price hit SL or TP on an open position?

     → Entry zone hit → trigger fresh deep signal for confirmation
     → SL/TP hit → log outcome, remove from monitoring
```

### Stop conditions

| Trigger | Action |
|---|---|
| 5 trades executed today | Stop monitoring. Day is done. |
| 2% daily loss hit (£200 from £10K) | **Kill switch** — stop everything. |
| All 10 tickers traded or invalidated | Stop monitoring. |
| A ticker hits SL or TP | Remove from watchlist, log outcome. |
| Market closes (4pm ET) | Stop monitoring. Run end-of-day summary. |

Most days, monitoring naturally winds down by midday after 2-3 trades.

---

## Risk Rules (enforced on every signal)

| Rule | Value |
|---|---|
| Min risk:reward | 1:2 |
| Max position size | 10% of portfolio |
| Max portfolio risk per trade | 2% of total value |
| Stop loss | Mandatory — no exceptions |
| No same-ticker stacking | 1 open position per ticker |
| Max daily trades | 5 |
| Max daily loss | 2% of portfolio (kill switch) |

See also: [[risk-engine]]

---

## Daily Cost Breakdown

| Component | Count/day | Cost each | Daily total |
|---|---|---|---|
| Morning screener (Claude, 75 tickers) | 1-2 calls | $0.25 | $0.40 |
| Deep signals (enriched, 6.6K tokens) | 10 | $0.14 | $1.40 |
| Entry confirmations | 4 | $0.09 | $0.36 |
| Chat follow-ups | 15 | $0.06 | $0.90 |
| Post-trade reviews | 3 | $0.08 | $0.24 |
| End-of-day summary | 1 | $0.12 | $0.12 |
| Market data (Alpaca) | Unlimited | Free | $0 |
| **Total** | | | **~$3.40-4.00** |

**Monthly: ~$80. Annual: ~$960.**

---

## Context Window Usage

Claude Opus 4.6 has a 200K token context window. Even at the enriched 6,600-token prompt, we use 3.3% of capacity. There is massive headroom to add more context without approaching limits.

---

## What's Built vs What's Left

| Component | Status |
|---|---|
| Signal API route (`/api/wingman/signal`) | Built — working with real data |
| Chat API route (`/api/wingman/chat`) | Built — streaming |
| Risk engine (Zod + hard rules) | Built |
| Market data service (Alpha Vantage) | Built |
| Wingman UI wired to real API | Built |
| Enriched prompt (Layers 3-5) | Not built — currently Layer 1-2 only |
| Morning screener (code filters + Claude rank) | Not built |
| Monitoring loop (15-min price checks) | Not built |
| Stop conditions / kill switch | Not built |
| End-of-day summary | Not built |
| Supabase persistence | Not built (blocked on schema review) |
| Alpaca integration | Not built (blocked on signup) |

---

*Canonical source: `docs/signal-strategy.md` in the code repo. This Obsidian note is a synced copy — update both when the strategy changes.*
