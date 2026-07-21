import { formatUsd } from '@/core/utils/currencyFormatter'
import type { JournalEntry } from '../../domain/entities/journalEntry'
import type { TradeOutcome } from '../../domain/entities/tradeOutcome'

const OUTCOME_LABEL: Record<TradeOutcome, { text: string; className: string }> = {
  open: { text: 'ABERTA', className: 'bg-accent/15 text-accent' },
  win: { text: 'GANHO', className: 'bg-profit/15 text-profit' },
  loss: { text: 'PERDA', className: 'bg-loss/15 text-loss' },
  breakeven: { text: 'EMPATE', className: 'bg-warning/15 text-warning' },
}

const dateFormatter = new Intl.DateTimeFormat('pt-BR', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
})

export function JournalEntryCard({ entry }: { entry: JournalEntry }) {
  const isLong = entry.direction === 'long'
  const outcome = OUTCOME_LABEL[entry.outcome]

  return (
    <div className="rounded-xl border border-border bg-surface p-3.5">
      <div className="flex items-center gap-1.5">
        <span className={isLong ? 'text-profit' : 'text-loss'} aria-hidden="true">
          {isLong ? '▲' : '▼'}
        </span>
        <span className="font-bold text-text-primary">{entry.instrumentSymbol}</span>
        <span className={`ml-auto rounded-md px-2 py-0.5 text-[10px] font-bold ${outcome.className}`}>
          {outcome.text}
        </span>
      </div>

      <div className="mt-2.5 flex gap-4">
        <Metric label="Risco" value={formatUsd(entry.riskAmount)} className="text-loss" />
        <Metric label="Retorno" value={formatUsd(entry.rewardAmount)} className="text-profit" />
        <Metric label="R:R" value={`1:${entry.riskRewardRatio.toFixed(2)}`} className="text-text-primary" />
      </div>

      <p className="mt-2 text-[11px] text-text-secondary">{dateFormatter.format(entry.openedAt)}</p>

      {entry.notes && <p className="mt-1.5 text-xs text-text-secondary">{entry.notes}</p>}
    </div>
  )
}

function Metric({ label, value, className }: { label: string; value: string; className: string }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[10px] text-text-secondary">{label}</span>
      <span className={`text-[13px] font-semibold ${className}`}>{value}</span>
    </div>
  )
}
