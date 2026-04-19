# YFYT — Session Context Document
**Date:** April 14, 2026  
**Purpose:** Handover context for new Claude Code session when context limit hits.  
**Pass this file to the next session and say:** *"Read this file first. It is your full context for the YFYT project."*

---

## Who Anti is

FAANG software engineer, London. PM/founder mode — directs AI agents to build, does not write code himself. Uses Claude Code in VS Code. Has a second Claude instance in the Claude.ai desktop app used for product thinking and architecture (referred to as "your friend"). When Anti pastes decisions or docs and says they're "from your friend", apply them directly.

Target users: Anti and his partner, complete trading beginners. Every design decision validated against their experience. Mobile-first.

---

## What YFYT is (original spec)

A **Socratic AI mentor** for complete trading beginners. Core thesis: passive content (YouTube, courses) doesn't build trading instinct. YFYT fixes this by making the AI ask "what would you do?" before explaining, coupled with paper trading so every lesson is immediately actionable.

**Pitch:** *"The AI mentor that teaches you to think like a trader, not just copy one."*

**What it is NOT (original spec):**
- Not a trading signal/bot — never tells users what to trade
- Not a broker — no real money
- Not a passive course — no lectures or slide decks
- Not social/copy trading — individual journey

---

## Major product pivot discussed (end of session)

Anti raised a structural change at the end of the session. The project is evolving from pure education to include a **Co-Trading / Co-Pilot mode**. See section below for full detail.

---

## Current codebase state

**Repository:** https://github.com/AntenehAdmasu/yfyt.git  
**Branch:** main  
**Last commit:** "initial scaffold: Next.js + auth shell"  
**Dev server:** `npm run dev` (runs on port 3000, or 3002 if 3000 is taken)

### What's built

| File/Folder | Purpose |
|---|---|
| `app/page.tsx` | Welcome screen — name entry, localStorage onboarding |
| `app/dashboard/page.tsx` | Portfolio summary, session stats, CTA to mentor |
| `app/mentor/page.tsx` | Socratic chat UI with mocked streaming responses |
| `app/portfolio/page.tsx` | Open positions, P&L, equity chart, trade history |
| `app/trade/page.tsx` | Buy/sell form with required reason field, ticker search |
| `lib/storage.ts` | All localStorage CRUD — user, sessions, portfolio, trades |
| `lib/mock-market.ts` | 10 hardcoded tickers (AAPL, TSLA, NVDA, VOO, etc.) |
| `lib/mock-mentor.ts` | Mocked Socratic responses keyed to ~15 beginner topics |
| `lib/utils.ts` | shadcn cn() utility |
| `types/index.ts` | Shared TypeScript types |
| `components/layout/Sidebar.tsx` | Desktop sidebar nav (black + gold Material theme) |
| `components/layout/BottomNav.tsx` | Mobile bottom nav |
| `components/ui/` | shadcn/ui components (button, card, input, textarea, badge, avatar, separator) |

### Tech stack
- **Framework:** Next.js 16 App Router + TypeScript (strict)
- **Styling:** Tailwind CSS v4 + shadcn/ui (using `@base-ui/react` — NOTE: Button does NOT support `asChild`. Use `buttonVariants` on `<Link>` instead)
- **State/Persistence:** localStorage (no Supabase yet — deferred)
- **AI:** Mocked (no Anthropic API key wired yet)
- **Market data:** Mocked (10 static tickers)
- **Hosting:** Not deployed yet (local only)

### Important shadcn note
This project uses **shadcn v4 with `@base-ui/react`**. The `Button` component does NOT support the `asChild` prop. To make a Link look like a button, use:
```tsx
import { buttonVariants } from '@/components/ui/button'
<Link href="/x" className={cn(buttonVariants({ variant: 'outline', size: 'sm' }), 'extra-classes')}>
  Label
</Link>
```

### Design theme (applied end of session, partially)
- **Primary colours:** Deep black + gold (`oklch(0.72 0.13 78)` ≈ `#C9A84C`)
- **Style:** Material Design — elevation shadows, proportional sizing, clean typography
- **Sidebar:** Black background, gold active nav items
- Theme is set in `app/globals.css` CSS variables
- Some pages may still need visual polish pass

---

## The Co-Trading / Co-Pilot Mode (new direction, discussed at session end)

### What Anti proposed
Anti realised he doesn't have time in the next 6 months to go through a full learning curriculum and become a proficient trader. His alternative: use Claude as a **live co-trader / big brother** that:

- Analyses live charts
- Makes explicit decisions: buy/sell/ratio/stop-loss/limit/take-profit
- Explains the *why* in plain English as it goes ("buy this because X — btw that's called a fair value gap")
- Teaches by association *while* trading, not before
- May track Claude models that are autonomously trading

**His framing:** *"A hands-on mentor like a big brother that will say buy this because, sell this because, btw fair value gap is..."*

**His goal:** Use Claude's analytical brain to actually make money while learning by doing rather than learning before doing.

### Claude's assessment of the idea (given at session end — not yet built)

**What's compelling:**
1. Learning by association during live trading is genuinely how many professionals learn (apprenticeship model)
2. The transparency layer ("here's the decision AND the reasoning") is differentiating — most signal tools give signals without teaching
3. Solving a real personal constraint (no time for structured learning)
4. The "big brother" framing is emotionally resonant and distinct from cold algo trading
5. Both modes (Learning + Co-Pilot) can coexist and serve different user states

**What needs honest discussion:**
1. **UK FCA regulatory issue** — the original spec was built explicitly around NOT giving investment advice because personalised financial advice requires FCA authorisation. Co-Pilot mode giving buy/sell/ratio/stop-loss recommendations IS personalised investment advice under UK law. If this is purely personal use, that's fine. If it becomes a product for others, it needs legal review.
2. **Claude doesn't have real-time data** — Claude has no internet access. It cannot see live charts unless you feed it the data (via screenshot + vision API, or structured price data via an API route). The architecture needs to account for this.
3. **Claude is not a trading model** — Its financial knowledge is broad but not optimised for trading decisions. Results may be poor. Anti should validate with paper trading before using real money.
4. **Liability** — If this is used for real money and loses, the product is causally involved.

**Recommended architecture for Co-Pilot mode:**
- Feed Claude chart data via screenshot (vision) or structured OHLCV data
- New system prompt: "You are a trading co-pilot. You make explicit decisions and explain your reasoning. You are not a regulated advisor and this is for personal educational use only."
- New UI: Chart display + Claude analysis panel side by side
- Start with paper trading for Co-Pilot too — validate signal quality before real money
- Separate the two modes clearly in UI: "Learn" vs "Trade"

### What needs to be built / changed for Co-Pilot mode
- New mode selector (Learn / Co-Pilot) — probably on dashboard
- New mentor system prompt for Co-Pilot (direct, decisive, teaches while deciding)
- Chart data ingestion (real market data API or screenshot upload)
- New trade signal UI (showing: action, confidence, entry price, stop-loss, take-profit, ratio, rationale)
- Possibly: Supabase for persisting real trade decisions and tracking P&L over time
- The FCA guardrails in the system prompt need to be scoped differently (personal use disclaimer, not blanket prohibition)

---

## Files to read for context
- `CLAUDE.md` — project context and coding conventions
- `docs/product-spec.md` — full original product spec
- `contexts/context-april-14-2026.md` — this file

---

## What to do next session
1. Discuss and finalise the Co-Pilot mode architecture with Anti
2. Rewrite the spec in `docs/product-spec.md` to reflect the dual-mode product
3. Update `CLAUDE.md` current phase
4. Build: mode selector, Co-Pilot system prompt, chart data flow, signal UI
5. Wire up real Anthropic API key (Anti needs to provide)
6. Wire up real market data (Alpha Vantage or Yahoo Finance)
7. Connect Supabase when Anti has created the project

---

## Key conventions (never forget)
- TypeScript strict mode, no `any`
- Functional components only, server components by default
- Mobile-first responsive design
- `Button asChild` does NOT work — use `buttonVariants` on `<Link>`
- Never give personalised financial advice (original constraint — scope may change for Co-Pilot personal mode)
- Trade reason is always a required field
- Disclaimer on every session screen
