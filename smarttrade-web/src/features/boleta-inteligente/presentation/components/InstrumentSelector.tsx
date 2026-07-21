import type { Instrument } from '../../domain/entities/instrument'

interface InstrumentSelectorProps {
  instruments: Instrument[]
  selected: Instrument | null
  onChange: (instrument: Instrument) => void
}

export function InstrumentSelector({ instruments, selected, onChange }: InstrumentSelectorProps) {
  return (
    <div className="flex flex-col gap-2">
      <label htmlFor="instrument-select" className="text-xs font-semibold tracking-wide text-text-secondary">
        ATIVO
      </label>
      <select
        id="instrument-select"
        value={selected?.symbol ?? ''}
        onChange={(event) => {
          const instrument = instruments.find((i) => i.symbol === event.target.value)
          if (instrument) onChange(instrument)
        }}
        className="rounded-lg border border-border bg-surface-elevated px-3 py-3 text-sm font-medium text-text-primary outline-none focus:border-accent"
      >
        {instruments.map((instrument) => (
          <option key={instrument.symbol} value={instrument.symbol}>
            [{instrument.marketType === 'futures' ? 'FUT' : 'FX'}] {instrument.symbol} - {instrument.displayName}
          </option>
        ))}
      </select>
    </div>
  )
}
