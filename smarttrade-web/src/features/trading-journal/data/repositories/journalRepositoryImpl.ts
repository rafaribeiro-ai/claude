import { DatabaseFailure } from '@/core/error/failure'
import { err, ok, type Result } from '@/core/result/result'
import type { JournalEntry } from '../../domain/entities/journalEntry'
import type { JournalRepository } from '../../domain/repositories/journalRepository'
import { journalLocalDataSource } from '../datasources/journalLocalDataSource'

export class JournalRepositoryImpl implements JournalRepository {
  async getEntries(): Promise<Result<JournalEntry[]>> {
    try {
      return ok(await journalLocalDataSource.getEntries())
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao carregar o diário: ${error}`))
    }
  }

  async addEntry(entry: JournalEntry): Promise<Result<void>> {
    try {
      await journalLocalDataSource.addEntry(entry)
      return ok(undefined)
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao salvar a operação: ${error}`))
    }
  }

  async deleteEntry(id: string): Promise<Result<void>> {
    try {
      await journalLocalDataSource.deleteEntry(id)
      return ok(undefined)
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao remover a operação: ${error}`))
    }
  }
}

export const journalRepository: JournalRepository = new JournalRepositoryImpl()
