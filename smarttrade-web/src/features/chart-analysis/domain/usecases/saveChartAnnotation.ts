import type { Result } from '@/core/result/result'
import type { ChartAnnotation } from '../entities/chartAnnotation'
import type { ChartAnnotationRepository } from '../repositories/chartAnnotationRepository'

export function saveChartAnnotation(
  repository: ChartAnnotationRepository,
  annotation: ChartAnnotation,
): Promise<Result<void>> {
  return repository.saveAnnotation(annotation)
}
