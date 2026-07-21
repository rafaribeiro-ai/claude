import { useEffect } from 'react'
import { TradingConstants } from '@/core/constants/tradingConstants'
import { InstrumentSelector } from '../components/InstrumentSelector'
import { LockedContractBadge } from '../components/LockedContractBadge'
import { RiskSummaryPanel } from '../components/RiskSummaryPanel'
import { useBoletaStore } from '../store/useBoletaStore'
import type { TradeDirection } from '../../domain/entities/tradeDirection'

function parseNullableNumber(raw: string): number | null {
  if (raw.trim() === '') return null
  const parsed = Number(raw)
  return Number.isNaN(parsed) ? null : parsed
}

/**
 * "Boleta Inteligente" - the Smart Order Ticket. The MVP's core screen:
 * pick an instrument, set direction/entry/stop/target, and watch the
 * exact dollar risk and reward update live underneath.
 */
export function SmartOrderTicketPage() {
  const {
    instruments,
    loading,
    selectedInstrument,
    direction,
    calculation,
    loadInstruments,
    selectInstrument,
    setDirection,
    setEntryPrice,
    setStopPrice,
    setTargetPrice,
    setForexLotSize,
  } = useBoletaStore()

  useEffect(() => {
    loadInstruments()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const isForexSelected = selectedInstrument?.marketType === 'forex'
  const isFuturesSelected = selectedInstrument?.marketType === 'futures'

  if (loading) {
    return <div className="p-6 text-sm text-text-secondary">Carregando instrumentos…</div>
  }

  return (
    <div className="mx-auto flex max-w-xl flex-col gap-4 p-4 pb-24">
      <h1 className="text-xl font-bold text-text-primary">Boleta Inteligente</h1>

      <InstrumentSelector
        instruments={instruments}
        selected={selectedInstrument}
        onChange={selectInstrument}
      />

      <div className="flex items-center justify-between">
        <span className="text-xs font-semibold tracking-wide text-text-secondary">DIREÇÃO</span>
        {isFuturesSelected && <LockedContractBadge />}
      </div>
      <DirectionToggle direction={direction} onChange={setDirection} />

      <PriceField label="Entrada" onChange={(raw) => setEntryPrice(parseNullableNumber(raw))} />
      <PriceField label="Stop Loss" onChange={(raw) => setStopPrice(parseNullableNumber(raw))} />
      <PriceField label="Alvo (Take Profit)" onChange={(raw) => setTargetPrice(parseNullableNumber(raw))} />

      {isForexSelected && (
        <PriceField
          label="Tamanho do Lote"
          defaultValue={String(TradingConstants.defaultForexLotSize)}
          onChange={(raw) => {
            const parsed = parseNullableNumber(raw)
            if (parsed !== null) setForexLotSize(parsed)
          }}
        />
      )}

      <RiskSummaryPanel calculation={calculation} />
    </div>
  )
}

function DirectionToggle({
  direction,
  onChange,
}: {
  direction: TradeDirection
  onChange: (direction: TradeDirection) => void
}) {
  return (
    <div className="grid grid-cols-2 gap-2">
      <button
        type="button"
        onClick={() => onChange('long')}
        className={`rounded-lg border px-4 py-2.5 text-sm font-semibold transition-colors ${
          direction === 'long'
            ? 'border-profit/50 bg-profit/15 text-profit'
            : 'border-border bg-surface-elevated text-text-secondary'
        }`}
      >
        ▲ COMPRA
      </button>
      <button
        type="button"
        onClick={() => onChange('short')}
        className={`rounded-lg border px-4 py-2.5 text-sm font-semibold transition-colors ${
          direction === 'short'
            ? 'border-loss/50 bg-loss/15 text-loss'
            : 'border-border bg-surface-elevated text-text-secondary'
        }`}
      >
        ▼ VENDA
      </button>
    </div>
  )
}

function PriceField({
  label,
  defaultValue,
  onChange,
}: {
  label: string
  defaultValue?: string
  onChange: (raw: string) => void
}) {
  return (
    <label className="flex flex-col gap-1.5">
      <span className="text-xs font-semibold tracking-wide text-text-secondary">{label}</span>
      <input
        type="number"
        inputMode="decimal"
        step="any"
        defaultValue={defaultValue}
        onChange={(event) => onChange(event.target.value)}
        className="rounded-lg border border-border bg-surface-elevated px-3 py-3 font-mono text-sm font-semibold tabular-nums text-text-primary outline-none focus:border-accent"
      />
    </label>
  )
}
