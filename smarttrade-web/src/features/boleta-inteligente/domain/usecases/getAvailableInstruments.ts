import type { Result } from '@/core/result/result'
import type { Instrument } from '../entities/instrument'
import type { InstrumentRepository } from '../repositories/instrumentRepository'

export function getAvailableInstruments(
  repository: InstrumentRepository,
): Promise<Result<Instrument[]>> {
  return repository.getAvailableInstruments()
}
