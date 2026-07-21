import type { Result } from '@/core/result/result'
import type { JournalEntry } from '../entities/journalEntry'

export interface JournalRepository {
  getEntries(): Promise<Result<JournalEntry[]>>
  addEntry(entry: JournalEntry): Promise<Result<void>>
  deleteEntry(id: string): Promise<Result<void>>
}
