import type { TradeDirection } from '@/features/boleta-inteligente/domain/entities/tradeDirection'
import type { TradeOutcome } from './tradeOutcome'

/**
 * One row of the offline "Diário de Trading". Typically created from a
 * `RiskCalculation` the Boleta Inteligente produced, so the risk figures
 * the user actually saw before entering are preserved even if contract
 * specs change later.
 */
export interface JournalEntry {
  id: string
  instrumentSymbol: string
  direction: TradeDirection
  entryPrice: number
  stopPrice: number
  targetPrice: number
  riskAmount: number
  rewardAmount: number
  riskRewardRatio: number
  positionSize: number
  outcome: TradeOutcome
  openedAt: Date
  notes?: string
  closedAt?: Date
}
