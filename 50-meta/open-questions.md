# Open questions

List unresolved questions here; promote answers to `30-decisions/` or [[scope]] when decided.

## Database schema (from temp-plan/database.md)
- Starting balance: £10,000 confirmed? (matches 2%/week target)
- Currency: GBP only, or support USD too? (most tickers are US-listed, prices in USD)
- Multiple portfolios: one per user for Phase 1? (separate "aggressive" vs "conservative" pots later?)
- Auth method: magic link only to start, or also Google OAuth from day one?

## Risk engine
- Are the proposed limits right? Min 1:2 R:R, max 10% position, max 5 daily trades, 2% portfolio risk per trade
- Should we enforce market hours (no fills outside 9:30am-4pm ET) for paper trading?

## Market data
- Alpaca signup blocked — try different email or choose alternative provider?
- If stuck on Alpha Vantage free (25 req/day), is that enough for Phase 1 dev/testing?
- Should we calculate indicators locally (SMA, MACD from OHLCV) or rely on API endpoints?

## Trading strategy
- Starting watchlist: which 30-50 tickers? (Anti needs to draft)
- System prompt methodology: does the proposed swing trading + price action approach match how Anti/Elsh want to trade?
- Post-mortem frequency: after every trade, or end-of-day batch?

## Product direction
- Kill the manual Trade page before beta? (redundant without Wingman guidance)
- When to deploy to Vercel? (after Supabase auth is wired, or sooner for feedback?)
