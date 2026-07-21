import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/core/constants/trading_constants.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/risk_calculation.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';

class CalculatePositionRiskParams extends Equatable {
  const CalculatePositionRiskParams({
    required this.instrument,
    required this.direction,
    required this.entryPrice,
    required this.stopPrice,
    required this.targetPrice,
    this.desiredForexLotSize,
  });

  final Instrument instrument;
  final TradeDirection direction;
  final double entryPrice;
  final double stopPrice;
  final double targetPrice;

  /// Only consulted for [ForexInstrument]. Ignored for futures: the
  /// Golden Rule fixes the contract count regardless of what is passed
  /// here, so there is no `desiredFuturesQuantity` field at all.
  final double? desiredForexLotSize;

  @override
  List<Object?> get props => [
        instrument,
        direction,
        entryPrice,
        stopPrice,
        targetPrice,
        desiredForexLotSize,
      ];
}

/// Core domain logic of the "Boleta Inteligente".
///
/// Golden Rule: futures orders are always sized at exactly
/// [TradingConstants.fixedFuturesContractQuantity] (1) contract. This use
/// case never reads a user-supplied futures quantity because the params
/// object doesn't expose one - the lock is structural, not just a
/// runtime check. Its entire job for futures is to translate the Stop
/// Loss distance into the exact dollar risk that single contract carries.
///
/// Forex/metals pairs (e.g. XAU/USD) are priced in pips and support
/// fractional lot sizing for users who don't trade futures.
class CalculatePositionRiskUseCase
    implements SyncUseCase<RiskCalculation, CalculatePositionRiskParams> {
  const CalculatePositionRiskUseCase();

  @override
  Either<Failure, RiskCalculation> call(CalculatePositionRiskParams params) {
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    final stopDistance = (params.entryPrice - params.stopPrice).abs();
    final targetDistance = (params.targetPrice - params.entryPrice).abs();

    final (positionSize, riskAmount, rewardAmount) = switch (params.instrument) {
      FuturesInstrument f => _calculateFutures(f, stopDistance, targetDistance),
      ForexInstrument x => _calculateForex(
          x,
          stopDistance,
          targetDistance,
          params.desiredForexLotSize,
        ),
    };

    final riskRewardRatio = riskAmount == 0 ? 0.0 : rewardAmount / riskAmount;

    return Right(
      RiskCalculation(
        instrument: params.instrument,
        direction: params.direction,
        entryPrice: params.entryPrice,
        stopPrice: params.stopPrice,
        targetPrice: params.targetPrice,
        positionSize: positionSize,
        stopDistance: stopDistance,
        targetDistance: targetDistance,
        riskAmount: riskAmount,
        rewardAmount: rewardAmount,
        riskRewardRatio: riskRewardRatio,
      ),
    );
  }

  (double, double, double) _calculateFutures(
    FuturesInstrument instrument,
    double stopDistance,
    double targetDistance,
  ) {
    // Regra de Ouro: sempre 1 contrato. Not a default, not clamped from
    // user input - this is the only value ever used here.
    const positionSize = TradingConstants.fixedFuturesContractQuantity;
    final riskAmount = stopDistance * instrument.valuePerPoint * positionSize;
    final rewardAmount =
        targetDistance * instrument.valuePerPoint * positionSize;
    return (positionSize.toDouble(), riskAmount, rewardAmount);
  }

  (double, double, double) _calculateForex(
    ForexInstrument instrument,
    double stopDistance,
    double targetDistance,
    double? desiredLotSize,
  ) {
    final requested = desiredLotSize ?? TradingConstants.defaultForexLotSize;
    final steps = (requested / instrument.lotStep).round();
    final snapped = steps * instrument.lotStep;
    final lotSize = snapped < instrument.minLot ? instrument.minLot : snapped;

    final riskAmount = stopDistance * instrument.contractSize * lotSize;
    final rewardAmount = targetDistance * instrument.contractSize * lotSize;
    return (lotSize, riskAmount, rewardAmount);
  }

  Failure? _validate(CalculatePositionRiskParams params) {
    if (params.entryPrice <= 0 ||
        params.stopPrice <= 0 ||
        params.targetPrice <= 0) {
      return const InvalidTradeParametersFailure(
        'Preços de entrada, stop e alvo devem ser maiores que zero.',
      );
    }

    if (params.stopPrice == params.entryPrice) {
      return const InvalidTradeParametersFailure(
        'O Stop Loss não pode ser igual ao preço de entrada.',
      );
    }

    final isLong = params.direction == TradeDirection.long;
    final stopOnCorrectSide = isLong
        ? params.stopPrice < params.entryPrice
        : params.stopPrice > params.entryPrice;
    final targetOnCorrectSide = isLong
        ? params.targetPrice > params.entryPrice
        : params.targetPrice < params.entryPrice;

    if (!stopOnCorrectSide) {
      return InvalidTradeParametersFailure(
        isLong
            ? 'Em uma operação comprada, o Stop Loss deve ficar abaixo da entrada.'
            : 'Em uma operação vendida, o Stop Loss deve ficar acima da entrada.',
      );
    }

    if (!targetOnCorrectSide) {
      return InvalidTradeParametersFailure(
        isLong
            ? 'Em uma operação comprada, o alvo deve ficar acima da entrada.'
            : 'Em uma operação vendida, o alvo deve ficar abaixo da entrada.',
      );
    }

    return null;
  }
}
