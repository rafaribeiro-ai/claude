import { TradingConstants } from '@/core/constants/tradingConstants'

interface BaseInstrument {
  symbol: string
  displayName: string
  exchange: string
}

/**
 * A futures contract (e.g. Nasdaq-100 Micro/E-mini). Priced in
 * ticks/points, each with a fixed dollar value per single contract.
 */
export interface FuturesInstrument extends BaseInstrument {
  marketType: 'futures'
  /** Smallest price increment the instrument trades in (e.g. 0.25 pts). */
  tickSize: number
  /** Dollar value of one tick move, for exactly one contract. */
  tickValue: number
}

/**
 * A forex/metals spot pair (e.g. XAU/USD). Priced in pips, with lot size
 * freely adjustable (including fractional/micro lots) since the
 * one-contract Golden Rule only applies to the futures market.
 */
export interface ForexInstrument extends BaseInstrument {
  marketType: 'forex'
  /** Smallest quoted price increment considered "one pip" (e.g. 0.01). */
  pipSize: number
  /** Units of the base asset represented by one standard lot (1.0). */
  contractSize: number
  minLot: number
  lotStep: number
}

/**
 * A tradable instrument the Boleta Inteligente can build an order for.
 *
 * A discriminated union (on `marketType`) so `calculatePositionRisk` can
 * `switch` over the two pricing models exhaustively, with the compiler
 * catching a missing case if a third market type is ever added.
 */
export type Instrument = FuturesInstrument | ForexInstrument

/** Dollar value of one full point of price movement, one contract. */
export function valuePerPoint(instrument: FuturesInstrument): number {
  return instrument.tickValue / instrument.tickSize
}

export function forexInstrumentDefaults(): Pick<ForexInstrument, 'minLot' | 'lotStep'> {
  return {
    minLot: TradingConstants.minForexLotSize,
    lotStep: TradingConstants.forexLotStep,
  }
}
