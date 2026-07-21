/// Hard business constraints for the SmartTrade App MVP.
///
/// These are intentionally hard-coded, not configuration: the product
/// requirement is a fixed "Golden Rule", not a user preference.
abstract final class TradingConstants {
  /// Regra de Ouro: every futures order the Boleta Inteligente builds is
  /// locked to exactly one contract. The calculator's job is to surface
  /// the financial risk that single contract carries, never to size up.
  static const int fixedFuturesContractQuantity = 1;

  /// Forex is not bound by the one-contract rule: lot size is
  /// user-adjustable in fractional steps (e.g. micro lots).
  static const double defaultForexLotSize = 0.01;
  static const double minForexLotSize = 0.01;
  static const double forexLotStep = 0.01;

  /// Below this R:R the ticket UI flags the trade as poor value.
  static const double minHealthyRiskRewardRatio = 1.5;
}
