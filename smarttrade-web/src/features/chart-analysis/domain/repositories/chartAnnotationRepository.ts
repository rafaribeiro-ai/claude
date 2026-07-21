import type { Result } from '@/core/result/result'
import type { ChartAnnotation } from '../entities/chartAnnotation'

export interface ChartAnnotationRepository {
  getAnnotations(instrumentSymbol: string): Promise<Result<ChartAnnotation[]>>
  saveAnnotation(annotation: ChartAnnotation): Promise<Result<void>>
  deleteAnnotation(id: string): Promise<Result<void>>
}
