import { DatabaseFailure } from '@/core/error/failure'
import { err, ok, type Result } from '@/core/result/result'
import type { ChartAnnotation } from '../../domain/entities/chartAnnotation'
import type { ChartAnnotationRepository } from '../../domain/repositories/chartAnnotationRepository'
import { chartAnnotationLocalDataSource } from '../datasources/chartAnnotationLocalDataSource'

export class ChartAnnotationRepositoryImpl implements ChartAnnotationRepository {
  async getAnnotations(instrumentSymbol: string): Promise<Result<ChartAnnotation[]>> {
    try {
      return ok(await chartAnnotationLocalDataSource.getAnnotations(instrumentSymbol))
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao carregar marcações: ${error}`))
    }
  }

  async saveAnnotation(annotation: ChartAnnotation): Promise<Result<void>> {
    try {
      await chartAnnotationLocalDataSource.saveAnnotation(annotation)
      return ok(undefined)
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao salvar marcação: ${error}`))
    }
  }

  async deleteAnnotation(id: string): Promise<Result<void>> {
    try {
      await chartAnnotationLocalDataSource.deleteAnnotation(id)
      return ok(undefined)
    } catch (error) {
      return err(new DatabaseFailure(`Falha ao remover marcação: ${error}`))
    }
  }
}

export const chartAnnotationRepository: ChartAnnotationRepository =
  new ChartAnnotationRepositoryImpl()
