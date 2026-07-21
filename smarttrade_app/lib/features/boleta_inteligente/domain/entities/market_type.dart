/// Which pricing model an [Instrument] uses. Drives which branch of the
/// risk calculator runs: ticks/points for futures, pips/lots for forex.
enum MarketType { futures, forex }
