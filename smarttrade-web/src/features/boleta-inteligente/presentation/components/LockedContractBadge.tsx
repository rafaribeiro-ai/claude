import { TradingConstants } from '@/core/constants/tradingConstants'

/**
 * Visible, unmissable confirmation that the Golden Rule is active: the
 * futures side of the ticket is locked to a single contract and cannot
 * be edited from this screen.
 */
export function LockedContractBadge() {
  return (
    <div className="flex items-center gap-2 rounded-lg border border-accent/40 bg-accent-muted px-3 py-1.5">
      <svg
        aria-hidden="true"
        viewBox="0 0 20 20"
        className="h-4 w-4 fill-none stroke-accent stroke-2"
      >
        <rect x="4" y="9" width="12" height="8" rx="1.5" />
        <path d="M7 9V6a3 3 0 0 1 6 0v3" />
      </svg>
      <span className="text-xs font-bold tracking-wide text-accent">
        {TradingConstants.fixedFuturesContractQuantity} CONTRATO (Regra de Ouro)
      </span>
    </div>
  )
}
