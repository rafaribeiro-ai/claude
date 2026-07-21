import { NotFoundFailure } from '@/core/error/failure'
import { err, ok, type Result } from '@/core/result/result'
import type { Instrument } from '../../domain/entities/instrument'
import type { InstrumentRepository } from '../../domain/repositories/instrumentRepository'
import { seedInstruments } from '../datasources/instrumentLocalDataSource'

export class InstrumentRepositoryImpl implements InstrumentRepository {
  async getAvailableInstruments(): Promise<Result<Instrument[]>> {
    return ok(seedInstruments)
  }

  async getInstrumentBySymbol(symbol: string): Promise<Result<Instrument>> {
    const instrument = seedInstruments.find((i) => i.symbol === symbol)
    if (!instrument) {
      return err(new NotFoundFailure(`Instrumento "${symbol}" não encontrado.`))
    }
    return ok(instrument)
  }
}

export const instrumentRepository: InstrumentRepository = new InstrumentRepositoryImpl()
