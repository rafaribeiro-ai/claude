import { create } from 'zustand'
import type { Result } from '@/core/result/result'
import { journalRepository } from '../../data/repositories/journalRepositoryImpl'
import type { JournalEntry } from '../../domain/entities/journalEntry'
import { addJournalEntry } from '../../domain/usecases/addJournalEntry'
import { getJournalEntries } from '../../domain/usecases/getJournalEntries'

interface JournalState {
  entries: JournalEntry[]
  loading: boolean
  loadEntries: () => Promise<void>
  addEntry: (entry: JournalEntry) => Promise<Result<void>>
}

/**
 * "Diário de Trading" state. New entries are typically built straight
 * from a completed Boleta Inteligente calculation, so the risk math
 * shown here always matches what the user saw before pulling the
 * trigger.
 */
export const useJournalStore = create<JournalState>((set, get) => ({
  entries: [],
  loading: true,

  loadEntries: async () => {
    const result = await getJournalEntries(journalRepository)
    if (result.ok) {
      set({ entries: result.value, loading: false })
    } else {
      set({ entries: [], loading: false })
    }
  },

  addEntry: async (entry) => {
    const result = await addJournalEntry(journalRepository, entry)
    if (result.ok) {
      set({ entries: [entry, ...get().entries] })
    }
    return result
  },
}))
