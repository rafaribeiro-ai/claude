import type { Result } from '@/core/result/result'
import type { MacroNewsHeadline } from '../entities/macroNewsHeadline'

/**
 * Feeds the bottom news ticker. No real implementation ships in the
 * MVP - see `data/repositories/macroNewsRepositoryImpl.ts` for the
 * placeholder - but the chart screen already depends on this interface
 * so wiring in a live macro calendar/news API later doesn't touch
 * presentation code.
 */
export interface MacroNewsRepository {
  getLatestHeadlines(): Promise<Result<MacroNewsHeadline[]>>
}
