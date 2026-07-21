import type { Result } from '@/core/result/result'
import type { JournalEntry } from '../entities/journalEntry'
import type { JournalRepository } from '../repositories/journalRepository'

export function getJournalEntries(repository: JournalRepository): Promise<Result<JournalEntry[]>> {
  return repository.getEntries()
}
