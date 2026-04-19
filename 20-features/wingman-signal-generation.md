# Wingman Signal Generation

**Status:** Designed, not yet built  
**Phase:** 1  
**API route:** `POST /api/wingman/signal`

## What it does

User picks a ticker + timeframe → app fetches real market data → builds structured prompt → sends to Claude Opus 4.6 → validates response with Zod → risk engine checks → renders SignalCard.

## Signal flow

1. User selects ticker (from watchlist or search) and timeframe (1D, 4H, 1H, 15m)
2. Server fetches from Alpaca/Alpha Vantage: last 30-50 OHLCV candles + indicators
3. Server builds prompt: system instructions + numerical data + user portfolio context
4. Claude Opus 4.6 returns structured JSON
5. Zod validates the schema — retry once if invalid
6. Risk engine enforces hard rules (see [[risk-engine]])
7. Signal saved to `signals` table in Supabase with full market data snapshot
8. SignalCard rendered in UI

## Output schema

```json
{
  "action": "BUY" | "SELL" | "WAIT",
  "confidence": "HIGH" | "MEDIUM" | "LOW",
  "entry": 270.23,
  "stopLoss": 261.50,
  "takeProfit": 288.00,
  "positionSizePct": 5,
  "riskReward": 2.03,
  "summary": "2-3 sentence overview",
  "reasoning": ["point 1", "point 2", "point 3"],
  "conceptsExplained": [{"term": "RSI", "explanation": "..."}]
}
```

## Data sent to Claude

| Data | Source | ~Tokens |
|---|---|---|
| OHLCV candles (30-50 bars) | Alpaca / Alpha Vantage | ~400 |
| RSI(14) | Calculated or API | ~50 |
| SMA 20 / SMA 50 | Calculated | ~50 |
| MACD (12, 26, 9) | Calculated | ~50 |
| Volume profile | Calculated | ~30 |
| Support/resistance levels | Calculated | ~30 |
| User portfolio context | Supabase | ~50 |
| System prompt | Hardcoded | ~400 |
| **Total** | | **~1,100** |

## Cost per signal

~$0.07-0.08 (input + output tokens at Opus pricing)

## Test run (April 18)

Successfully tested end-to-end: real AAPL data from Alpha Vantage → Claude Opus 4.6 → structured BUY signal. 872 tokens in, 790 out. Signal returned 1:1 R:R which was flagged as too low — system prompt needs to enforce 1:2 minimum.

---

*See [[risk-engine]] for the rules applied after Claude returns the signal.*
