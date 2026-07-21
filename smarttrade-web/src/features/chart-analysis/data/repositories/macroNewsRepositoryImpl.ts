import { ok, type Result } from '@/core/result/result'
import type { MacroNewsHeadline } from '../../domain/entities/macroNewsHeadline'
import type { MacroNewsRepository } from '../../domain/repositories/macroNewsRepository'

/**
 * Placeholder implementation: returns a fixed sample so the ticker has
 * something to scroll in the MVP. Replace with a data source that hits
 * a real macroeconomic calendar/news API once one is chosen.
 */
export class MacroNewsRepositoryImpl implements MacroNewsRepository {
  async getLatestHeadlines(): Promise<Result<MacroNewsHeadline[]>> {
    const now = new Date()
    return ok([
      {
        headline: 'FOMC mantém juros; mercado aguarda fala de Powell.',
        impact: 'high',
        publishedAt: now,
      },
      {
        headline: 'CPI dos EUA em linha com o consenso.',
        impact: 'medium',
        publishedAt: now,
      },
      {
        headline: 'Payroll acima do esperado pressiona yields.',
        impact: 'high',
        publishedAt: now,
      },
      {
        headline: 'Feed de dados macro em desenvolvimento.',
        impact: 'low',
        publishedAt: now,
      },
    ])
  }
}

export const macroNewsRepository: MacroNewsRepository = new MacroNewsRepositoryImpl()
