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

### 11. Pass 2 Claude ranking built (mocked)

New file: `lib/screener-ranking.ts`

- `RankedTickerSchema` — Zod schema: rank, setup quality (A/B/C), entry zone (low/high), thesis, trap flag + reason
- `RankingOutputSchema` — top picks array, market bias, market note, skipped count
- `RANKING_SYSTEM_PROMPT` — full system prompt for ranking with methodology, trap detection, JSON output
- `buildRankingPrompt()` — assembles candidates + market context + open positions into user prompt
- `rankWithClaude()` — real Claude call (commented out, ready to uncomment when API key is live)
- `mockRankCandidates()` — deterministic mock: scores, sorts, assigns entry zones/theses, flags traps, determines market bias

Screener route (`app/api/wingman/screener/route.ts`) updated to run full Pass 1 → Pass 2 pipeline. Accepts `openPositions` to exclude held tickers. `skipPass2` flag for code-filters-only mode.

### 12. Market clock UI built

New component: `components/wingman/MarketClock.tsx`

Placed in Wingman top bar between refresh button and cash display:
- Green pulsing dot + "Market Open" during 9:30 AM - 4:00 PM ET with countdown to close
- Amber dot + "Pre-Market" before 9:30 AM with countdown to open
- Grey dot + "After Hours" / "Weekend" with countdown to next open
- Shows local time with timezone abbreviation (e.g. "21:45 BST")
- Updates every 15 seconds

### 13. Strategy tuning parking lot created

New file: `plan/strategy-tuning.md` (+ Obsidian copy at `20-features/strategy-tuning.md`)

Dedicated file for screener and signal refinement ideas:
- ATR-normalised gaps (replace flat 1%)
- Tiered ticker pool expansion (expand search, never relax thresholds)
- Confidence scoring for when too many candidates pass
- 6 algorithmic approaches: relative strength vs SPY, ATR expansion, pre-market movers, sector rotation, volatility squeeze, unusual options activity
- Weekly pool re-evaluation idea also parked here

### 14. Gap + volume safeguard implemented

`lib/screener.ts` updated: gap filter now requires today's volume ≥ 1x average. A gap on below-average volume is flagged `(low vol)` and doesn't pass. Prevents counting manipulation or thin-liquidity fake gaps.

### 15. CLAUDE.md updated for context persistence

`CLAUDE.md` now instructs Claude to read the latest context file from `contexts/` when starting a new session or recovering from compaction. Lists key project files for fast orientation.

---

## Files created/modified April 20-22

| File | Change |
|---|---|
| `lib/screener.ts` | NEW — morning screener filters, stub data, 51-ticker universe, gap+vol safeguard |
| `lib/screener-ranking.ts` | NEW — Pass 2 ranking prompt, schema, mock ranker |
| `lib/prompt-builder.ts` | NEW — enriched prompt builder (Layers 3-5) |
| `lib/signal-schema.ts` | MODIFIED — risk engine upgrades (RiskConfig, TradingState, kill switch, stacking, market hours) |
| `app/api/wingman/signal/route.ts` | MODIFIED — pre-signal checks, enriched prompt, configurable risk |
| `app/api/wingman/screener/route.ts` | NEW → MODIFIED — full Pass 1 → Pass 2 pipeline |
| `app/wingman/page.tsx` | MODIFIED — RiskDashboard, MarketClock, portfolio state tracking |
| `components/wingman/RiskDashboard.tsx` | NEW — risk enforcement stats, progress bar, rules panel |
| `components/wingman/MarketClock.tsx` | NEW — market open/closed status, countdown, local time |
| `docs/signal-strategy.md` | NEW — canonical signal architecture document |
| `plan/strategy-tuning.md` | NEW — screener/signal refinement parking lot |
| `plan/parking-lot.md` | MODIFIED — added weekly pool re-eval, cross-ref to strategy-tuning |
| `temp-plan/signal-generation-design.html` | MODIFIED — fixed formatting, updated to match approved strategy |
| `CLAUDE.md` | MODIFIED — context persistence instructions, key file list |
| `contexts/context-april-20-22-2026.md` | NEW — this file |

---

## What to do next session

### Pending from Anti (external setup)
1. Rotate Anthropic API key — [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys)
2. Fix Alpaca Markets signup (try different email) — need API key + secret
3. Review database schema in `temp-plan/database.md` — answer 4 open questions
4. Create Supabase tables — Claude builds migration once schema is approved

### Build tasks — no external dependencies (do these first)
1. **Replace MOCK_STOCKS** with the 51-ticker screener universe
2. **Wire CandleChart to real candle data** — signal API already returns OHLCV, pass it to chart
3. **Send portfolio state to signal route** — so dynamic sizing actually works (not defaults)
4. **Screener UI** — page or panel to trigger morning screener, see Pass 1 + Pass 2 results
5. **Monitoring loop skeleton** — 15-min price checks, entry zone detection, stop conditions (stub prices)
6. **End-of-day summary template** — daily performance recap generator

### Build tasks — blocked on external setup
7. **Wire screener to Alpaca** — swap stub data for real market data (blocked on #2)
8. **Wire Layer 3 to real data** — SPY/QQQ/VIX snapshots, news headlines, earnings dates (blocked on #2)
9. **Supabase schema + auth** — create tables, wire client (blocked on #3/#4)
10. **Wire Layer 5 to Supabase** — past signals per ticker (blocked on #9)
11. **Trade execution with live prices** — needs Alpaca or Alpha Vantage current price (blocked on #2)
12. **Flip Pass 2 to real Claude** — uncomment `rankWithClaude()`, remove mock (blocked on #1)
11. **End-to-end testing** — 10 full cycles to pass Phase 1 gate

### Phase 1 gate reminder
> Run signal → take trade → see outcome tracked. 10 times, zero manual intervention.

---

## Continued April 22 — afternoon session

### 8. Risk dashboard UI built

New component: `components/wingman/RiskDashboard.tsx`

Placed in the Wingman signal panel between the header and signal card. Shows:
- **3-column stat strip:** Portfolio value, Today's P&L (with color), Trades used (x/5)
- **Daily loss progress bar:** Fills as losses accumulate. Color shifts green → amber → red. Shows remaining headroom in dollars ("$150 remaining").
- **Quick stats row:** Cash balance, open position count
- **Risk Rules section (collapsible):** All 8 rules with current values. Note that sizing is off current equity.
- **Kill switch / blocked banner:** Red alert when daily loss limit or trade limit is hit.

Updates live after each trade via `refreshPortfolioState()`.

`app/wingman/page.tsx` modified:
- Added portfolio state tracking: `portfolioValue`, `dailyPnL`, `todaysTradeCount`, `openPositionCount`
- Added `refreshPortfolioState()` callback — reads portfolio, calculates equity, counts today's trades, computes unrealized P&L
- Trade handler now calls `refreshPortfolioState()` after execution
- Imported and placed `RiskDashboard` in signal panel

### 9. Screener parameter deep-dive

Anti reviewed all 5 screener filter parameters. Key findings and decisions:

**Lookback periods and manipulation resistance:**
- 20-day averages (volume, highs/lows) are hard to manipulate — need weeks of fake activity
- 14-period RSI and 20/50 SMAs are inherently smoothed
- Gap filter (1-day event) is the most susceptible to manipulation — should require volume confirmation
- General rule: longer lookback = harder to fake, but less responsive. 20 days is the swing trading sweet spot

**Parameter assessment:**
| Parameter | Value | Verdict |
|---|---|---|
| Volume > 1.5x 20d avg | Conservative but sensible for multi-filter system | Keep, may tune to 2x if too noisy |
| Gap > 1% | Flat % doesn't account for per-stock volatility | Consider upgrading to ATR-normalised gaps later |
| RSI 30/70 | Textbook Wilder thresholds, universally accepted | Keep |
| SMA proximity 1% | Reasonable for "in the zone" detection | Keep |
| New 20-day high/low | Standard for swing trading breakouts | Keep |

**Gap + volume safeguard proposed:** Gap filter should only trigger if today's volume is also ≥ 1x average (not below normal). Prevents counting low-volume fake gaps. Not yet implemented.

**Adaptive expansion agreed:** If fewer than 15 candidates pass strict filters, progressively relax thresholds (e.g. volume 1.5x → 1.3x, gap 1% → 0.7%) up to 3 rounds. Guarantees Claude always has enough candidates. Not yet implemented.

**Other algorithmic approaches discussed for future:**
1. Relative strength vs SPY (Mansfield method) — stocks outperforming the market
2. ATR expansion — volatility increasing, stock "waking up"
3. Pre-market movers — from Alpaca, overnight/early morning activity
4. Sector rotation scan — identify hot sectors first, then pick strongest stocks within
5. Consolidation breakout detection — narrowing Bollinger Bands / volatility squeeze
6. Unusual options activity — leading indicator (needs paid data feed)

### 10. Parking lot additions

Added to both `plan/parking-lot.md` and Obsidian `20-features/parking-lot.md`:
- **Weekly pool re-evaluation** — auto-review the base ticker universe weekly. Detect stale tickers (no setups for 2+ weeks) and trending mid-caps gaining momentum. Suggest swaps.

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
