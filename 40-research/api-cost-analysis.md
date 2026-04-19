# API Cost Analysis

**Date:** April 18, 2026

## Claude Opus 4.6 pricing

- Input: ~$15 per million tokens
- Output: ~$75 per million tokens
- Anti's plan: $24/month Build tier (fixed credit allowance)

## Cost per API call type

| Call type | Input tokens | Output tokens | Cost |
|---|---|---|---|
| Signal generation | ~900-1,100 | ~700-800 | ~$0.07-0.08 |
| Chat follow-up | ~500-800 | ~300-500 | ~$0.03-0.04 |
| Post-trade review | ~600 | ~400 | ~$0.05 |

## Daily usage projection (personal use)

| Call type | Count/day | Cost each | Daily total |
|---|---|---|---|
| Signal generation | 10-15 | ~$0.08 | ~$1.00 |
| Chat follow-ups | 10-20 | ~$0.04 | ~$0.60 |
| Post-trade review | 2-3 | ~$0.05 | ~$0.15 |
| **Total** | | | **~$1.75/day** |

Monthly: ~$35-50. The $24/mo Build plan may not cover heavy usage — monitor and top up if needed.

## Why NOT to scan 100 stocks with Claude

| Scenario | Calls/day | Cost/day | Verdict |
|---|---|---|---|
| 100 stocks every 5 min | 7,800 | $546 | Insane |
| 100 stocks every 30 min | 1,300 | $91 | Still too much |
| 5-10 shortlisted stocks | 10-15 | $1 | Right approach |

**Rule:** Use code for filtering and monitoring. Use Claude only for deep thinking on shortlisted tickers.

## Market data costs

| Provider | Free tier | Premium |
|---|---|---|
| Alpha Vantage | 25 req/day | $50/mo (75 req/min) |
| Alpaca | Unlimited (WebSocket) | Free |
| Polygon.io | 5 req/min (delayed) | $29/mo |
| Finnhub | 60 req/min | Free |

---

*See [[market-data]] for provider decision. See [[scope]] for budget constraints.*
