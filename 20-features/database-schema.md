# Database Schema

**Status:** Designed in `temp-plan/database.md`, awaiting Anti's approval  
**Phase:** 1 (Step 1)  
**Platform:** Supabase (Postgres + RLS)

## Tables

| Table | Purpose | Key fields |
|---|---|---|
| `users` | Core user record, linked to Supabase Auth | id, email, name, starting_balance, currency, preferences |
| `portfolios` | One per user, tracks cash balance | id, user_id, cash_balance |
| `positions` | Open positions | ticker, quantity, avg_buy_price, total_cost_basis |
| `trades` | Every buy/sell ever (immutable) | ticker, action, quantity, price, reason, pnl, signal_id |
| `signals` | Every Wingman signal generated | ticker, timeframe, action, confidence, entry/SL/TP, reasoning, market_data_snapshot |
| `chat_messages` | Follow-up chat about signals | signal_id, role, content |
| `watchlist` | Tickers user is watching | ticker, notes |

## Design principles

- **RLS on everything** — users only see their own data
- **UUIDs** — no sequential IDs exposed
- **Immutable trades** — never updated or deleted (audit trail for Phase 4 journal)
- **Market data snapshots** — stored as JSONB on signals, so we can replay exactly what Claude saw
- **Token tracking** — input/output tokens stored on signals for cost monitoring

## Open questions

1. Starting balance: £10,000 confirmed?
2. Currency: GBP only, or support USD too?
3. Multiple portfolios: one per user for Phase 1?
4. Auth method: magic link only, or also Google OAuth?

## Data volume (3 months, personal use)

~300 trades, ~1,200 signals, ~2,500 chat messages, ~50 watchlist items. Well within Supabase free tier (500MB, 50K rows).

---

*Full schema detail in `temp-plan/database.md` in the code repo. See [[scope]] for Phase 1 steps.*
