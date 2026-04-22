# Strategy Tuning — Parking Lot

Ideas for improving screener accuracy, signal quality, and ticker selection. These are refinements to the core strategy — return to them once the base system is running and producing data to validate against.

Canonical source: `plan/strategy-tuning.md` in the code repo.

---

## Screener filter improvements

- **ATR-normalised gaps** — replace flat 1% gap threshold with gap > 1 ATR. Normalises for per-stock volatility.

- **Tiered ticker pool expansion** — instead of relaxing thresholds, expand the search universe in tiers (first 50 → second 50 → third 50). Never compromise on filter quality. If nothing passes, don't trade that day.

- **Confidence scoring and sorting** — when too many tickers pass, rank by weighted score (filters passed, signal strength, volume ratio, proximity to levels). Top N go to Claude.

## Additional algorithmic approaches

- **Relative strength vs SPY** — 20-day performance vs SPY. Leadership detection.
- **ATR expansion** — volatility increasing = stock waking up. Catches early breakouts.
- **Pre-market movers** — via Alpaca WebSocket. Overnight news reaction.
- **Sector rotation scan** — scan sector ETFs first, then strongest stocks within hot sectors.
- **Consolidation breakout (volatility squeeze)** — narrowing Bollinger Bands or compressed 20-day range.
- **Unusual options activity** — abnormal call/put volume. Needs paid data feed.

---

See also: [[signal-strategy]], [[parking-lot]], [[risk-engine]]

*Prioritise based on paper trading results — which setups does Wingman perform best on?*
