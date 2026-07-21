import { db } from '@/core/persistence/db'
import type { JournalEntry } from '../../domain/entities/journalEntry'

export const journalLocalDataSource = {
  async getEntries(): Promise<JournalEntry[]> {
    return db.journalEntries.reverse().sortBy('openedAt')
  },

  async addEntry(entry: JournalEntry): Promise<void> {
    await db.journalEntries.put(entry)
  },

  async deleteEntry(id: string): Promise<void> {
    await db.journalEntries.delete(id)
  },
}
