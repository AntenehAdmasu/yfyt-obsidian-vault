# Market Data

**Status:** Alpha Vantage working (limited), Alpaca blocked on signup  
**Phase:** 1 (Step 3)

## Two options

### Alpaca Markets (preferred)

- **Free** real-time WebSocket streaming (IEX feed)
- Built-in paper trading API
- Unlimited requests
- **Problem:** signup blocked — "invalid email domain" error. Need to try plain Gmail, Outlook, or work email.

### Alpha Vantage (current fallback)

- API key working: `ALPHA_VANTAGE_API_KEY` in `.env.local`
- **Free tier: 25 requests/day** — not viable for monitoring multiple stocks
- Premium: $50/mo for 75 requests/min
- No WebSocket streaming — polling only
- Tested successfully: fetched real AAPL daily OHLCV + RSI(14) on April 18

## What we need from market data

| Data | Used for | Frequency |
|---|---|---|
| Daily OHLCV (30-50 bars) | Signal generation prompt | On-demand per signal |
| RSI(14) | Signal generation prompt | On-demand per signal |
| SMA 20/50 | Signal generation prompt | Can calculate locally from OHLCV |
| MACD | Signal generation prompt | Can calculate locally from OHLCV |
| Current price | Trade execution, P&L | Real-time or near-real-time |
| Intraday data | Monitoring active positions | Every 30 min for 3-5 tickers |

## Monitoring architecture (cost-optimised)

- **Morning:** Fetch data for 50-100 tickers → local code filters → shortlist 5-10
- **Intraday:** Check 3-5 active tickers every 30 min (code, not Claude)
- **Alerts:** Code detects entry/SL/TP hits → notification
- With Alpha Vantage free tier (25/day), can only do ~5 tickers × 5 checks. Alpaca solves this.

## Other alternatives if Alpaca fails

- **Polygon.io** — free tier: 5 API calls/min, delayed data
- **Finnhub** — free tier: 60 calls/min, real-time US stocks
- **Yahoo Finance** — unofficial, rate limited, no API key needed

---

*Decision pending Alpaca signup resolution. See [[pitfalls]] for rate limit risks.*
