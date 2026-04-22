# YFYT — Session Context Document
**Date:** April 20-22, 2026  
**Purpose:** Handover context for new Claude Code session when context limit hits.  
**Pass this file to the next session and say:** *"Read this file first. It is your full context for the YFYT project."*

**Prior context:** `contexts/context-april-19-2026.md` — read that first for real signal generation and Obsidian vault setup. This document covers April 20-22.

---

## Who is building this

- **Anti** — FAANG software engineer, London (GMT/BST). PM/founder mode — directs AI agents to build.
- **Elsh** — Anti's girlfriend. Software engineer, New York (EST). Co-building YFYT.

---

## What happened April 20

### 1. Signal strategy document finalised

The canonical signal architecture was written and approved: `docs/signal-strategy.md`. Also synced to the Obsidian vault at `20-features/signal-strategy.md`.

Key decisions locked in:
- **75 tickers**, 15-min monitoring, ~$4/day budget (~$80/month)
- **Two-pass morning screener**: Pass 1 code filters (free) → Pass 2 Claude ranking (1 call, ~$0.25)
- **Enriched prompt**: 6,600 tokens (~3.3% of 200K context), 5 layers
- **Stop conditions**: 5 trades/day, 2% daily loss kill switch, market hours
- **All-in monthly cost**: ~$100 (Claude Pro $20 + API ~$80)

### 2. Financial projections discussed

Anti plans to start with £5K, scale to £10K once system proves itself. Key numbers:

| Scenario | £5K | £10K |
|---|---|---|
| Break-even return needed | 19.2% | 9.6% |
| Realistic net P&L | -£360 to +£240 | +£240 to +£1,440 |
| Optimistic net P&L | +£840 to +£1,440 | +£2,640 to +£3,840 |

API costs are fixed (~£960/year), so scaling capital improves the math significantly. £10K is the real starting line where realistic scenarios turn net positive.

### 3. Dynamic position sizing confirmed

Anti confirmed that position sizing should calculate off current equity (gross portfolio value), not starting capital. If equity drops to £5K, positions halve. If equity grows to £20K, positions double. This makes blowup mathematically asymptotic — you can never truly reach zero.

### 4. Risk rule values are not final

Anti explicitly stated the current numbers (10% max position, 2% risk per trade, 1:2 R:R, etc.) are placeholders to indicate the rules exist. They will be tuned during paper trading. The risk engine was designed to accept a `RiskConfig` object so values can be changed without code modifications.

### 5. Signal generation design slides fixed

`temp-plan/signal-generation-design.html` was updated:
- Fixed content overflow / truncation issues on multiple slides
- Updated from outdated ~$1.75/day costs to approved ~$4/day
- Updated from ~1,100 token prompt to enriched 6,600 token prompt
- Added new slides for morning screener and monitoring loop
- Now 11 slides (was 10), all fitting within Reveal.js viewport

### 6. Parking lot updated

Ticker knowledge base idea added to both `plan/parking-lot.md` and Obsidian `20-features/parking-lot.md` — persistent per-ticker notes with dated entries, auto-expire stale entries, feed into Layer 5 of enriched prompt.

### 7. All changes committed and pushed

Both repos committed and pushed:
- YFYT code repo: `9b5d866` — 15 files, 1,935 lines (signal API, market data, risk engine, strategy doc, context files)
- Obsidian vault: `c2bd8d0` — signal strategy note

---

## What happened April 22

### 1. Morning screener built (Pass 1 — code filters)

New file: `lib/screener.ts`

**5 filter functions** matching the strategy doc:
- Volume > 1.5x 20-day average
- Gap up/down > 1%
- RSI(14) < 30 or > 70
- Price within 1% of SMA 20 or SMA 50
- New 20-day high or low

**Key functions:**
- `screenTicker(snapshot)` — runs all 5 filters on one ticker, returns scored candidate
- `runScreener(snapshots, minFilters)` — batch-processes array, filters by minimum score, sorts by quality
- `formatCandidatesForRanking(candidates)` — formats as compact text for Claude's Pass 2 ranking call

**51-ticker default universe** (`DEFAULT_UNIVERSE`) — mega-cap tech, high-volume movers, semis, financials, energy, health, retail, ETFs, crypto-adjacent. Starting list until Anti drafts a custom watchlist.

**Stub data generator** (`generateStubSnapshot`) — deterministic pseudo-random market data per ticker for development. RSI calculated from candle data (no API dependency).

**API route**: `POST /api/wingman/screener` — runs screener against stub data, returns candidates + formatted ranking prompt.

### 2. Enriched prompt builder (Layers 3-5)

New file: `lib/prompt-builder.ts`

Builds the remaining layers of the 6,600-token enriched prompt:

| Layer | Builder function | Status |
|---|---|---|
| 1. System prompt | Already in `signal-schema.ts` | Built (prior session) |
| 2. Market data | Already in `market-data.ts` | Built (prior session) |
| 3. Market context | `buildMarketContext()` + `formatMarketContext()` | **Built — stub data** |
| 4. User context | `buildUserContext()` + `formatUserContext()` | **Built — reads portfolio** |
| 5. Knowledge base | `buildKnowledgeBase()` + `formatKnowledgeBase()` | **Built — stub (empty)** |

**Layer 3 details:**
- SPY/QQQ/VIX snapshot with trend direction (based on SMA20 relationship)
- Sector ETF mapping for 30+ tickers (e.g. AAPL → XLK, AMZN → XLY)
- Earnings proximity detection (stub — returns no data yet)
- News headlines slot (stub — returns empty array)
- VIX stress indicator (warns if VIX > 25)

**Layer 4 details:**
- Portfolio value calculated from current equity (cash + positions at market price)
- Open positions with unrealized P&L per position
- Today's trade history
- Daily P&L and risk budget usage percentage
- Trades remaining count

**Layer 5 details:**
- Past signals for the ticker (stub — will query Supabase later)
- Observed trading patterns (stub — will populate over time)

`buildEnrichedPrompt()` assembles all layers with separators into a single prompt string.

### 3. Risk engine upgraded

Modified file: `lib/signal-schema.ts` — significant expansion.

**New types:**
- `RiskConfig` — all risk limits as configurable values, not hardcoded
- `DEFAULT_RISK_CONFIG` — starting values (all tuneable)
- `TradingState` — session-level state (today's trades, daily P&L, positions, portfolio value)
- `RiskResult` — now includes `blocked` flag and `blockReason` for session-level blocks

**New functions:**
- `buildTradingState(portfolio, currentPrices)` — constructs trading state from portfolio + live prices
- `canTrade(tradingState, config)` — pre-signal gate that checks session-level limits BEFORE calling Claude (saves API cost)
- `checkTickerStacking(ticker, positions)` — prevents opening a second position on the same ticker
- `isMarketOpen()` — detects weekends, pre-market, after-hours (US Eastern time)

**Upgraded `applyRiskRules()`:**
- Now accepts optional `RiskConfig` (defaults to `DEFAULT_RISK_CONFIG`)
- Now accepts optional `TradingState` for session-level checks
- Position sizing uses current equity, not hardcoded $10K
- Returns `blocked` and `blockReason` in addition to `valid` and `issues`

### 4. Signal route updated

Modified file: `app/api/wingman/signal/route.ts`

- Runs pre-signal checks (ticker stacking, trade count, kill switch) BEFORE calling Claude — saves ~$0.14 per blocked signal
- Uses enriched prompt (Layers 2-5) instead of just Layer 2
- Accepts optional `portfolio`, `currentPrices`, and `riskConfig` from the client body
- Falls back to defaults ($10K portfolio, default config) for backwards compatibility
- `_meta` now includes `portfolioValue` and `tradesRemaining`

### 5. Build verified

`npx next build` — compiled successfully with zero TypeScript errors. All routes registered:
- `POST /api/wingman/signal` (updated)
- `POST /api/wingman/chat` (unchanged)
- `POST /api/wingman/screener` (new)

---

## Current state of what works vs what's mocked

| Component | Real or Mock? |
|---|---|
| Market data (OHLCV, RSI) | **Real** — Alpha Vantage |
| Signal generation | **Real** — Claude Opus 4.6 |
| Chat follow-up | **Real** — Claude Opus 4.6 (streaming) |
| Risk engine | **Real** — Zod + hard rules + session checks + dynamic sizing |
| Morning screener (code filters) | **Built** — running against stub data |
| Enriched prompt (Layers 3-5) | **Built** — Layer 4 reads real portfolio, Layers 3+5 use stubs |
| Screener API route | **Built** — returns stub data candidates |
| Stock search/selection | **Mock** — 10 hardcoded tickers in MOCK_STOCKS |
| CandleChart visuals | **Mock** — uses generated fake candle data |
| Trade execution | **Mock** — localStorage + mock prices |
| Portfolio/P&L | **Mock** — localStorage |
| Auth | **Mock** — name entry only, no Supabase |
| Database | **Mock** — localStorage |

---

## Files created/modified April 20-22

| File | Change |
|---|---|
| `lib/screener.ts` | NEW — morning screener filters, stub data, 51-ticker universe |
| `lib/prompt-builder.ts` | NEW — enriched prompt builder (Layers 3-5) |
| `lib/signal-schema.ts` | MODIFIED — risk engine upgrades (RiskConfig, TradingState, kill switch, stacking, market hours) |
| `app/api/wingman/signal/route.ts` | MODIFIED — pre-signal checks, enriched prompt, configurable risk |
| `app/api/wingman/screener/route.ts` | NEW — screener API endpoint |
| `docs/signal-strategy.md` | NEW — canonical signal architecture document |
| `temp-plan/signal-generation-design.html` | MODIFIED — fixed formatting, updated to match approved strategy |
| `contexts/context-april-20-22-2026.md` | NEW — this file |

---

## What to do next session

### Still pending from Anti
1. Review database schema in `temp-plan/database.md` — answer 4 open questions
2. Fix Alpaca Markets signup (try different email)
3. Rotate Anthropic API key (was shared in chat)
4. Review risk engine rules and system prompt
5. Draft starting watchlist (30-50 tickers) — default 51-ticker universe is in place as fallback

### Build tasks remaining for Phase 1
1. **Supabase schema + auth** — create tables, wire up client (blocked on Anti's review)
2. **Replace MOCK_STOCKS** with real ticker search or the screener universe
3. **Wire CandleChart to real data** — pass real candles from signal API to the chart component
4. **Trade execution with live prices** — use Alpha Vantage current price instead of mock
5. **Portfolio P&L with live prices** — same
6. **Wire screener to Alpaca** — swap stub data for real market data (blocked on Alpaca signup)
7. **Wire Layer 3 to real data** — fetch SPY/QQQ/VIX snapshots, news headlines, earnings dates
8. **Wire Layer 5 to Supabase** — query past signals for the ticker (blocked on database)
9. **Monitoring loop** — 15-min price check service with entry zone detection
10. **End-of-day summary** — daily performance recap generator
11. **End-to-end testing** — 10 full cycles to pass Phase 1 gate

### Phase 1 gate reminder
> Run signal → take trade → see outcome tracked. 10 times, zero manual intervention.

---

## Architecture overview (as of April 22)

```
User clicks "Analyse" in Wingman UI
  │
  ├─ Pre-signal checks (FREE — no API call)
  │   ├─ checkTickerStacking() — already holding this ticker?
  │   ├─ canTrade() — daily trade limit? kill switch active?
  │   └─ isMarketOpen() — weekend/pre-market/after-hours?
  │
  ├─ Fetch market data (Alpha Vantage — 2 API calls)
  │   ├─ getDailyCandles() — OHLCV
  │   └─ getRSI() — RSI(14)
  │
  ├─ Build enriched prompt (~6,600 tokens)
  │   ├─ Layer 2: formatForPrompt(snapshot) — ticker data
  │   ├─ Layer 3: buildMarketContext() — SPY/QQQ/VIX, sector, earnings, news
  │   ├─ Layer 4: buildUserContext() — portfolio, positions, P&L, risk budget
  │   └─ Layer 5: buildKnowledgeBase() — past signals, patterns
  │
  ├─ Call Claude Opus 4.6 (~$0.14)
  │   ├─ System prompt (Layer 1) as system message
  │   └─ Enriched prompt (Layers 2-5) as user message
  │
  ├─ Validate response
  │   ├─ Zod schema validation
  │   ├─ R:R check — auto-retry if below minimum
  │   └─ Risk engine — position sizing, SL/TP direction
  │
  └─ Return signal to UI
```

```
Morning Screener (not yet wired to UI)
  │
  ├─ Pass 1: Code filters (FREE)
  │   ├─ 51 tickers from DEFAULT_UNIVERSE
  │   ├─ 5 filters: volume, gap, RSI, SMA proximity, 20d high/low
  │   └─ Returns ~20-25 candidates scored 1-5
  │
  └─ Pass 2: Claude ranking (~$0.25)  [NOT BUILT YET]
      ├─ formatCandidatesForRanking() — compact stats text
      └─ Claude picks top 10 with entry zones + theses
```
