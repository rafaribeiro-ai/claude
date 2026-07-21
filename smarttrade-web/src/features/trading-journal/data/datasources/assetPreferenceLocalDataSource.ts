import { db } from '@/core/persistence/db'
import type { AssetPreference } from '../../domain/entities/assetPreference'

export const assetPreferenceLocalDataSource = {
  async getAll(): Promise<AssetPreference[]> {
    return db.assetPreferences.orderBy('displayOrder').toArray()
  },

  async save(preference: AssetPreference): Promise<void> {
    await db.assetPreferences.put(preference)
  },
}
