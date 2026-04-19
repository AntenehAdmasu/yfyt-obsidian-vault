# YFYT — Session Context Document
**Date:** April 15, 2026  
**Purpose:** Handover context for new Claude Code session when context limit hits.  
**Pass this file to the next session and say:** *"Read this file first. It is your full context for the YFYT project."*

**Prior context:** `contexts/context-april-14-2026.md` — read that first for original spec and product pivot history.

---

## Who Anti is

Two builders behind the keyboard:

- **Anti** — FAANG software engineer, London (GMT/BST). PM/founder mode — directs AI agents to build. Uses Claude Code in VS Code. Has a second Claude instance in the Claude.ai desktop app for product thinking (referred to as "your friend"). When Anti pastes decisions or docs and says they're "from your friend", apply them directly.
- **Elsh** — Software engineer, New York (EST, 5 hours behind London). Co-building YFYT with Anti as of April 2026. Either person may be driving a Claude Code session.

---

## What happened in the April 15 session

### 1. Co-Pilot mode became "Wingman" — built and polished

The Co-Pilot concept from April 14 was fully designed and built as **Wingman** — an AI trading co-pilot that analyses a ticker/timeframe, generates a structured signal with full reasoning, and answers follow-up questions via chat. Everything runs on mock data for now.

### 2. Product & Architecture document created

A 44K-word PM × Senior Architect working session document was written and rendered:
- `brainstorming/product-architecture-v1.md` — full markdown source
- `brainstorming/product-architecture-v1.pdf` — rendered PDF (xelatex, Helvetica Neue, A4)
- `brainstorming/product-architecture-slides.html` — 22-slide reveal.js deck in YFYT gold/dark theme

### 3. UI fixes (two rounds)

**Round 1:**
- Sidebar contrast fixed — was using `bg-background` (resolves to near-white in light mode); replaced with explicit `#0f0f0f`
- Font loading fixed — `globals.css` had `--font-sans: var(--font-sans)` (circular reference → no font); fixed to `--font-sans: var(--font-geist-sans)`

**Round 2 (chart proportions + fonts):**
- Chart was `flex-1` filling 85%+ of viewport height → capped at `min(calc(100vh - 290px), 500px)`
- Stats strip below chart: padding, font size, and border opacity all increased
- Sidebar nav: 13px → 14px; wordmark label 9px → 10px
- SignalCard LevelBox label: 10px → 11px, value: text-base → 15px

**Round 3 (collapsible sidebar + right panel):**
- Sidebar is now collapsible: 200px ↔ 64px icon-only, state in `localStorage['sidebar-collapsed']`
- 220ms CSS transition, hydration-safe (`mounted` flag prevents SSR/client flash)
- Right panel: 420px → 460px wide
- All body text in signal card and chat: text-sm (14px) → text-[15px]

---

## Current codebase state

**Repository:** https://github.com/AntenehAdmasu/yfyt.git  
**Branch:** main  
**Dev server:** `npm run dev` (port 3000 or 3002)

### What's built

| File/Folder | Purpose |
|---|---|
| `app/page.tsx` | Welcome / name entry screen, localStorage onboarding |
| `app/dashboard/page.tsx` | Portfolio summary, session stats, CTA to Wingman |
| `app/wingman/page.tsx` | **Main page** — ticker selector, timeframe pills, CandleChart, SignalCard, chat input/bubbles, stats strip |
| `app/portfolio/page.tsx` | Open positions, P&L, equity chart, trade history |
| `app/trade/page.tsx` | Manual buy/sell form (to be killed before beta — redundant without Wingman) |
| `components/layout/Sidebar.tsx` | Collapsible sidebar: 200px expanded / 64px icon-only. Toggle at footer. localStorage persisted. |
| `components/layout/BottomNav.tsx` | Mobile bottom nav |
| `components/wingman/SignalCard.tsx` | BUY/SELL/WAIT signal card: level grid, position info row, reasoning list, concepts accordion, trade button |
| `components/wingman/CandleChart.tsx` | lightweight-charts v5 candlestick chart with Entry/Stop/Target price lines drawn on signal |
| `lib/storage.ts` | All localStorage CRUD — user, portfolio, trades, wingman sessions |
| `lib/mock-market.ts` | 10 hardcoded tickers (AAPL, TSLA, NVDA, MSFT, GOOGL, AMZN, VOO, SPY, QQQ, META) |
| `lib/mock-signals.ts` | `generateSignal()` — mocked BUY/SELL/WAIT signals. `getMockWingmanReply()` — pattern-matched chat responses |
| `lib/utils.ts` | shadcn `cn()` utility |
| `types/index.ts` | Shared TypeScript types |
| `brainstorming/product-architecture-v1.pdf` | Full PM×Architect architecture document |
| `brainstorming/product-architecture-slides.html` | 22-slide reveal.js deck |

### Tech stack
- **Framework:** Next.js 16 App Router + TypeScript (strict)
- **Styling:** Tailwind CSS v4 + shadcn/ui v4 (`@base-ui/react` — `Button` does NOT support `asChild`, use `buttonVariants` on `<Link>`)
- **Charts:** lightweight-charts v5 (TradingView) — `chart.addSeries(CandlestickSeries, opts)` API
- **State/Persistence:** localStorage only (no Supabase yet)
- **AI:** Fully mocked (no Anthropic API key wired)
- **Market data:** Fully mocked (10 static tickers, hardcoded prices)
- **Hosting:** Not deployed yet (local only)

### Design system (locked in)
- **Background:** `#0d0d0d` page, `#0f0f0f` sidebar, `#0a0a0a` chart
- **Gold accent:** `#C9A84C` — used for Wingman nav highlight, signal price lines, active states
- **Font:** Geist (loaded via `next/font/google` in layout.tsx as `--font-geist-sans`)
- **Sidebar:** Always dark — uses explicit hex values, NOT CSS theme variables (theme vars resolve to light mode without `.dark` class on `<html>`)
- **Right panel:** 460px fixed width, body text at 15px

---

## Architecture decisions (from product-architecture-v1.pdf)

These are locked decisions for Phase 1+. Don't deviate without reason.

| Decision | Choice | Why |
|---|---|---|
| Market data | Alpaca Markets (US primary) + Alpha Vantage (UK/LSE) | Free real-time WebSocket; paper trading API included |
| AI — signals + chat + post-mortems | Claude Opus 4.6 | Best available model for all interactions — always upgrade to latest |
| Database | Supabase (Postgres + RLS + Realtime + Auth) | One service for everything; generous free tier |
| Auth | Supabase magic link + Google OAuth | No passwords to manage |
| Rate limiting | Upstash Redis (serverless) | Per-user limits: 20 signals/day, 50 chat messages/signal session |
| Hosting | Vercel | Already targeted; Edge network; preview URLs per PR |
| Signal prompt | Numerical context (EMAs, swing highs/lows, volume) NOT image-only | 4x cheaper per call; more precise; image upload is enhancement path |
| AI output validation | Zod schema on all Claude output | Prevent silent bad data reaching the UI |
| Streaming | Mandatory for chat | First token <400ms vs 1-3s blocking — makes product feel professional |

### Pricing tiers
- **Free:** 3 signals/day, 5 chat messages/signal, 30-day history
- **Pro:** £12/mo — unlimited signals + chat, post-mortems, Replay Room, watchlist
- **Pro + Live:** £25/mo — everything + live broker (Phase 3)

### Unit economics at 1,000 paying users
- AI cost: ~$1/active user/month (10% of Pro revenue)
- Target MRR: £15,900 (~£190k ARR)
- Contribution margin: ~90%

---

## Phase 1 — what to build next (4–6 weeks)

This is the current task. Turns mock product into a real launchable MVP for 100 beta users.

| Task | Detail |
|---|---|
| Replace mock signals with Claude API | Anthropic SDK; structured numerical prompt with computed EMAs/swing points/volume; Zod validation on output |
| Replace mock prices with Alpaca API | Real-time US equity WebSocket; 15-min delayed fallback |
| Supabase auth + database | Email magic link auth; migrate localStorage schema to Postgres with RLS |
| Streaming chat responses | Replace mock delay with Claude SDK streaming (SSE) |
| Onboarding flow (5 questions) | Style, time horizon, risk, knowledge, goal → stored in DB → injected into prompt context |
| Signal outcome tracking | Background job (Supabase Edge Function / pg_cron) checks if SL or TP was hit; updates `wingman_signals.outcome` |
| Paper trading realism | 0.15% simulated slippage; market hours enforcement (no fills 4pm–9:30am EST) |
| Core disclaimers | "Paper only · Educational · Not financial advice" on every signal |

### DB schema (target for Phase 1)
```sql
users (id, email, name, onboarding jsonb, created_at)
portfolios (id, user_id, cash_balance default 10000, updated_at)
positions (id, portfolio_id, ticker, quantity, avg_buy_price, opened_at)
trades (id, portfolio_id, ticker, action, quantity, price, reason, executed_at)
wingman_signals (id, user_id, ticker, timeframe, action, confidence, entry, stop_loss,
  take_profit, risk_reward, position_size_pct, summary, reasoning jsonb,
  concepts_explained jsonb, traded bool, trade_id, outcome, outcome_price,
  outcome_pnl_pct, generated_at, closed_at)
chat_messages (id, signal_id, user_id, role, content, created_at)
```

### API routes (target for Phase 1)
```
/api/signal    POST — generate Wingman signal (Claude Opus 4.6)
/api/chat      POST — streaming chat reply (Claude Opus 4.6, SSE)
/api/trade     POST — execute paper trade
/api/quote     GET  — current price for ticker (Alpaca)
```

---

## Key constraints (never forget)

- All API keys server-side only — `ANTHROPIC_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `ALPACA_API_KEY` never reach the client
- Paper trading only through Phase 2 — no FCA/SEC registration needed
- Every AI output must append "This is educational content, not financial advice"
- `Button asChild` does NOT work in this shadcn version — use `buttonVariants` on `<Link>`
- Sidebar must use explicit hex dark values, not CSS theme variables
- Kill Manual Trade page before beta — it's redundant without Wingman guidance

---

## What to do next session

1. Begin Phase 1 — wire up real Claude API for signal generation
2. Wire up Alpaca Markets for real-time prices
3. Set up Supabase project + auth + DB schema
4. Replace mock streaming in chat with Claude SDK streaming
5. Anti needs to provide: `ANTHROPIC_API_KEY`, Alpaca API credentials, Supabase project URL + anon key

---

## April 16 addendum — strategy session

A deep brainstorm session happened on April 16 that shifts some decisions and adds structure. Treat these as authoritative over anything earlier in this doc.

### Model decision locked

**Always use `claude-opus-4-6` for everything** — signals, chat, post-mortems. Never default to Sonnet. Anti specifically subscribed to Opus for this project and will upgrade to the best available model as new versions launch. All docs, slides, and code references updated accordingly. (See memory file `feedback_model_choice.md`.)

### Build rhythm locked

**15 hours/week** — 5 hours across weekdays (1h/day) + 10 hours on weekends. Total project timeline at this rhythm: ~13 weeks (~3 months) from zero to Phase 4 complete.

### Scope expansion — 4 phases (supersedes "Phase 1" framing above)

The single "Phase 1" in the earlier section of this doc is now just the first of four phases. Full breakdown lives in `plan/build-plan-overview.html`.

| Phase | What | Approx weeks @ 15h/wk |
|---|---|---|
| Phase 1 | Foundation — real Opus signals, Alpaca, Supabase, paper sim, risk engine | ~3 weeks |
| Phase 2 | Context & Intelligence — screener, multi-TF, news, Reddit, FinBERT, RAG | ~4 weeks |
| Phase 3 | Autonomous Agent — 24/7 WhatsApp agent on Railway, two-way Claude dialogue | ~3 weeks |
| Phase 4 | Learning System — backtester, trade journal, behaviour pattern detection | ~3 weeks |

### New components added to the scope (not in April 15 version)

- **Nightly screener** — S&P 500 + FTSE 100 filtered to 15–30 daily candidates (replaces any fixed watchlist)
- **Multi-timeframe top-down** — 1D → 4H → 1H → 15M confluence required for signal
- **News + Reddit context** — Alpha Vantage news + Reddit API aggregated before Claude prompt
- **FinBERT pre-processing** — numeric sentiment score passed to Claude, not raw headlines
- **RAG knowledge base** — Supabase pgvector with embeddings from trading books (Murphy, Douglas, ICT transcripts)
- **WhatsApp agent on Railway** (~£5/mo) — Vercel serverless can't host long-running scanners
- **Risk engine** — hardcoded: 2% per trade, max 3 positions, 5% daily loss kill switch, no same-sector concurrency
- **Backtester** — replays historical Alpaca data against signal logic
- **Claude trade post-mortems** — one-paragraph reflection after each closed trade; behaviour patterns surface over time

### New docs produced on April 16

- `brainstorming/wingman-build-strategy.html` — full end-to-end strategy document (print-to-PDF ready)
- `plan/build-plan-overview.html` — 4-phase roadmap slide deck with ground rules and decision gates
- `plan/parking-lot.md` — placeholder for out-of-scope temptations that arise mid-phase
- Memory: `feedback_model_choice.md` — Opus-only directive
- Memory: `feedback_readme.md` — always update README when new service integrated

### Discipline contract (Anti's own words)

> "I don't trust myself in patiently building one by one. I get excited and jump here and there."

The `plan/` deck exists to prevent this. Ground rules: finish each phase before starting the next, no parallel phases, use Wingman for 2 weeks between phases, commit after every working feature, and all out-of-scope ideas go into `plan/parking-lot.md` — never lost, never allowed to derail the current phase.

### Cost reality check (personal use, just Anti)

Everything is on free tiers except Claude API. Opus at ~2 signals/day + ~10 chats/day = **~£10–15/month**. Supabase, Alpaca (IEX), Vercel Hobby, Upstash Redis: all £0 at this scale. Railway server comes in at Phase 3 for ~£5/month.

### Regulatory note

Public launch is firmly a **Phase 5+** concern. FCA authorisation and financial promotion rules apply the moment signals go out to anyone other than Anti. Treat "launch" as a completely separate legal/compliance workstream, not a build task.
