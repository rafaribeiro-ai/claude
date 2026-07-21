import type { Candle } from '../../domain/entities/candle'

/**
 * Deterministic placeholder price series. There is no live market data
 * feed in the MVP yet; this only exists so the chart screen has
 * something to render while that integration is built.
 */
export function generateSampleCandles(symbol: string, count = 60): Candle[] {
  const seed = [...symbol].reduce((sum, char) => sum + char.charCodeAt(0), 0)
  let price = 100 + (seed % 50)
  const now = Date.now()

  return Array.from({ length: count }, (_, i) => {
    const drift = (((seed + i * 7) % 11) - 5) * 0.35
    const open = price
    price = Math.max(1, price + drift)
    const close = price
    const high = Math.max(open, close) + 0.5
    const low = Math.min(open, close) - 0.5

    return {
      time: new Date(now - (count - i) * 5 * 60_000),
      open,
      high,
      low,
      close,
    }
  })
}
