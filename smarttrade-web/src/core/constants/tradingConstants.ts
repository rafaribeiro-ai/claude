/**
 * Hard business constraints for the SmartTrade App MVP.
 *
 * These are intentionally hard-coded, not configuration: the product
 * requirement is a fixed "Golden Rule", not a user preference.
 */
export const TradingConstants = {
  /**
   * Regra de Ouro: every futures order the Boleta Inteligente builds is
   * locked to exactly one contract. The calculator's job is to surface
   * the financial risk that single contract carries, never to size up.
   */
  fixedFuturesContractQuantity: 1,

  /** Forex is not bound by the one-contract rule: lot size is adjustable. */
  defaultForexLotSize: 0.01,
  minForexLotSize: 0.01,
  forexLotStep: 0.01,

  /** Below this R:R the ticket UI flags the trade as poor value. */
  minHealthyRiskRewardRatio: 1.5,
} as const
