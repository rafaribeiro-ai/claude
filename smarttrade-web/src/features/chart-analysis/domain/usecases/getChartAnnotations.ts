import type { Result } from '@/core/result/result'
import type { ChartAnnotation } from '../entities/chartAnnotation'
import type { ChartAnnotationRepository } from '../repositories/chartAnnotationRepository'

export function getChartAnnotations(
  repository: ChartAnnotationRepository,
  instrumentSymbol: string,
): Promise<Result<ChartAnnotation[]>> {
  return repository.getAnnotations(instrumentSymbol)
}
