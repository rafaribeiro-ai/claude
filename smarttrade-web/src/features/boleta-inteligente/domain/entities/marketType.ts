/**
 * Which pricing model an {@link Instrument} uses. Drives which branch of
 * the risk calculator runs: ticks/points for futures, pips/lots for forex.
 */
export type MarketType = 'futures' | 'forex'
