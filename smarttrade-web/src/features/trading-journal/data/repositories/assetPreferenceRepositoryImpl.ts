import { DatabaseFailure } from '@/core/error/failure'
import { err, ok, type Result } from '@/core/result/result'
import type { AssetPreference } from '../../domain/entities/assetPreference'
import type { AssetPreferenceRepository } from '../../domain/repositories/assetPreferenceRepository'
import { assetPreferenceLocalDataSource } from '../datasources/assetPreferenceLocalDataSource'

export class AssetPreferenceRepositoryImpl implements AssetPreferenceRepository {
  async getAll(): Promise<Result<AssetPreference[]>> {
    try {
      return ok(await assetPreferenceLocalDataSource.getAll())
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao carregar preferências: ${error}`))
    }
  }

  async save(preference: AssetPreference): Promise<Result<void>> {
    try {
      await assetPreferenceLocalDataSource.save(preference)
      return ok(undefined)
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao salvar preferência: ${error}`))
    }
  }
}

export const assetPreferenceRepository: AssetPreferenceRepository =
  new AssetPreferenceRepositoryImpl()
