# Watchlist Criteria

This is the source of truth for the premarket scanner. Two setups, both backtested, both with hard rules. If a ticker doesn't check every box, it doesn't make the list. No vibes-based inclusion.

## Day Trading Watchlist: "Trend Join Long"

Backtest: 54.6% win rate, profit factor 1.59, 280 trades.

### Premarket selection (all required)

- Gap % vs prev close > 3%
- Price > $3
- Market cap > $1B
- Premarket RVOL > 1.5
- Price breaking above yesterday's high

### Intraday plan

- **Window:** 10:00am to 3:30pm ET. Nothing before, nothing after.
- **Trigger:** price > premarket high AND > prior high-of-day
- **Stop (1R):** 1% below premarket high, or LOD, whichever is lower
- **Scale out:** 1/3 off at +1R, 1/3 off at +2R
- **Runner:** trail the last 1/3 on the 21-EMA
- **Hard flat:** 3:51pm, no exceptions

## Swing Watchlist

Backtest: 57.6% win rate / PF 5.34 on news catalysts, 44.7% win rate / PF 2.57 on earnings catalysts.

### Premarket selection (all required)

- Gap % >= 8%
- Price > $3
- Open > yesterday's high
- Open > 200-day SMA
- Market cap >= $800M
- Real catalyst: earnings on the gap day, or news with no earnings attached

### Entry and exit

Management logic isn't built yet. Swing names on this list are starter ideas only. Do not attach stops or targets that aren't real, just flag the setup and the catalyst.

## Conviction Key (for reference downstream)

🟢 High conviction, 🟡 Mixed / needs confirmation, 🔴 Low conviction / skip. This file only defines the watchlist filters, conviction gets layered on by the analyst pass later.
