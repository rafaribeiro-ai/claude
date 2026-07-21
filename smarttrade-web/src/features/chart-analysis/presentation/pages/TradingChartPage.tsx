import { useEffect, useMemo } from 'react'
import { useBoletaStore } from '@/features/boleta-inteligente/presentation/store/useBoletaStore'
import { generateSampleCandles } from '../../data/datasources/sampleCandleDataSource'
import type { ChartDisplayMode } from '../../domain/entities/chartDisplayMode'
import { CandleChartEngine } from '../components/ChartEngine'
import { MacroNewsTicker } from '../components/MacroNewsTicker'
import { useChartStore } from '../store/useChartStore'

/**
 * Chart screen for technical study. Reuses the instrument catalog
 * exposed by the Boleta Inteligente's domain layer (a shared domain
 * concept, not a presentation component) so both screens always agree
 * on which instruments exist.
 */
export function TradingChartPage() {
  const { instruments, loading, loadInstruments } = useBoletaStore()
  const { displayMode, headlines, annotationsBySymbol, setDisplayMode, loadHeadlines, loadAnnotations } =
    useChartStore()

  useEffect(() => {
    loadInstruments()
    loadHeadlines()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const symbol = instruments[0]?.symbol

  useEffect(() => {
    if (symbol) loadAnnotations(symbol)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [symbol])

  const candles = useMemo(() => (symbol ? generateSampleCandles(symbol) : []), [symbol])
  const annotations = symbol ? (annotationsBySymbol[symbol] ?? []) : []

  if (loading || !symbol) {
    return <div className="p-6 text-sm text-text-secondary">Carregando…</div>
  }

  return (
    <div className="flex h-full flex-col">
      <div className="flex items-center justify-between p-4 pb-2">
        <h1 className="text-xl font-bold text-text-primary">{symbol}</h1>
        <DisplayModeToggle mode={displayMode} onChange={setDisplayMode} />
      </div>

      {annotations.length > 0 && (
        <p className="px-4 pb-2 text-xs text-text-secondary">
          {annotations.length} marcação(ões) salva(s)
        </p>
      )}

      <div className="min-h-0 flex-1 px-4 pb-2">
        <CandleChartEngine candles={candles} mode={displayMode} />
      </div>

      <MacroNewsTicker headlines={headlines} />
    </div>
  )
}

function DisplayModeToggle({
  mode,
  onChange,
}: {
  mode: ChartDisplayMode
  onChange: (mode: ChartDisplayMode) => void
}) {
  return (
    <div className="flex rounded-lg border border-border bg-surface-elevated p-0.5 text-xs font-semibold">
      <button
        type="button"
        onClick={() => onChange('time')}
        className={`rounded-md px-3 py-1.5 transition-colors ${
          mode === 'time' ? 'bg-accent-muted text-accent' : 'text-text-secondary'
        }`}
      >
        Tempo
      </button>
      <button
        type="button"
        onClick={() => onChange('renko')}
        className={`rounded-md px-3 py-1.5 transition-colors ${
          mode === 'renko' ? 'bg-accent-muted text-accent' : 'text-text-secondary'
        }`}
      >
        Renko
      </button>
    </div>
  )
}
