import { db } from '@/core/persistence/db'
import type { ChartAnnotation } from '../../domain/entities/chartAnnotation'

export const chartAnnotationLocalDataSource = {
  async getAnnotations(instrumentSymbol: string): Promise<ChartAnnotation[]> {
    return db.chartAnnotations
      .where('instrumentSymbol')
      .equals(instrumentSymbol)
      .reverse()
      .sortBy('createdAt')
  },

  async saveAnnotation(annotation: ChartAnnotation): Promise<void> {
    await db.chartAnnotations.put(annotation)
  },

  async deleteAnnotation(id: string): Promise<void> {
    await db.chartAnnotations.delete(id)
  },
}
