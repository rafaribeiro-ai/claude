import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/trade_outcome.dart';

/// One row of the offline "Diário de Trading". Typically created from a
/// [RiskCalculation] the Boleta Inteligente produced, so the risk figures
/// the user actually saw before entering are preserved even if contract
/// specs change later.
class JournalEntry extends Equatable {
  const JournalEntry({
    required this.id,
    required this.instrumentSymbol,
    required this.direction,
    required this.entryPrice,
    required this.stopPrice,
    required this.targetPrice,
    required this.riskAmount,
    required this.rewardAmount,
    required this.riskRewardRatio,
    required this.positionSize,
    required this.outcome,
    required this.openedAt,
    this.notes,
    this.closedAt,
  });

  final String id;
  final String instrumentSymbol;
  final TradeDirection direction;
  final double entryPrice;
  final double stopPrice;
  final double targetPrice;
  final double riskAmount;
  final double rewardAmount;
  final double riskRewardRatio;
  final double positionSize;
  final TradeOutcome outcome;
  final DateTime openedAt;
  final String? notes;
  final DateTime? closedAt;

  JournalEntry copyWith({TradeOutcome? outcome, DateTime? closedAt, String? notes}) {
    return JournalEntry(
      id: id,
      instrumentSymbol: instrumentSymbol,
      direction: direction,
      entryPrice: entryPrice,
      stopPrice: stopPrice,
      targetPrice: targetPrice,
      riskAmount: riskAmount,
      rewardAmount: rewardAmount,
      riskRewardRatio: riskRewardRatio,
      positionSize: positionSize,
      outcome: outcome ?? this.outcome,
      openedAt: openedAt,
      notes: notes ?? this.notes,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        instrumentSymbol,
        direction,
        entryPrice,
        stopPrice,
        targetPrice,
        riskAmount,
        rewardAmount,
        riskRewardRatio,
        positionSize,
        outcome,
        openedAt,
        notes,
        closedAt,
      ];
}
