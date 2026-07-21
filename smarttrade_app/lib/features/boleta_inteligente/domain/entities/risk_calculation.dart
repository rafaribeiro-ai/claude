import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/core/constants/trading_constants.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';

/// Result of running the Boleta Inteligente's risk/reward math for one
/// instrument, direction, entry, stop and target combination.
///
/// [positionSize] is always `1` when [instrument] is a [FuturesInstrument]
/// (the Golden Rule), or the resolved lot size when it's a
/// [ForexInstrument].
class RiskCalculation extends Equatable {
  const RiskCalculation({
    required this.instrument,
    required this.direction,
    required this.entryPrice,
    required this.stopPrice,
    required this.targetPrice,
    required this.positionSize,
    required this.stopDistance,
    required this.targetDistance,
    required this.riskAmount,
    required this.rewardAmount,
    required this.riskRewardRatio,
  });

  final Instrument instrument;
  final TradeDirection direction;
  final double entryPrice;
  final double stopPrice;
  final double targetPrice;
  final double positionSize;

  /// Absolute price distance between entry and stop.
  final double stopDistance;

  /// Absolute price distance between entry and target.
  final double targetDistance;

  /// Exact financial risk, in USD, this single position carries.
  final double riskAmount;

  /// Potential financial reward, in USD, if the target is hit.
  final double rewardAmount;

  final double riskRewardRatio;

  bool get isHealthyRiskReward =>
      riskRewardRatio >= TradingConstants.minHealthyRiskRewardRatio;

  bool get isFuturesGoldenRuleLocked => instrument is FuturesInstrument;

  @override
  List<Object?> get props => [
        instrument,
        direction,
        entryPrice,
        stopPrice,
        targetPrice,
        positionSize,
        stopDistance,
        targetDistance,
        riskAmount,
        rewardAmount,
        riskRewardRatio,
      ];
}
