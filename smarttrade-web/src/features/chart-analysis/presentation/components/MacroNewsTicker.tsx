import type { MacroImpact, MacroNewsHeadline } from '../../domain/entities/macroNewsHeadline'

interface MacroNewsTickerProps {
  headlines: MacroNewsHeadline[]
}

const IMPACT_COLOR_CLASS: Record<MacroImpact, string> = {
  high: 'bg-loss',
  medium: 'bg-warning',
  low: 'bg-text-disabled',
}

/**
 * Fixed-height strip reserved at the bottom of the chart screen for a
 * scrolling news-ticker ("tarja") of macroeconomic headlines.
 *
 * Data comes from `MacroNewsRepository`, which is a placeholder today
 * (see `data/repositories/macroNewsRepositoryImpl.ts`); this component
 * only owns the scrolling presentation so wiring in a live feed later is
 * a data-layer change.
 */
export function MacroNewsTicker({ headlines }: MacroNewsTickerProps) {
  if (headlines.length === 0) {
    return (
      <div className="flex h-9 shrink-0 items-center bg-ticker-bg px-3 text-xs text-text-disabled">
        Tarja macroeconômica: aguardando dados.
      </div>
    )
  }

  return (
    <div className="flex h-9 shrink-0 items-stretch overflow-hidden bg-ticker-bg">
      <div className="flex shrink-0 items-center bg-surface-elevated px-2.5 text-[11px] font-bold tracking-wide text-text-secondary">
        MACRO
      </div>
      <div className="relative flex-1 overflow-hidden">
        <div className="animate-ticker-scroll absolute inset-y-0 flex items-center gap-8 whitespace-nowrap">
          {[...headlines, ...headlines].map((item, index) => (
            <span key={index} className="flex items-center gap-1.5 text-xs text-text-primary">
              <span className={`h-1.5 w-1.5 shrink-0 rounded-full ${IMPACT_COLOR_CLASS[item.impact]}`} />
              {item.headline}
            </span>
          ))}
        </div>
      </div>
    </div>
  )
}
