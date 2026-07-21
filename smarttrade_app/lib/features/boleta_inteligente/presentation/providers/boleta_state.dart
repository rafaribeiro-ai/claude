import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/constants/trading_constants.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/risk_calculation.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';

/// Sentinel used by [BoletaState.copyWith] so `null` can be passed as a
/// real, explicit value (e.g. "clear the target price") instead of
/// meaning "leave this field untouched".
const Object _unset = Object();

/// Everything the Smart Order Ticket screen needs to render, kept as one
/// immutable snapshot so [BoletaState.calculation] is always recomputed
/// atomically with whichever field just changed.
class BoletaState {
  const BoletaState({
    required this.instruments,
    required this.direction,
    required this.forexLotSize,
    this.selectedInstrument,
    this.entryPrice,
    this.stopPrice,
    this.targetPrice,
    this.calculation,
  });

  factory BoletaState.initial(List<Instrument> instruments) => BoletaState(
        instruments: instruments,
        direction: TradeDirection.long,
        forexLotSize: TradingConstants.defaultForexLotSize,
        selectedInstrument:
            instruments.isNotEmpty ? instruments.first : null,
      );

  final List<Instrument> instruments;
  final Instrument? selectedInstrument;
  final TradeDirection direction;
  final double? entryPrice;
  final double? stopPrice;
  final double? targetPrice;
  final double forexLotSize;

  /// `null` until entry/stop/target are all filled in; then recomputed on
  /// every keystroke for the dynamic Risk/Reward calculation.
  final Either<Failure, RiskCalculation>? calculation;

  bool get isForexSelected => selectedInstrument is ForexInstrument;
  bool get isFuturesSelected => selectedInstrument is FuturesInstrument;

  BoletaState copyWith({
    List<Instrument>? instruments,
    Object? selectedInstrument = _unset,
    TradeDirection? direction,
    Object? entryPrice = _unset,
    Object? stopPrice = _unset,
    Object? targetPrice = _unset,
    double? forexLotSize,
    Object? calculation = _unset,
  }) {
    return BoletaState(
      instruments: instruments ?? this.instruments,
      selectedInstrument: identical(selectedInstrument, _unset)
          ? this.selectedInstrument
          : selectedInstrument as Instrument?,
      direction: direction ?? this.direction,
      entryPrice: identical(entryPrice, _unset)
          ? this.entryPrice
          : entryPrice as double?,
      stopPrice: identical(stopPrice, _unset)
          ? this.stopPrice
          : stopPrice as double?,
      targetPrice: identical(targetPrice, _unset)
          ? this.targetPrice
          : targetPrice as double?,
      forexLotSize: forexLotSize ?? this.forexLotSize,
      calculation: identical(calculation, _unset)
          ? this.calculation
          : calculation as Either<Failure, RiskCalculation>?,
    );
  }
}
