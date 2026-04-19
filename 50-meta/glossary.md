# Glossary

Define shared terms so notes stay consistent. Use `[[wiki-links]]` to key concepts.

| Term | Definition |
|------|------------|
| **Wingman** | The AI trading co-pilot — core feature of YFYT. Analyses tickers, generates signals, answers questions. |
| **Signal** | A structured trading recommendation: BUY/SELL/WAIT with entry, stop loss, take profit, confidence, reasoning. |
| **R:R (Risk:Reward)** | Ratio of potential loss to potential gain. E.g. 1:2 means risking $1 to make $2. Minimum 1:2 enforced. |
| **Stop Loss (SL)** | Price level where a losing trade is automatically closed to limit loss. |
| **Take Profit (TP)** | Price level where a winning trade is automatically closed to lock in gain. |
| **Paper trading** | Simulated trading with fake money. No real financial risk. |
| **RSI** | Relative Strength Index — momentum indicator. Above 70 = overbought, below 30 = oversold. |
| **OHLCV** | Open, High, Low, Close, Volume — the five data points for each price candle. |
| **SMA** | Simple Moving Average — average closing price over N periods. |
| **MACD** | Moving Average Convergence Divergence — trend/momentum indicator using 12, 26, 9 period EMAs. |
| **Swing trading** | Holding positions for 1-10 days. YFYT's default timeframe. |
| **RLS** | Row Level Security — Supabase/Postgres feature ensuring users can only access their own data. |
| **Zod** | TypeScript schema validation library. Used to validate Claude's JSON output. |
| **RAG** | Retrieval Augmented Generation — pulling relevant docs/knowledge into AI prompts. Phase 2. |
| **FinBERT** | Financial sentiment analysis model. Converts news headlines into numeric sentiment scores. Phase 2. |
| **Phase gate** | Decision checkpoint — a phase must pass its gate before the next phase starts. |
| **Parking lot** | Holding area for out-of-scope ideas. See [[parking-lot]]. |
| **Position sizing** | How much of your portfolio to allocate to a single trade. Max 10% in YFYT. |
| **Alpha Vantage** | Market data API provider. Free tier: 25 requests/day. |
| **Alpaca Markets** | Market data + paper trading API. Free real-time WebSocket streaming. |
| **Supabase** | Backend-as-a-service: Postgres database + auth + realtime. YFYT's database. |
