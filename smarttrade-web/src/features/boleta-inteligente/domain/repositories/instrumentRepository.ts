import type { Result } from '@/core/result/result'
import type { Instrument } from '../entities/instrument'

/**
 * Source of tradable instruments for the Boleta Inteligente.
 *
 * The MVP data layer backs this with a hard-coded seed list (Nasdaq
 * futures, XAU/USD), but the domain layer only knows this contract, so
 * swapping in a remote/broker-fed catalog later is a data-layer-only
 * change.
 */
export interface InstrumentRepository {
  getAvailableInstruments(): Promise<Result<Instrument[]>>
  getInstrumentBySymbol(symbol: string): Promise<Result<Instrument>>
}
