import type { Result } from '@/core/result/result'
import type { AssetPreference } from '../entities/assetPreference'

export interface AssetPreferenceRepository {
  getAll(): Promise<Result<AssetPreference[]>>
  save(preference: AssetPreference): Promise<Result<void>>
}
