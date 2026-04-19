# Risk Engine

**Status:** Rules designed, not yet built  
**Phase:** 1 (Step 6)

## Purpose

Hard rules applied *after* Claude returns a signal, *before* showing to the user. Protects against both bad AI outputs and bad user behaviour.

## Rules (proposed — pending Anti's review)

| Rule | Value | What happens if violated |
|---|---|---|
| Min risk:reward | 1:2 | Reject signal, ask Claude to recalculate TP |
| Max position size | 10% of portfolio | Cap the `positionSizePct` |
| Max daily trades | 5 | Block execution, show "daily limit reached" |
| Max portfolio risk per trade | 2% of total value | Reduce quantity so max loss ≤ 2% |
| Stop loss required | Always | Reject any signal without SL |
| No same-ticker stacking | 1 open position per ticker | Block if already holding |

## Why these numbers

- **1:2 R:R** — you only need to be right 33% of the time to break even. The test run returned 1:1 which is a bad trade.
- **10% max position** — prevents overconcentration. With £10K pot, max £1K per position.
- **5 daily trades** — prevents overtrading and impulse decisions.
- **2% risk per trade** — industry standard for retail. Max £200 loss per trade from £10K.
- **No stacking** — keeps portfolio diversified, prevents averaging down into losers.

## Implementation

Applied as a validation layer between Claude's response and the UI. If a rule is violated:
1. Some rules auto-correct (cap position size, reduce quantity)
2. Some rules reject and retry (R:R too low → re-prompt Claude)
3. Some rules hard-block (daily limit, no SL)

---

*See [[wingman-signal-generation]] for the full signal flow.*
