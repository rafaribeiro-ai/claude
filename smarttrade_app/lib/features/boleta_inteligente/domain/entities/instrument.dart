import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/core/constants/trading_constants.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/market_type.dart';

/// A tradable instrument the Boleta Inteligente can build an order for.
///
/// Sealed so [CalculatePositionRiskUseCase] can `switch` over the two
/// pricing models exhaustively, with the compiler catching a missing
/// case if a third market type is ever added.
sealed class Instrument extends Equatable {
  const Instrument({
    required this.symbol,
    required this.displayName,
    required this.exchange,
  });

  final String symbol;
  final String displayName;
  final String exchange;

  MarketType get marketType;
}

/// A futures contract (e.g. Nasdaq-100 E-mini/Micro). Priced in
/// ticks/points, each with a fixed dollar value per single contract.
class FuturesInstrument extends Instrument {
  const FuturesInstrument({
    required super.symbol,
    required super.displayName,
    required super.exchange,
    required this.tickSize,
    required this.tickValue,
  });

  /// Smallest price increment the instrument trades in (e.g. 0.25 pts).
  final double tickSize;

  /// Dollar value of one tick move, for exactly one contract.
  final double tickValue;

  /// Dollar value of one full point of price movement, one contract.
  double get valuePerPoint => tickValue / tickSize;

  @override
  MarketType get marketType => MarketType.futures;

  @override
  List<Object?> get props =>
      [symbol, displayName, exchange, tickSize, tickValue];
}

/// A forex/metals spot pair (e.g. XAU/USD). Priced in pips, with lot
/// size freely adjustable (including fractional/micro lots) since the
/// one-contract Golden Rule only applies to the futures market.
class ForexInstrument extends Instrument {
  const ForexInstrument({
    required super.symbol,
    required super.displayName,
    required super.exchange,
    required this.pipSize,
    required this.contractSize,
    this.minLot = TradingConstants.minForexLotSize,
    this.lotStep = TradingConstants.forexLotStep,
  });

  /// Smallest quoted price increment considered "one pip" (e.g. 0.01).
  final double pipSize;

  /// Units of the base asset represented by one standard lot (1.0).
  final double contractSize;

  final double minLot;
  final double lotStep;

  @override
  MarketType get marketType => MarketType.forex;

  @override
  List<Object?> get props =>
      [symbol, displayName, exchange, pipSize, contractSize, minLot, lotStep];
}
