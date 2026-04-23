# YFYT — Session Context Document
**Date:** April 23, 2026  
**Purpose:** Handover context for new Claude Code session when context limit hits.  
**Pass this file to the next session and say:** *"Read this file first. It is your full context for the YFYT project."*

**Prior context:** `contexts/context-april-20-22-2026.md` — covers the three core builds (screener, prompt builder, risk engine), UI components, and strategy discussions.

---

## Who is building this

- **Anti** — FAANG software engineer, London (GMT/BST). PM/founder mode — directs AI agents to build.
- **Elsh** — Anti's girlfriend. Will use the app later. Second seed user in the database.

---

## What happened April 23

### 1. Supabase database fully wired

**Schema design was finalized** with Anti's answers to the 4 open questions:
- Starting balance: £10,000 (GBP only for now, USD later)
- One portfolio per user (Phase 1)
- No real auth — seed users with cookie-based session picker

**Migration created and executed:**
- `supabase/migrations/001_initial_schema.sql` — 7 tables, indexes, triggers, RLS
- Tables: `users`, `portfolios`, `positions`, `trades`, `signals`, `chat_messages`, `watchlist`
- Seed users: Anti (`a1b2c3d4-e5f6-7890-abcd-ef1234567890`) and Elsh (`b2c3d4e5-f6a7-8901-bcde-f12345678901`)
- RLS enabled but using permissive `true` policies for dev — swap to `auth.uid()` when real auth is added

**Client library:**
- `lib/supabase.ts` — browser client (anon key) + server client (service_role key)
- `lib/supabase-storage.ts` — full Supabase-backed storage layer mirroring localStorage API
  - `getPortfolioFromDb()` — reads portfolio, positions, trades from Supabase
  - `executeTradeInDb()` — full buy/sell logic with position averaging, cash updates
  - `saveSignalToDb()` — persists signals with all metadata

**User session system:**
- `lib/user-context.tsx` — React context with cookie-based user ID, `useUser()` hook
- `components/UserPicker.tsx` — "Who's trading?" modal on first visit (Anti / Elsh)
- `components/DevTools.tsx` — bottom-right dev panel for clearing DB tables during testing
- `app/api/dev/reset/route.ts` — API for clearing trades, positions, signals, etc. per user

**Env vars required:**
```
NEXT_PUBLIC_SUPABASE_URL=<set>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<set>
SUPABASE_SERVICE_ROLE_KEY=<set>
ANTHROPIC_API_KEY=<set>
ALPHA_VANTAGE_API_KEY=<set>
```

### 2. Screener UI page built

New page at `/screener` with full two-pass screener UI:
- Run button triggers `POST /api/wingman/screener`
- Configurable minimum filter count (1-5)
- Summary strip: tickers scanned, pass 1 candidates, pass 2 ranked, market bias
- Pass 2 top picks: ranked cards with setup quality (A/B/C), entry zones, theses, trap flags
- Pass 1 candidates: expandable cards showing all 5 filter results per ticker
- Collapsible ranking prompt viewer (shows exactly what Claude sees)
- Added to sidebar and bottom nav with ScanSearch icon

### 3. MOCK_STOCKS expanded to 51 tickers

`lib/mock-market.ts` now generates `StockQuote` data from the `DEFAULT_UNIVERSE` in `screener.ts`. The old hardcoded 10-stock array is replaced with deterministic stub data for all 51 tickers. All consumers (wingman, portfolio, dashboard) automatically get the full universe.

### 4. Portfolio state wired to signal route

The wingman page now sends `portfolio` and `currentPrices` in the signal request body, enabling:
- Dynamic position sizing off current equity (not starting capital)
- Pre-signal risk checks (ticker stacking, daily trade limit, kill switch)
- The signal route returns `blocked: true` with reason when risk rules prevent trading
- UI handles blocked responses with error messages

### 5. Pass 2 flipped to real Claude

- `rankWithClaude()` in `lib/screener-ranking.ts` is now live (was commented out)
- Screener route (`app/api/wingman/screener/route.ts`) uses real Claude when `ANTHROPIC_API_KEY` is set
- Falls back to `mockRankCandidates()` if the API call fails
- Response includes `rankingSource: 'claude' | 'mock'` so the UI knows which was used

### 6. Layer 5 wired to Supabase

`buildKnowledgeBase()` in `lib/prompt-builder.ts` now queries Supabase for:
- Past signals for the ticker being analysed (up to 10, newest first)
- Trade outcomes (win/loss/open) by matching signals to closing sells
- Derived patterns (win rate if 3+ closed trades exist)
- Falls back to empty if no userId or no Supabase configured
- Function is now `async` — `buildEnrichedPrompt()` updated to `async` accordingly

### 7. End-of-day summary

- `lib/eod-summary.ts` — `buildEODSummary()` aggregates daily activity from Supabase
  - Trades executed (buys/sells), signals generated/acted on/skipped
  - Realized P&L, risk budget usage
  - Top win and top loss trades
  - `formatEODSummary()` for text output
- `app/api/wingman/summary/route.ts` — `POST` endpoint accepting `userId` and optional `date`
- Portfolio page has "Today's Summary" button showing the EOD card

### 8. Portfolio page reads from Supabase

`app/portfolio/page.tsx` updated:
- Uses `useUser()` hook and `getPortfolioFromDb()` for Supabase mode
- Signal log reads from `signals` table instead of localStorage wingman sessions
- EOD summary integration (button + card display)
- Falls back to localStorage when Supabase is not configured

### 9. Tab favicon and site logo updated

- `app/icon.svg` — new YFYT brand mark (chart line with green dot, dark background)
- Sidebar logo replaced: chart-line SVG + "YFYT / Wingman" text (was generic Zap icon)
- Landing page logo updated to match

---

## Current architecture

```
app/
  page.tsx              — landing / welcome
  layout.tsx            — root layout (ThemeProvider + UserProvider + UserPicker + DevTools)
  wingman/page.tsx      — main trading view (Supabase-backed)
  screener/page.tsx     — morning screener UI (NEW)
  portfolio/page.tsx    — portfolio + signals + EOD summary (Supabase-backed)
  dashboard/page.tsx    — overview dashboard
  trade/page.tsx        — manual trade entry
  mentor/page.tsx       — learning sessions
  api/
    wingman/
      signal/route.ts   — Claude signal generation with enriched prompt
      chat/route.ts     — follow-up chat about signals
      screener/route.ts — two-pass screener (code + Claude ranking)
      summary/route.ts  — end-of-day summary (NEW)
    dev/
      reset/route.ts    — dev-only DB clearing (NEW)

lib/
  supabase.ts           — browser + server Supabase clients (NEW)
  supabase-storage.ts   — Supabase-backed portfolio/trade/signal operations (NEW)
  user-context.tsx      — cookie-based user session (NEW)
  eod-summary.ts        — end-of-day summary builder (NEW)
  screener.ts           — Pass 1 code filters, 51-ticker universe
  screener-ranking.ts   — Pass 2 Claude ranking (NOW LIVE)
  prompt-builder.ts     — enriched prompt Layers 3-5 (Layer 5 now Supabase-backed)
  signal-schema.ts      — risk engine, system prompt, Zod schema
  market-data.ts        — Alpha Vantage market data
  mock-market.ts        — 51-ticker stub data (was 10)
  storage.ts            — localStorage fallback

components/
  UserPicker.tsx        — user selector modal (NEW)
  DevTools.tsx          — dev-only DB management panel (NEW)
  wingman/
    SignalCard.tsx       — signal display + trade button
    CandleChart.tsx     — candlestick chart
    RiskDashboard.tsx   — risk enforcement stats
    MarketClock.tsx     — market hours / countdown

supabase/
  migrations/
    001_initial_schema.sql — full schema + seed data
```

---

## What's still mocked / stubbed

1. **Market data** — `generateStubSnapshot()` produces fake candle data. Real data needs Alpaca API
2. **Layer 3 stubs** — SPY/QQQ/VIX snapshots, earnings proximity, news headlines are hardcoded
3. **Live prices** — `getLivePrice()` adds ±1% jitter to static mock prices
4. **CandleChart** — renders mock candles, not real data from signal API

---

## External dependencies remaining

| What | Status | Blocks |
|------|--------|--------|
| Anthropic API key | SET | Nothing — fully wired |
| Supabase | SET | Nothing — fully wired |
| Alpha Vantage | SET | Not yet used for real-time data |
| Alpaca | NOT SET | Live prices, real candle data, paper trade execution |

Alpaca is the **only** missing external dependency. Anti said to delay it.

---

## Next session tasks

### No dependencies (can build now):
1. Wire CandleChart to real candle data from signal API response
2. Dashboard page — update to use Supabase (currently still localStorage)
3. Monitoring loop skeleton — 15-min price checks (Anti wants to discuss timing strategy first)
4. Trade page — update to use Supabase

### Blocked on Alpaca:
5. Replace stub snapshots with real market data
6. Wire Layer 3 to real SPY/QQQ/VIX
7. Live price feeds for positions
8. Paper trade execution via Alpaca

### Research / discussion items:
9. Deeper research on screener filter thresholds and prompt builder numbers (saved in memory)
10. Monitoring loop timing strategy (Anti wants to discuss in detail)

---

## Key design principles (from Anti)

- **Never compromise on accuracy** — expand the search pool, don't lower the bar
- **Dynamic position sizing** — calculate off current equity, not starting capital
- **Cost-conscious** — pre-signal gates save API cost by blocking before Claude call
- **Extensible auth** — seed users + cookies now, add real auth later without schema changes
- **Always use claude-opus-4-6** — never default to Sonnet
