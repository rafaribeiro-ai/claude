import { TradingConstants } from '@/core/constants/tradingConstants'
import { InvalidTradeParametersFailure, type Failure } from '@/core/error/failure'
import { err, ok, type Result } from '@/core/result/result'
import { valuePerPoint, type ForexInstrument, type FuturesInstrument, type Instrument } from '../entities/instrument'
import type { RiskCalculation } from '../entities/riskCalculation'
import type { TradeDirection } from '../entities/tradeDirection'

export interface CalculatePositionRiskParams {
  instrument: Instrument
  direction: TradeDirection
  entryPrice: number
  stopPrice: number
  targetPrice: number
  /**
   * Only consulted for forex instruments. Ignored for futures: the
   * Golden Rule fixes the contract count regardless of what is passed
   * here, so there is no `desiredFuturesQuantity` field at all.
   */
  desiredForexLotSize?: number
}

/**
 * Core domain logic of the "Boleta Inteligente".
 *
 * Golden Rule: futures orders are always sized at exactly
 * `TradingConstants.fixedFuturesContractQuantity` (1) contract. This
 * function never reads a user-supplied futures quantity because
 * {@link CalculatePositionRiskParams} doesn't expose one - the lock is
 * structural, not just a runtime check. Its entire job for futures is to
 * translate the Stop Loss distance into the exact dollar risk that
 * single contract carries.
 *
 * Forex/metals pairs (e.g. XAU/USD) are priced in pips and support
 * fractional lot sizing for users who don't trade futures.
 */
export function calculatePositionRisk(
  params: CalculatePositionRiskParams,
): Result<RiskCalculation> {
  const validationError = validate(params)
  if (validationError) return err(validationError)

  const stopDistance = Math.abs(params.entryPrice - params.stopPrice)
  const targetDistance = Math.abs(params.targetPrice - params.entryPrice)

  const { positionSize, riskAmount, rewardAmount } =
    params.instrument.marketType === 'futures'
      ? calculateFutures(params.instrument, stopDistance, targetDistance)
      : calculateForex(
          params.instrument,
          stopDistance,
          targetDistance,
          params.desiredForexLotSize,
        )

  const riskRewardRatio = riskAmount === 0 ? 0 : rewardAmount / riskAmount

  return ok({
    instrument: params.instrument,
    direction: params.direction,
    entryPrice: params.entryPrice,
    stopPrice: params.stopPrice,
    targetPrice: params.targetPrice,
    positionSize,
    stopDistance,
    targetDistance,
    riskAmount,
    rewardAmount,
    riskRewardRatio,
  })
}

function calculateFutures(
  instrument: FuturesInstrument,
  stopDistance: number,
  targetDistance: number,
) {
  // Regra de Ouro: sempre 1 contrato. Not a default, not clamped from
  // user input - this is the only value ever used here.
  const positionSize: number = TradingConstants.fixedFuturesContractQuantity
  const vpp = valuePerPoint(instrument)
  return {
    positionSize,
    riskAmount: stopDistance * vpp * positionSize,
    rewardAmount: targetDistance * vpp * positionSize,
  }
}

function calculateForex(
  instrument: ForexInstrument,
  stopDistance: number,
  targetDistance: number,
  desiredLotSize: number | undefined,
) {
  const requested = desiredLotSize ?? TradingConstants.defaultForexLotSize
  const steps = Math.round(requested / instrument.lotStep)
  const snapped = steps * instrument.lotStep
  const lotSize = snapped < instrument.minLot ? instrument.minLot : snapped

  return {
    positionSize: lotSize,
    riskAmount: stopDistance * instrument.contractSize * lotSize,
    rewardAmount: targetDistance * instrument.contractSize * lotSize,
  }
}

function validate(params: CalculatePositionRiskParams): Failure | null {
  if (params.entryPrice <= 0 || params.stopPrice <= 0 || params.targetPrice <= 0) {
    return new InvalidTradeParametersFailure(
      'Preços de entrada, stop e alvo devem ser maiores que zero.',
    )
  }

  if (params.stopPrice === params.entryPrice) {
    return new InvalidTradeParametersFailure(
      'O Stop Loss não pode ser igual ao preço de entrada.',
    )
  }

  const isLong = params.direction === 'long'
  const stopOnCorrectSide = isLong
    ? params.stopPrice < params.entryPrice
    : params.stopPrice > params.entryPrice
  const targetOnCorrectSide = isLong
    ? params.targetPrice > params.entryPrice
    : params.targetPrice < params.entryPrice

  if (!stopOnCorrectSide) {
    return new InvalidTradeParametersFailure(
      isLong
        ? 'Em uma operação comprada, o Stop Loss deve ficar abaixo da entrada.'
        : 'Em uma operação vendida, o Stop Loss deve ficar acima da entrada.',
    )
  }

  if (!targetOnCorrectSide) {
    return new InvalidTradeParametersFailure(
      isLong
        ? 'Em uma operação comprada, o alvo deve ficar acima da entrada.'
        : 'Em uma operação vendida, o alvo deve ficar abaixo da entrada.',
    )
  }

  return null
}
