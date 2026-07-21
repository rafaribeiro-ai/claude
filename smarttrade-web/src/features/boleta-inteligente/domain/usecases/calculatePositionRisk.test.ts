// Domain-level tests for the Boleta Inteligente's core business rule:
// futures orders are always sized at exactly one contract, and the
// dollar risk/reward math is derived from that fixed size.

import { describe, expect, it } from 'vitest'
import type { ForexInstrument, FuturesInstrument } from '../entities/instrument'
import { calculatePositionRisk } from './calculatePositionRisk'

const mnq: FuturesInstrument = {
  marketType: 'futures',
  symbol: 'MNQ',
  displayName: 'Micro E-mini Nasdaq-100',
  exchange: 'CME',
  tickSize: 0.25,
  tickValue: 0.5,
}

const xauusd: ForexInstrument = {
  marketType: 'forex',
  symbol: 'XAUUSD',
  displayName: 'Ouro (Spot)',
  exchange: 'OTC',
  pipSize: 0.01,
  contractSize: 100,
  minLot: 0.01,
  lotStep: 0.01,
}

describe('calculatePositionRisk - futures Golden Rule', () => {
  it('always locks position size to exactly 1 contract', () => {
    const result = calculatePositionRisk({
      instrument: mnq,
      direction: 'long',
      entryPrice: 20000,
      stopPrice: 19980,
      targetPrice: 20040,
    })

    expect(result.ok).toBe(true)
    if (!result.ok) throw new Error('expected ok result')
    expect(result.value.positionSize).toBe(1)
  })

  it('computes exact dollar risk from stop distance and tick value', () => {
    const result = calculatePositionRisk({
      instrument: mnq,
      direction: 'long',
      entryPrice: 20000,
      stopPrice: 19980, // 20 points away
      targetPrice: 20040, // 40 points away
    })

    expect(result.ok).toBe(true)
    if (!result.ok) throw new Error('expected ok result')

    // valuePerPoint = tickValue / tickSize = 0.50 / 0.25 = $2/point
    expect(result.value.riskAmount).toBeCloseTo(40.0, 3)
    expect(result.value.rewardAmount).toBeCloseTo(80.0, 3)
    expect(result.value.riskRewardRatio).toBeCloseTo(2.0, 3)
  })

  it('rejects a stop placed on the wrong side of a long entry', () => {
    const result = calculatePositionRisk({
      instrument: mnq,
      direction: 'long',
      entryPrice: 20000,
      stopPrice: 20010,
      targetPrice: 20040,
    })

    expect(result.ok).toBe(false)
  })
})

describe('calculatePositionRisk - forex lot sizing', () => {
  it('supports fractional lot sizes for non-futures instruments', () => {
    const result = calculatePositionRisk({
      instrument: xauusd,
      direction: 'long',
      entryPrice: 2400,
      stopPrice: 2395, // $5 distance
      targetPrice: 2415, // $15 distance
      desiredForexLotSize: 0.1,
    })

    expect(result.ok).toBe(true)
    if (!result.ok) throw new Error('expected ok result')

    expect(result.value.positionSize).toBeCloseTo(0.1, 3)
    // riskAmount = stopDistance * contractSize * lotSize = 5 * 100 * 0.1
    expect(result.value.riskAmount).toBeCloseTo(50.0, 3)
    expect(result.value.rewardAmount).toBeCloseTo(150.0, 3)
  })
})
