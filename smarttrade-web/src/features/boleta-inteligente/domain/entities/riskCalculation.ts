import { TradingConstants } from '@/core/constants/tradingConstants'
import type { Instrument } from './instrument'
import type { TradeDirection } from './tradeDirection'

/**
 * Result of running the Boleta Inteligente's risk/reward math for one
 * instrument, direction, entry, stop and target combination.
 *
 * `positionSize` is always `1` when `instrument.marketType === 'futures'`
 * (the Golden Rule), or the resolved lot size for forex.
 */
export interface RiskCalculation {
  instrument: Instrument
  direction: TradeDirection
  entryPrice: number
  stopPrice: number
  targetPrice: number
  positionSize: number
  /** Absolute price distance between entry and stop. */
  stopDistance: number
  /** Absolute price distance between entry and target. */
  targetDistance: number
  /** Exact financial risk, in USD, this single position carries. */
  riskAmount: number
  /** Potential financial reward, in USD, if the target is hit. */
  rewardAmount: number
  riskRewardRatio: number
}

export function isHealthyRiskReward(calculation: RiskCalculation): boolean {
  return calculation.riskRewardRatio >= TradingConstants.minHealthyRiskRewardRatio
}

export function isFuturesGoldenRuleLocked(calculation: RiskCalculation): boolean {
  return calculation.instrument.marketType === 'futures'
}
