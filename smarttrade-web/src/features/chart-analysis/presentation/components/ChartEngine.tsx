import { useEffect, useRef } from 'react'
import { CandlestickSeries, createChart, type UTCTimestamp } from 'lightweight-charts'
import type { Candle } from '../../domain/entities/candle'
import type { ChartDisplayMode } from '../../domain/entities/chartDisplayMode'

interface CandleChartEngineProps {
  candles: Candle[]
  mode: ChartDisplayMode
}

/**
 * Contract the trading chart screen renders against, in effect: any
 * component with this prop shape can replace `CandleChartEngine` below.
 * Swapping the MVP's lightweight-charts candlestick engine for a full
 * Renko-capable library later means writing a new component with the
 * same props and swapping the import in `TradingChartPage` - the page
 * itself never changes.
 *
 * MVP engine: draws real candlesticks via lightweight-charts. It
 * intentionally does not implement `mode === 'renko'` -
 * lightweight-charts has no notion of atemporal bricks - so a
 * Renko-capable engine is a straight drop-in replacement, not a rewrite
 * of this screen.
 */
export function CandleChartEngine({ candles, mode }: CandleChartEngineProps) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (mode !== 'time' || !containerRef.current) return

    const chart = createChart(containerRef.current, {
      layout: {
        background: { color: 'transparent' },
        textColor: '#8b93a1',
      },
      grid: {
        vertLines: { color: '#2a2f36' },
        horzLines: { color: '#2a2f36' },
      },
      timeScale: { borderColor: '#2a2f36' },
      rightPriceScale: { borderColor: '#2a2f36' },
      autoSize: true,
    })

    const series = chart.addSeries(CandlestickSeries, {
      upColor: '#17c67f',
      downColor: '#e5484d',
      borderVisible: false,
      wickUpColor: '#17c67f',
      wickDownColor: '#e5484d',
    })

    series.setData(
      candles.map((candle) => ({
        time: Math.floor(candle.time.getTime() / 1000) as UTCTimestamp,
        open: candle.open,
        high: candle.high,
        low: candle.low,
        close: candle.close,
      })),
    )
    chart.timeScale().fitContent()

    return () => chart.remove()
  }, [mode, candles])

  if (candles.length === 0) {
    return (
      <div className="flex h-full items-center justify-center rounded-xl border border-border bg-surface text-sm text-text-secondary">
        Sem dados de preço carregados.
      </div>
    )
  }

  if (mode === 'renko') {
    return (
      <div className="flex h-full items-center justify-center rounded-xl border border-border bg-surface p-6 text-center text-sm text-text-secondary">
        Visualização Renko requer um motor de gráfico dedicado.
        <br />
        Implemente um novo CandleChartEngine para habilitá-la.
      </div>
    )
  }

  return <div ref={containerRef} className="h-full w-full rounded-xl border border-border bg-surface" />
}
