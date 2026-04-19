# Tech Stack

## Current stack (as of April 18, 2026)

| Layer | Technology | Status |
|---|---|---|
| **Framework** | Next.js 16.2.3 App Router + TypeScript 5.9.3 | Built |
| **Styling** | Tailwind CSS v4 + shadcn/ui v4 + `next-themes` | Built |
| **Charts** | lightweight-charts v5 (TradingView) + recharts (equity curves) | Built |
| **Icons** | lucide-react | Built |
| **AI** | Claude Opus 4.6 (`claude-opus-4-6`) via Anthropic API | Key set up, tested |
| **Market data** | Alpha Vantage (working) / Alpaca Markets (preferred, signup blocked) | Partially set up |
| **Database** | Supabase (Postgres + RLS + Realtime + Auth) | Project created, schema designed |
| **Auth** | Supabase magic link (Google OAuth later) | Not built yet |
| **Rate limiting** | Upstash Redis (serverless) | Phase 2+ |
| **Hosting** | Vercel | Not deployed yet |
| **Theme** | `next-themes` with `attribute="class"`, dark default | Built |

## Architecture decisions (locked)

| Decision | Choice | Why |
|---|---|---|
| AI model | Claude Opus 4.6 — always upgrade, never Sonnet | Best quality for signal reasoning |
| Signal prompt | Numerical context, not chart images | 4x cheaper, more precise |
| AI output validation | Zod schema on Claude output | Prevent bad data reaching UI |
| Streaming | Mandatory for chat | First token <400ms |
| Market data | Alpaca (free WebSocket) preferred over Alpha Vantage (25 req/day free) | Cost and real-time capability |
| DB | Supabase (Postgres + RLS) | One service for everything |

## API keys (.env.local — gitignored)

| Key | Service | Status |
|---|---|---|
| `ANTHROPIC_API_KEY` | Claude Opus 4.6 | Set — needs rotation (shared in chat) |
| `ALPHA_VANTAGE_API_KEY` | Market data (fallback) | Set |
| `NEXT_PUBLIC_SUPABASE_URL` | Database | Set |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Database auth | Set |
| `ALPACA_API_KEY` | Market data (preferred) | Pending signup |
| `ALPACA_API_SECRET` | Market data (preferred) | Pending signup |

## Cost (personal use — Anti + Elsh only)

| Service | Monthly cost |
|---|---|
| Claude Opus 4.6 API | ~$24 (Build plan) + possible top-up |
| Supabase | Free tier |
| Alpaca Markets | Free |
| Vercel Hobby | Free |
| Alpha Vantage | Free (25 req/day) or $50/mo premium |
| Railway (Phase 3) | ~£5 |
| **Total** | **~$24-75/month** |

---

*See [[scope]] for what's being built with this stack.*
