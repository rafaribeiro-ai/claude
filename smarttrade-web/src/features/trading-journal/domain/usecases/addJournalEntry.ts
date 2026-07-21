import type { Result } from '@/core/result/result'
import type { JournalEntry } from '../entities/journalEntry'
import type { JournalRepository } from '../repositories/journalRepository'

export function addJournalEntry(
  repository: JournalRepository,
  entry: JournalEntry,
): Promise<Result<void>> {
  return repository.addEntry(entry)
}
