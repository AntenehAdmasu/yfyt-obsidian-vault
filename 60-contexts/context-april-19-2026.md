# YFYT — Session Context Document
**Date:** April 19, 2026  
**Purpose:** Handover context for new Claude Code session when context limit hits.  
**Pass this file to the next session and say:** *"Read this file first. It is your full context for the YFYT project."*

**Prior context:** `contexts/context-april-18-2026.md` — read that first for API keys setup and Phase 1 planning. This document covers April 19.

---

## Who is building this

- **Anti** — FAANG software engineer, London (GMT/BST). PM/founder mode — directs AI agents to build.
- **Elsh** — Anti's girlfriend. Software engineer, New York (EST). Co-building YFYT.

---

## What happened April 19

### 1. Obsidian vault fully populated

The separate Obsidian vault at `/Users/antenehadmasu/Projects/Obsidian Vault/YFYT/` was populated with all project knowledge. Remote: `https://github.com/AntenehAdmasu/yfyt-obsidian-vault`

**Structure:**

| Folder | Contents |
|---|---|
| `10-product/` | vision, scope, users, pitfalls — all filled with real content |
| `20-features/` | wingman-signal-generation, risk-engine, chat-follow-up, database-schema, market-data, parking-lot |
| `30-decisions/` | 2026-04-16-model-locked, 2026-04-16-build-rhythm, 2026-04-18-trading-targets |
| `40-research/` | tech-stack, competitive-landscape, api-cost-analysis |
| `50-meta/` | glossary (20+ terms), open-questions |
| `60-contexts/` | about-contexts explainer + all 4 context files (Apr 14, 15, 16-17, 18) |

All notes use `[[wikilinks]]` for cross-referencing. Reference file added to code repo at `docs/obsidian-vault.md`. Memory saved for future sessions.

Committed and pushed to `yfyt-obsidian-vault` remote.

### 2. Real signal generation built — end-to-end working

The core of Phase 1 is now functional: real market data → Claude Opus 4.6 → validated trading signal.

**New files created:**

| File | Purpose |
|---|---|
| `lib/market-data.ts` | Alpha Vantage service — fetches daily OHLCV candles, RSI(14), calculates SMA 20/50, volume metrics, formats data as text for Claude prompt |
| `lib/signal-schema.ts` | Zod schema for validating Claude's JSON output + risk engine (6 hard rules) + Wingman system prompt |
| `app/api/wingman/signal/route.ts` | `POST /api/wingman/signal` — fetches market data → prompts Opus → Zod validates → risk engine → returns signal. Auto-retries if R:R < 2 |
| `app/api/wingman/chat/route.ts` | `POST /api/wingman/chat` — streaming follow-up chat with signal context + conversation history |

**Packages installed:** `@anthropic-ai/sdk`, `zod`

### 3. Wingman UI wired to real API

`app/wingman/page.tsx` updated:
- `runAnalysis()` now calls `POST /api/wingman/signal` instead of `generateSignal()` mock
- `handleChatSend()` now calls `POST /api/wingman/chat` instead of `getMockWingmanReply()` mock
- Auto-analysis on page load **removed** — real API calls cost money, user must click refresh
- Import of `generateSignal` and `getMockWingmanReply` from mock-signals removed

### 4. Alpha Vantage rate limit fix

The initial implementation used `Promise.all` to fetch candles + RSI in parallel, which hit Alpha Vantage's 1 request/sec burst limit. Fixed by making calls sequential with a 1.2s delay between them.

**Key discovery:** The Alpha Vantage error message says "spread out requests (1 per second)" — this is a **burst rate limit**, not a daily cap. The 25 requests/day is a separate limit. For moderate usage (~10-12 signals/day × 2 calls each = 20-24 daily), the free tier is usable.

### 5. Successful live test

Tested the full pipeline: AAPL daily → Alpha Vantage real data → Claude Opus 4.6 → Zod validation → risk engine check → returned valid BUY signal:
- Entry $270.23, SL $261, TP $289, R:R 1:2.03
- 4 detailed reasoning points referencing actual dates and price levels
- 3 trading concepts explained
- Zero risk engine violations

### 6. Alpaca and database deferred

Anti didn't have time to fix Alpaca signup or review the database schema. Decision: proceed without blocking on these — Alpha Vantage works for dev, localStorage continues as temporary store. Both will be plugged in later without rewriting.

---

## Risk engine rules (implemented in `lib/signal-schema.ts`)

| Rule | Value | Implementation |
|---|---|---|
| Min R:R | 1:2 | If Claude returns R:R < 2, auto-retry with correction prompt |
| Max position size | 10% | Capped in `applyRiskRules()` |
| Max portfolio risk per trade | 2% | Position size reduced if risk > 2% of portfolio |
| Stop loss direction | Must be below entry (BUY) or above entry (SELL) | Rejected if wrong side |
| Take profit direction | Must be above entry (BUY) or below entry (SELL) | Rejected if wrong side |

### System prompt (in `lib/signal-schema.ts`)

Wingman is configured as a swing trader (1-10 day holds) with:
- Price action first, indicators confirm
- Trend identification (higher highs/lows)
- Volume confirmation required
- Minimum 1:2 R:R enforced
- WAIT output if setup is unclear
- Educational tone — explain WHY, teach concepts
- Output: raw JSON only, no markdown

---

## Current state of what works vs what's mocked

| Component | Real or Mock? |
|---|---|
| Market data (OHLCV, RSI) | **Real** — Alpha Vantage |
| Signal generation | **Real** — Claude Opus 4.6 |
| Chat follow-up | **Real** — Claude Opus 4.6 (streaming) |
| Risk engine | **Real** — Zod + hard rules |
| Stock search/selection | **Mock** — 10 hardcoded tickers in MOCK_STOCKS |
| CandleChart visuals | **Mock** — uses generated fake candle data |
| Trade execution | **Mock** — localStorage + mock prices |
| Portfolio/P&L | **Mock** — localStorage |
| Auth | **Mock** — name entry only, no Supabase |
| Database | **Mock** — localStorage |

---

## Files changed/created April 19

| File | Change |
|---|---|
| `lib/market-data.ts` | NEW — Alpha Vantage market data service |
| `lib/signal-schema.ts` | NEW — Zod schema, risk engine, system prompt |
| `app/api/wingman/signal/route.ts` | NEW — signal generation API route |
| `app/api/wingman/chat/route.ts` | NEW — streaming chat API route |
| `app/wingman/page.tsx` | MODIFIED — wired to real API, removed mock imports, removed auto-analysis |
| `docs/obsidian-vault.md` | NEW — reference to Obsidian vault location and structure |
| `package.json` / `package-lock.json` | MODIFIED — added `@anthropic-ai/sdk`, `zod` |
| `contexts/context-april-19-2026.md` | NEW — this file |

---

## What to do next session

### Still pending from Anti
1. Review database schema in `temp-plan/database.md` — answer 4 open questions
2. Fix Alpaca Markets signup (try different email)
3. Rotate Anthropic API key (was shared in chat)
4. Review risk engine rules and system prompt in `temp-plan/signal-generation-design.html`
5. Draft starting watchlist (30-50 tickers)

### Build tasks remaining for Phase 1
1. **Supabase schema + auth** — create tables, wire up client (blocked on Anti's review)
2. **Replace MOCK_STOCKS** with real ticker search (can use Alpha Vantage symbol search endpoint)
3. **Wire CandleChart to real data** — pass real candles from signal API to the chart component
4. **Trade execution with live prices** — use Alpha Vantage current price instead of mock
5. **Portfolio P&L with live prices** — same
6. **End-to-end testing** — 10 full cycles to pass Phase 1 gate

### Phase 1 gate reminder
> Run signal → take trade → see outcome tracked. 10 times, zero manual intervention.

---

## Known issues

- Alpha Vantage free tier: 25 requests/day + 1 req/sec burst limit. Enough for dev, tight for real usage. Alpaca (free, unlimited WebSocket) is the solution.
- Signal generation takes ~8-15 seconds (Alpha Vantage fetch + Claude Opus response). Acceptable but not snappy.
- The `AnalysingState` loading animation steps are still the old mock text. Could be updated to reflect real pipeline stages.
- Chat returns the full response at once (not true streaming) — the SSE endpoint sends one `data:` event with the complete text. True token-by-token streaming would improve UX.
