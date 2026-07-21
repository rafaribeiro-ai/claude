import type { Result } from '@/core/result/result'
import { formatUsd } from '@/core/utils/currencyFormatter'
import { isHealthyRiskReward, type RiskCalculation } from '../../domain/entities/riskCalculation'

interface RiskSummaryPanelProps {
  calculation: Result<RiskCalculation> | null
}

export function RiskSummaryPanel({ calculation }: RiskSummaryPanelProps) {
  if (calculation === null) {
    return (
      <div className="rounded-xl border border-border bg-surface p-5 text-sm text-text-secondary">
        Preencha entrada, stop e alvo para calcular o risco.
      </div>
    )
  }

  if (!calculation.ok) {
    return (
      <div className="flex items-start gap-2.5 rounded-xl border border-loss/40 bg-loss/10 p-4 text-sm text-loss">
        <span aria-hidden="true">⚠</span>
        <span>{calculation.error.message}</span>
      </div>
    )
  }

  const calc = calculation.value
  const isFutures = calc.instrument.marketType === 'futures'
  const ratioColorClass = isHealthyRiskReward(calc) ? 'text-profit' : 'text-warning'

  return (
    <div className="rounded-xl border border-border bg-surface p-4">
      <div className="flex items-center justify-between">
        <span className="text-xs font-semibold tracking-wide text-text-secondary">RESUMO DE RISCO</span>
        <span className="text-xs font-semibold text-text-secondary">
          {isFutures ? '1 contrato' : `${calc.positionSize.toFixed(2)} lote(s)`}
        </span>
      </div>

      <div className="mt-4 flex gap-3">
        <div className="flex-1">
          <p className="text-xs text-text-secondary">Risco ($)</p>
          <p className="mt-1 font-mono text-2xl font-bold tabular-nums text-loss">
            {formatUsd(calc.riskAmount)}
          </p>
        </div>
        <div className="flex-1">
          <p className="text-xs text-text-secondary">Retorno ($)</p>
          <p className="mt-1 font-mono text-2xl font-bold tabular-nums text-profit">
            {formatUsd(calc.rewardAmount)}
          </p>
        </div>
      </div>

      <hr className="my-4 border-border" />

      <div className="flex items-center justify-between">
        <span className="text-sm text-text-primary">Relação Risco/Retorno</span>
        <span className={`font-mono text-sm font-semibold tabular-nums ${ratioColorClass}`}>
          1 : {calc.riskRewardRatio.toFixed(2)}
        </span>
      </div>
    </div>
  )
}
