/**
 * How the chart lays out candles on the horizontal axis.
 *
 * `time` is the classic clock-driven candle chart. `renko` is
 * atemporal: bricks are drawn purely from price movement past a fixed
 * size, so the same price history can produce a different number of
 * bricks depending on {@link RenkoSettings.brickSize}. The MVP chart
 * engine (see `presentation/components/ChartEngine.tsx`) only implements
 * `time` today; `renko` exists so the interface doesn't need to change
 * shape when a Renko-capable charting library is plugged in.
 */
export type ChartDisplayMode = 'time' | 'renko'

/**
 * Configuration a future Renko renderer will need. Kept here, next to
 * {@link ChartDisplayMode}, so the domain layer already models what
 * "atemporal" charting requires even though no renderer consumes it yet.
 */
export interface RenkoSettings {
  /** Minimum price movement, in points, required to draw a new brick. */
  brickSize: number
  /** Whether bricks show high/low wicks or are drawn as flat boxes. */
  useWicks: boolean
}
