export type MacroImpact = 'low' | 'medium' | 'high'

/**
 * One line of the bottom news ticker. Placeholder shape for the
 * macroeconomic data feed the ticker will eventually consume (CPI,
 * FOMC, NFP, etc.) - the MVP only needs the UI to reserve the space and
 * render this shape, not a real feed.
 */
export interface MacroNewsHeadline {
  headline: string
  impact: MacroImpact
  publishedAt: Date
}
