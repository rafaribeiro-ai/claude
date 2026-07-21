import { useState } from 'react'
import { v4 as uuidv4 } from 'uuid'
import { calculatePositionRisk } from '@/features/boleta-inteligente/domain/usecases/calculatePositionRisk'
import type { Instrument } from '@/features/boleta-inteligente/domain/entities/instrument'
import type { TradeDirection } from '@/features/boleta-inteligente/domain/entities/tradeDirection'
import { useBoletaStore } from '@/features/boleta-inteligente/presentation/store/useBoletaStore'
import { useJournalStore } from '../store/useJournalStore'

interface AddJournalEntryFormProps {
  onClose: () => void
}

export function AddJournalEntryForm({ onClose }: AddJournalEntryFormProps) {
  const instruments = useBoletaStore((state) => state.instruments)
  const addEntry = useJournalStore((state) => state.addEntry)

  const [symbol, setSymbol] = useState(instruments[0]?.symbol ?? '')
  const [direction, setDirection] = useState<TradeDirection>('long')
  const [entryPrice, setEntryPrice] = useState('')
  const [stopPrice, setStopPrice] = useState('')
  const [targetPrice, setTargetPrice] = useState('')
  const [notes, setNotes] = useState('')
  const [error, setError] = useState<string | null>(null)

  const selectedInstrument: Instrument | undefined = instruments.find((i) => i.symbol === symbol)

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault()
    setError(null)

    const entry = Number(entryPrice)
    const stop = Number(stopPrice)
    const target = Number(targetPrice)

    if (!selectedInstrument || !entryPrice || !stopPrice || !targetPrice) {
      setError('Preencha entrada, stop e alvo corretamente.')
      return
    }

    const result = calculatePositionRisk({
      instrument: selectedInstrument,
      direction,
      entryPrice: entry,
      stopPrice: stop,
      targetPrice: target,
    })

    if (!result.ok) {
      setError(result.error.message)
      return
    }

    const calc = result.value
    const saveResult = await addEntry({
      id: uuidv4(),
      instrumentSymbol: selectedInstrument.symbol,
      direction,
      entryPrice: entry,
      stopPrice: stop,
      targetPrice: target,
      riskAmount: calc.riskAmount,
      rewardAmount: calc.rewardAmount,
      riskRewardRatio: calc.riskRewardRatio,
      positionSize: calc.positionSize,
      outcome: 'open',
      openedAt: new Date(),
      notes: notes || undefined,
    })

    if (!saveResult.ok) {
      setError(saveResult.error.message)
      return
    }

    onClose()
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 sm:items-center">
      <form
        onSubmit={handleSubmit}
        className="flex w-full max-w-md flex-col gap-3 rounded-t-2xl border border-border bg-surface p-5 sm:rounded-2xl"
      >
        <h2 className="text-base font-bold text-text-primary">Registrar operação</h2>

        <label className="flex flex-col gap-1.5">
          <span className="text-xs font-semibold text-text-secondary">Ativo</span>
          <select
            value={symbol}
            onChange={(e) => setSymbol(e.target.value)}
            className="rounded-lg border border-border bg-surface-elevated px-3 py-2.5 text-sm text-text-primary outline-none focus:border-accent"
          >
            {instruments.map((instrument) => (
              <option key={instrument.symbol} value={instrument.symbol}>
                {instrument.symbol}
              </option>
            ))}
          </select>
        </label>

        <div className="grid grid-cols-2 gap-2">
          <button
            type="button"
            onClick={() => setDirection('long')}
            className={`rounded-lg border px-3 py-2 text-xs font-semibold ${
              direction === 'long'
                ? 'border-profit/50 bg-profit/15 text-profit'
                : 'border-border bg-surface-elevated text-text-secondary'
            }`}
          >
            ▲ COMPRA
          </button>
          <button
            type="button"
            onClick={() => setDirection('short')}
            className={`rounded-lg border px-3 py-2 text-xs font-semibold ${
              direction === 'short'
                ? 'border-loss/50 bg-loss/15 text-loss'
                : 'border-border bg-surface-elevated text-text-secondary'
            }`}
          >
            ▼ VENDA
          </button>
        </div>

        <FormField label="Entrada" value={entryPrice} onChange={setEntryPrice} />
        <FormField label="Stop Loss" value={stopPrice} onChange={setStopPrice} />
        <FormField label="Alvo" value={targetPrice} onChange={setTargetPrice} />

        <label className="flex flex-col gap-1.5">
          <span className="text-xs font-semibold text-text-secondary">Notas (opcional)</span>
          <input
            type="text"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            className="rounded-lg border border-border bg-surface-elevated px-3 py-2.5 text-sm text-text-primary outline-none focus:border-accent"
          />
        </label>

        {error && <p className="text-xs text-loss">{error}</p>}

        <div className="mt-1 flex gap-2">
          <button
            type="button"
            onClick={onClose}
            className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-text-secondary"
          >
            Cancelar
          </button>
          <button
            type="submit"
            className="flex-1 rounded-lg bg-accent py-2.5 text-sm font-semibold text-white"
          >
            Salvar no Diário
          </button>
        </div>
      </form>
    </div>
  )
}

function FormField({
  label,
  value,
  onChange,
}: {
  label: string
  value: string
  onChange: (value: string) => void
}) {
  return (
    <label className="flex flex-col gap-1.5">
      <span className="text-xs font-semibold text-text-secondary">{label}</span>
      <input
        type="number"
        inputMode="decimal"
        step="any"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="rounded-lg border border-border bg-surface-elevated px-3 py-2.5 font-mono text-sm text-text-primary outline-none focus:border-accent"
      />
    </label>
  )
}
