/**
 * One OHLC price bar. Timeframe-agnostic on purpose: `time` is a real
 * timestamp for time-based candles, but a Renko engine can reuse this
 * same shape and simply ignore `time` spacing (Renko bricks form on
 * price movement, not on a clock).
 */
export interface Candle {
  time: Date
  open: number
  high: number
  low: number
  close: number
  volume?: number
}

export function isBullish(candle: Candle): boolean {
  return candle.close >= candle.open
}
