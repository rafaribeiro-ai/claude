import { forexInstrumentDefaults, type Instrument } from '../../domain/entities/instrument'

/**
 * MVP catalog: a hard-coded seed list of instruments.
 *
 * Real contract specs (tick size/value, pip size, lot size) so the risk
 * math is accurate out of the box. Swapping this for a remote/broker-fed
 * catalog later only touches this file - the domain and presentation
 * layers depend on `InstrumentRepository`, not on where the list comes
 * from.
 */
export const seedInstruments: Instrument[] = [
  {
    marketType: 'futures',
    symbol: 'MNQ',
    displayName: 'Micro E-mini Nasdaq-100',
    exchange: 'CME',
    tickSize: 0.25,
    tickValue: 0.5,
  },
  {
    marketType: 'futures',
    symbol: 'NQ',
    displayName: 'E-mini Nasdaq-100',
    exchange: 'CME',
    tickSize: 0.25,
    tickValue: 5.0,
  },
  {
    marketType: 'futures',
    symbol: 'MGC',
    displayName: 'Micro Gold Futures',
    exchange: 'COMEX',
    tickSize: 0.1,
    tickValue: 1.0,
  },
  {
    marketType: 'forex',
    symbol: 'XAUUSD',
    displayName: 'Ouro (Spot)',
    exchange: 'OTC',
    pipSize: 0.01,
    contractSize: 100,
    ...forexInstrumentDefaults(),
  },
  {
    marketType: 'forex',
    symbol: 'EURUSD',
    displayName: 'Euro / Dólar',
    exchange: 'OTC',
    pipSize: 0.0001,
    contractSize: 100_000,
    ...forexInstrumentDefaults(),
  },
]
