import Dexie, { type EntityTable } from 'dexie'
import type { ChartAnnotation } from '@/features/chart-analysis/domain/entities/chartAnnotation'
import type { AssetPreference } from '@/features/trading-journal/domain/entities/assetPreference'
import type { JournalEntry } from '@/features/trading-journal/domain/entities/journalEntry'

/**
 * IndexedDB (via Dexie) is the browser equivalent of the sqflite
 * database a mobile build of this app would use: it persists the
 * offline "Diário de Trading", asset preferences, and chart study
 * annotations across sessions without any backend.
 *
 * Unlike a SQL row, Dexie stores structured objects directly, so the
 * `ChartAnnotation` discriminated union is persisted as-is - no JSON
 * packing/unpacking of type-specific fields is needed the way a sqlite
 * schema would require.
 */
class SmartTradeDatabase extends Dexie {
  journalEntries!: EntityTable<JournalEntry, 'id'>
  assetPreferences!: EntityTable<AssetPreference, 'instrumentSymbol'>
  chartAnnotations!: EntityTable<ChartAnnotation, 'id'>

  constructor() {
    super('smarttrade-app')
    this.version(1).stores({
      journalEntries: 'id, instrumentSymbol, openedAt',
      assetPreferences: 'instrumentSymbol, displayOrder',
      chartAnnotations: 'id, instrumentSymbol, type, createdAt',
    })
  }
}

export const db = new SmartTradeDatabase()
