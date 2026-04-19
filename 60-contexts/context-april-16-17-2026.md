# YFYT — Session Context Document
**Date:** April 16–17, 2026  
**Purpose:** Handover context for new Claude Code session when context limit hits.  
**Pass this file to the next session and say:** *"Read this file first. It is your full context for the YFYT project."*

**Prior context:** `contexts/context-april-15-2026.md` — read that first for full April 14–15 history. This document covers decisions and changes made on April 16–17.

---

## Who is building this

Two builders behind the keyboard:

- **Anti** — FAANG software engineer, London (GMT/BST). PM/founder mode — directs AI agents to build, does not write code directly. Uses Claude Code in VS Code with Claude Opus 4.6.
- **Elsh** — Anti's girlfriend. Software engineer, New York (EST, 5 hours behind London). Co-building YFYT as of April 2026. Either person may be driving a Claude Code session.

---

## Key decisions made April 16–17

### 1. Model locked to Claude Opus 4.6

All AI interactions in YFYT must use `claude-opus-4-6` — signals, chat, post-mortems, everything. Never default to Sonnet. Anti specifically subscribes to Opus for this project and will upgrade to the best available model as new versions launch.

**Updated across:** README.md, slides, product specs (docs/ and about/), context file, memory.

### 2. Elsh joins the project

Updated all product specs and memory to reflect two builders. Estimates will be revised once they work out the hour split.

### 3. Build rhythm locked: 15 hours/week

5 hours across weekdays (1h/day) + 10 hours on weekends. Timeline: ~13 weeks (~3 months) from zero to Phase 4 complete.

### 4. Four-phase roadmap formalised

The single "Phase 1" from April 15 is now one of four sequential phases. **Each phase has a decision gate — must pass before starting the next.**

| Phase | What | Weeks @ 15h/wk | Gate |
|---|---|---|---|
| Phase 1 | Foundation — real Opus signals, Alpaca, Supabase, paper sim, risk engine | ~3 | Run signal → take trade → see outcome tracked. 10 times, zero manual intervention |
| Phase 2 | Context & Intelligence — screener, multi-TF, news, Reddit, FinBERT, RAG | ~4 | Signal reasoning references specific news, sentiment, and methodology — not just indicators |
| Phase 3 | Autonomous Agent — WhatsApp alerts on Railway, two-way Claude dialogue | ~3 | WhatsApp alert arrives when away from laptop, reply with question, Claude answers in-thread |
| Phase 4 | Learning System — backtester, journal, behaviour pattern detection | ~3 | Wingman surfaces a behavioural pattern about your trading that you didn't know — and is right |

### 5. Full UI redesign with dark/light theme support

Complete visual overhaul of all 5 pages. See details below.

---

## What was built April 16–17

### New documents & plan directory

| File | Purpose |
|---|---|
| `brainstorming/wingman-build-strategy.html` | End-to-end strategy document — screener, context layer, WhatsApp agent, RAG, risk engine, backtester, journal. Print-to-PDF ready (Cmd+P in Chrome → Save as PDF) |
| `plan/build-plan-overview.html` | 10-slide Reveal.js deck — 4-phase roadmap with ground rules, decision gates, anti-temptation section, timeline at 15h/week |
| `plan/parking-lot.md` | Holding area for out-of-scope ideas that arise mid-phase — prevents scope creep |

### Full UI redesign

**Theme system installed:**
- `next-themes` package added for dark/light mode switching
- `components/ThemeProvider.tsx` created — wraps the app, defaults to dark theme
- `app/layout.tsx` updated — `suppressHydrationWarning` on `<html>`, ThemeProvider wrapper

**globals.css completely rewritten:**
- Proper light theme (white backgrounds, warm gold accents, warm grey borders)
- Proper dark theme (#09090b background, refined gold, rgba borders)
- Surface token system: `--surface-0` through `--surface-3` for layered backgrounds
- Semantic color tokens: `--success`, `--danger`, `--warning` + muted variants
- Elevation system: `.elevation-1/2/3` that adapts per theme (subtle in light, deeper in dark)
- Smooth 200ms color transitions on theme switch
- Radius tightened to `0.625rem` (from `0.75rem`)
- Custom CSS utilities: `.bg-surface-0/1/2/3`, `.border-surface`, `.text-gold`, `.bg-gold`

**Sidebar.tsx rewritten:**
- Fully theme-aware — uses `bg-sidebar`, `text-sidebar-foreground`, `border-sidebar-border` tokens
- Added **theme toggle button** (Sun/Moon icon) in footer, between disclaimer and Reset
- All hover states use Tailwind `hover:bg-sidebar-accent` instead of inline JS `onMouseEnter/onMouseLeave`
- Width: 64px collapsed / 220px expanded (was 200px)
- Cleaner typography: `text-[13px]` nav items, `text-lg` wordmark

**BottomNav.tsx rewritten:**
- Uses theme tokens: `bg-surface-0`, `border-surface`, `text-primary`
- Elevation on Wingman floating pill

**All 5 pages rewritten to be theme-aware:**

1. **app/page.tsx (Landing)**
   - Icon-based feature list (BarChart3, BookOpen, Shield) instead of gold dots
   - Proper focus ring on input: `ring-2 ring-primary/20` + `border-primary`
   - Uses `bg-background`, `text-foreground`, `bg-surface-1`, `border-border`
   - Local `cn()` helper (doesn't import from lib/utils, avoids dependency)

2. **app/wingman/page.tsx (Wingman — core page)**
   - All hardcoded `#0d0d0d`, `rgba(255,255,255,0.x)` replaced with theme tokens
   - Search dropdown: `bg-card`, `elevation-3`, `border-border`
   - Timeframe pills: `bg-muted`, active `bg-primary text-primary-foreground`
   - Chat bubbles: user = `bg-primary text-primary-foreground`, AI = `bg-surface-2 text-foreground/80`
   - Stats strip: `bg-surface-1`, `border-border`
   - Status messages use `var(--success-muted)` / `var(--danger-muted)` backgrounds
   - Spinner uses `border-primary/20` + `borderTopColor: var(--primary)`

3. **app/dashboard/page.tsx**
   - Wingman CTA card: `bg-primary text-primary-foreground` with `elevation-2`
   - "Open Wingman" button: `bg-background text-foreground` (inverted from card)
   - Portfolio card: `bg-card border-border`
   - Signal badges: semantic `bg-[var(--success-muted)]` etc.
   - `max-w-2xl` content area

4. **app/portfolio/page.tsx**
   - Equity chart: stroke and gradient use `var(--primary)` — adapts to theme
   - XAxis/YAxis tick fill: `var(--muted-foreground)` — readable in both themes
   - All cards: `bg-card border-border`, consistent `rounded-xl`
   - P&L colors: `text-[var(--success)]` / `text-[var(--danger)]`

5. **app/trade/page.tsx**
   - Cash bar: `bg-surface-1 border-border`
   - Buy/Sell toggle: `bg-foreground text-background` when active
   - Order summary: `bg-surface-1`
   - Success/error alerts: semantic muted backgrounds
   - Links updated from `/mentor` to `/wingman`

**SignalCard.tsx rewritten:**
- Action header: semantic `bg-[var(--success-muted)]` / `danger-muted` / `warning-muted`
- Level grid: uses `variant` prop (`gold` / `danger` / `success`) mapped to CSS vars
- Position info row: `bg-surface-1 border-border`
- Reasoning numbers: `bg-primary/15 text-primary`
- Concepts accordion: `bg-surface-1 border-border` when expanded
- Execute button: `elevation-2` shadow
- All inline `rgba(255,255,255,0.x)` eliminated

---

## Current codebase state

**Repository:** https://github.com/AntenehAdmasu/yfyt.git  
**Branch:** main  
**Dev server:** `npm run dev` (port 3000)

### What's built (full file table)

| File/Folder | Purpose |
|---|---|
| `app/page.tsx` | Landing — name entry, icon features, theme-aware |
| `app/layout.tsx` | Root layout with ThemeProvider + Geist fonts |
| `app/globals.css` | Full light/dark theme with surface tokens, elevations, semantic colors |
| `app/wingman/page.tsx` | Core page — chart + signal panel + chat, fully theme-aware |
| `app/dashboard/page.tsx` | Overview — greeting, Wingman CTA, portfolio summary, stats, signals |
| `app/portfolio/page.tsx` | Portfolio — equity chart (recharts), positions, signal log, trade history |
| `app/trade/page.tsx` | Manual trade form — search, buy/sell toggle, order summary |
| `components/ThemeProvider.tsx` | `next-themes` wrapper, defaults dark |
| `components/layout/Sidebar.tsx` | Collapsible sidebar with theme toggle (Sun/Moon) |
| `components/layout/BottomNav.tsx` | Mobile bottom nav, theme-aware |
| `components/wingman/SignalCard.tsx` | BUY/SELL/WAIT card, fully theme-aware |
| `components/wingman/CandleChart.tsx` | lightweight-charts v5 candlestick (still uses dark hardcoded — chart library limitation) |
| `components/ui/button.tsx` | shadcn Button with CVA variants |
| `components/ui/card.tsx` | shadcn Card |
| `components/ui/badge.tsx` | shadcn Badge |
| `components/ui/input.tsx` | shadcn Input |
| `components/ui/textarea.tsx` | shadcn Textarea |
| `components/ui/separator.tsx` | shadcn Separator |
| `components/ui/avatar.tsx` | shadcn Avatar |
| `lib/storage.ts` | All localStorage CRUD |
| `lib/mock-signals.ts` | Mock signal generation + chat responses |
| `lib/mock-market.ts` | 10 hardcoded tickers with jitter prices |
| `lib/utils.ts` | shadcn `cn()` utility |
| `types/index.ts` | Shared TypeScript types |
| `brainstorming/product-architecture-v1.md` | Full PM×Architect doc (source) |
| `brainstorming/product-architecture-v1.pdf` | Rendered PDF |
| `brainstorming/product-architecture-slides.html` | 22-slide Reveal.js deck |
| `brainstorming/wingman-build-strategy.html` | End-to-end strategy doc (print-to-PDF) |
| `plan/build-plan-overview.html` | 4-phase roadmap deck |
| `plan/parking-lot.md` | Out-of-scope ideas holding area |
| `contexts/context-april-14-2026.md` | Session 1 context |
| `contexts/context-april-15-2026.md` | Session 2 context (+ April 16 addendum) |
| `contexts/context-april-16-17-2026.md` | This file |

### Tech stack

- **Framework:** Next.js 16.2.3 App Router + TypeScript 5.9.3
- **Styling:** Tailwind CSS v4 + shadcn/ui v4 + `next-themes` for dark/light
- **Charts:** lightweight-charts v5 (TradingView) + recharts (equity curves)
- **Icons:** lucide-react
- **State/Persistence:** localStorage only (no Supabase yet)
- **AI:** Fully mocked (Claude Opus 4.6 target — `claude-opus-4-6`)
- **Market data:** Fully mocked (10 static tickers)
- **Hosting:** Not deployed yet

### Design system (current)

**Light theme:**
- Background: `#ffffff`, Card: `#ffffff`, Surface-1: `#fafaf8`, Surface-2: `#f5f3ee`
- Primary (gold): `#C9A84C`
- Borders: `#e8e5de`
- Text: `#111111`, Muted: `#71717a`
- Success: `#16a34a`, Danger: `#dc2626`, Warning: `#d97706`

**Dark theme:**
- Background: `#09090b`, Card: `#111113`, Surface-1: `#111113`, Surface-2: `#18181c`
- Primary (gold): `#C9A84C`
- Borders: `rgba(255,255,255,0.08)`
- Text: `#f0ede8`, Muted: `#71717a`
- Success: `#22c55e`, Danger: `#ef4444`, Warning: `#f59e0b`

**Font:** Geist (sans) + Geist Mono — loaded via `next/font/google`
**Radius:** `0.625rem` base
**Theme toggle:** Sun/Moon button in sidebar footer

---

## Architecture decisions (locked)

| Decision | Choice | Why |
|---|---|---|
| AI model | Claude Opus 4.6 (`claude-opus-4-6`) | Best available. Always upgrade. Never default to Sonnet |
| Market data | Alpaca Markets (US primary) + Alpha Vantage (UK/LSE) | Free real-time WebSocket; paper trading API included |
| Database | Supabase (Postgres + RLS + Realtime + Auth) | One service for everything; generous free tier |
| Auth | Supabase magic link + Google OAuth | No passwords to manage |
| Rate limiting | Upstash Redis (serverless) | Per-user limits |
| Hosting | Vercel | Edge network, preview URLs |
| Theme | `next-themes` with `attribute="class"` | Supports dark/light with Tailwind `dark:` variant |
| Signal prompt | Numerical context (not image) | 4x cheaper, more precise |
| AI output validation | Zod schema on Claude output | Prevent bad data reaching UI |
| Streaming | Mandatory for chat | First token <400ms |

---

## Cost for personal use (just Anti + Elsh)

| Service | Monthly cost |
|---|---|
| Claude Opus 4.6 API | ~£10–15 |
| Supabase | Free tier |
| Alpaca Markets (IEX) | Free |
| Vercel Hobby | Free |
| Upstash Redis | Free |
| Railway (Phase 3, WhatsApp agent) | ~£5 |
| **Total** | **~£10–20/month** |

---

## Known issue to fix next session

**Non-Wingman pages have too much empty space on the right.** Dashboard, Portfolio, and Trade pages are capped at `max-w-2xl` (672px) and left-aligned within the full viewport. Two options:
1. Fill the right side with a contextual panel (quick stats, tips, recent signals sidebar)
2. Center the content and let it breathe with wider max-width

Anti's feedback: "that gigantic space left on the right side on the non wingman pages. feels off."

---

## What to do next session

1. **Fix the right-side empty space** on non-Wingman pages (dashboard, portfolio, trade)
2. **Begin Phase 1** — wire up real Claude Opus 4.6 API for signal generation
3. Wire up Alpaca Markets for real-time prices
4. Set up Supabase project + auth + DB schema
5. Anti/Elsh need to provide: `ANTHROPIC_API_KEY`, Alpaca API credentials, Supabase project URL + anon key

---

## Ground rules (from the build plan)

1. Finish each phase before the next — no "80% done" skipping
2. No parallel phases
3. Use Wingman for 2 weeks between phases before adding the next layer
4. Commit after every working feature
5. Out-of-scope ideas → `plan/parking-lot.md`
