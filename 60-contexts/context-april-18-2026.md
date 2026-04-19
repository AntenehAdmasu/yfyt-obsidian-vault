# YFYT — Session Context Document
**Date:** April 18, 2026  
**Purpose:** Handover context for new Claude Code session when context limit hits.  
**Pass this file to the next session and say:** *"Read this file first. It is your full context for the YFYT project."*

**Prior context:** `contexts/context-april-16-17-2026.md` — read that first for full history through April 17. This document covers April 18.

---

## Who is building this

- **Anti** — FAANG software engineer, London (GMT/BST). PM/founder mode — directs AI agents to build.
- **Elsh** — Anti's girlfriend. Software engineer, New York (EST). Co-building YFYT.

---

## What happened April 18

### 1. API keys set up and verified

All three Phase 1 services are connected and tested:

| Service | Key | Status |
|---|---|---|
| **Anthropic** (Claude Opus 4.6) | `ANTHROPIC_API_KEY` in `.env.local` | Working — tested with real API call |
| **Alpha Vantage** (market data) | `ALPHA_VANTAGE_API_KEY` in `.env.local` | Working — fetched real AAPL data |
| **Supabase** (database + auth) | `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` in `.env.local` | Connected — project ref `fbddjonlgqkcznamgztw` |

**Alpaca Markets** — signup blocked (email domain error). Anti needs to retry with a different email (plain Gmail, Outlook, or work email). Alpaca is preferred over Alpha Vantage because it offers free real-time WebSocket streaming, whereas Alpha Vantage free tier is limited to 25 requests/day.

**IMPORTANT:** Anti shared API keys in the chat. The Anthropic key needs to be rotated — go to console.anthropic.com, delete the current key, create a new one, update `.env.local`.

### 2. End-to-end test run — real data → real AI signal

Successfully ran a full pipeline test:

1. **Alpha Vantage** → fetched real AAPL daily OHLCV data (last 13 candles) + 14-day RSI
2. **Claude Opus 4.6** → sent structured prompt with the real data → received valid JSON signal
3. **Result:** BUY AAPL at $270.23, SL $256.50, TP $284.00, R:R 1:1, MEDIUM confidence

**Usage from the test:** 872 tokens in, 790 tokens out (~$0.07 total cost)

Anti flagged the R:R — 1:1 is a bad trade. Agreed to enforce minimum 1:2 R:R in the risk engine.

### 3. Anthropic API billing clarification

Anti's $24/month is a fixed credit plan (Build tier), not pay-as-you-go. He'll be notified when approaching the limit. The Claude Pro/Max subscription (used for Claude Code conversations) is separate from the API billing.

### 4. Trading targets and strategy agreed

**Paper trading target:** 2% per week (~£200) from a £10,000 pot.

Context:
- 2%/week is aggressive but achievable for disciplined swing traders
- Professional day traders hit this range
- $1K/week from $5K (Anti's initial ask) would be 20%/week — unrealistic
- Revised to £10K pot → £200/week target
- Goal: prove consistency over 3 months of paper trading before considering real money

**Monitoring architecture (cost-optimised):**
- Morning: fetch data for 50-100 tickers → local code filters (volume, gaps, RSI extremes) → shortlist 5-10
- Claude Opus: only called for the 5-10 shortlisted tickers (deep analysis)
- Intraday: check 3-5 active tickers every 30 min with code logic, not Claude
- Alerts: code detects entry/SL/TP hits → notification
- Evening: 1 Claude call for post-mortem
- Daily cost estimate: ~$1.75/day (~$35-50/month)

### 5. Phase 1 broken into 10 sequential steps

| Step | What | Status |
|---|---|---|
| 1 | Supabase schema + auth | Designed (in `temp-plan/database.md`) |
| 2 | Replace localStorage with Supabase | Not started — starting fresh, no migration |
| 3 | Market data service (Alpaca or Alpha Vantage) | Not started — blocked on Alpaca signup |
| 4 | Signal generation API route (`/api/wingman/signal`) | Designed (in `temp-plan/signal-generation-design.html`) |
| 5 | Wire Wingman UI to real API | Not started |
| 6 | Risk engine (min 1:2 R:R, position limits) | Rules designed |
| 7 | Trade execution with real prices | Not started |
| 8 | Chat follow-up API route (`/api/wingman/chat`) | Not started |
| 9 | Portfolio P&L with live prices | Not started |
| 10 | End-to-end testing (10 full cycles) | Not started |

### 6. Design documents created in `temp-plan/`

| File | Purpose |
|---|---|
| `temp-plan/database.md` | Full Supabase schema — 7 tables (users, portfolios, positions, trades, signals, chat_messages, watchlist), RLS policies, indexes, triggers, open questions |
| `temp-plan/setup-instructions.html` | 9-slide Reveal.js deck — manual tasks Anti needs to do (Alpaca signup, rotate API key, enable Supabase auth, create tables) |
| `temp-plan/signal-generation-design.html` | 10-slide Reveal.js deck — signal flow, system prompt, output schema, risk engine rules, stock selection strategy, cost projections |

---

## Alpha Vantage vs Alpaca — key difference

| | Alpha Vantage (current) | Alpaca Markets (preferred) |
|---|---|---|
| **Free tier** | 25 requests/day | Unlimited (IEX real-time stream) |
| **Real-time** | No (15-min delay on free) | Yes (WebSocket streaming) |
| **Cost for more** | $50/mo for 75 req/min | Free |
| **Paper trading API** | No | Yes (built-in) |
| **Signup status** | Working | Blocked (email domain issue) |

Alpaca is strictly better if Anti can resolve the signup.

---

## Open questions for Anti/Elsh (from database.md)

1. **Starting balance**: £10,000 confirmed?
2. **Currency**: GBP only, or support USD too?
3. **Multiple portfolios**: One per user for Phase 1?
4. **Auth method**: Magic link only to start, or also Google OAuth?

---

## Risk engine rules (proposed, pending Anti's review)

| Rule | Value |
|---|---|
| Min risk:reward | 1:2 |
| Max position size | 10% of portfolio |
| Max daily trades | 5 |
| Max portfolio risk per trade | 2% of total value |
| Stop loss | Always required |
| Same-ticker stacking | Blocked (1 position per ticker) |

---

## What to do next session

1. Anti reviews `temp-plan/database.md` — answers open questions, tweaks if needed
2. Anti reviews system prompt and risk rules in `temp-plan/signal-generation-design.html`
3. Anti fixes Alpaca signup (or decides on alternative)
4. Anti rotates Anthropic API key
5. Anti drafts starting watchlist (30-50 tickers)
6. Once approved → Claude generates SQL migration → Anti runs it in Supabase SQL Editor
7. Build continues from Step 2 onwards

---

## Current .env.local structure

```
ANTHROPIC_API_KEY=sk-ant-... (NEEDS ROTATION)
ALPHA_VANTAGE_API_KEY=8KT1UC9I3GJX761T
NEXT_PUBLIC_SUPABASE_URL=https://fbddjonlgqkcznamgztw.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
# ALPACA_API_KEY= (pending signup)
# ALPACA_API_SECRET= (pending signup)
```

All keys are in `.env.local` which is gitignored. Never commit this file.

---

## Files changed/created April 18

| File | Change |
|---|---|
| `.env.local` | NEW — API keys for Anthropic, Alpha Vantage, Supabase |
| `temp-plan/database.md` | NEW — full Supabase schema design |
| `temp-plan/setup-instructions.html` | NEW — manual setup tasks slide deck |
| `temp-plan/signal-generation-design.html` | NEW — signal generation architecture slide deck |
| `contexts/context-april-18-2026.md` | NEW — this file |

All previous UI redesign changes were committed and pushed to `origin/main` at the start of this session.
