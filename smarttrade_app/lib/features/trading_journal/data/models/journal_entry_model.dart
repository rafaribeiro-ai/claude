import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/trade_outcome.dart';

abstract final class JournalEntryModel {
  static Map<String, Object?> toMap(JournalEntry entry) {
    return {
      'id': entry.id,
      'instrument_symbol': entry.instrumentSymbol,
      'direction': entry.direction.name,
      'entry_price': entry.entryPrice,
      'stop_price': entry.stopPrice,
      'target_price': entry.targetPrice,
      'risk_amount': entry.riskAmount,
      'reward_amount': entry.rewardAmount,
      'risk_reward_ratio': entry.riskRewardRatio,
      'position_size': entry.positionSize,
      'outcome': entry.outcome.name,
      'notes': entry.notes,
      'opened_at': entry.openedAt.toIso8601String(),
      'closed_at': entry.closedAt?.toIso8601String(),
    };
  }

  static JournalEntry fromMap(Map<String, Object?> map) {
    final closedAt = map['closed_at'] as String?;
    return JournalEntry(
      id: map['id'] as String,
      instrumentSymbol: map['instrument_symbol'] as String,
      direction: TradeDirection.values.byName(map['direction'] as String),
      entryPrice: map['entry_price'] as double,
      stopPrice: map['stop_price'] as double,
      targetPrice: map['target_price'] as double,
      riskAmount: map['risk_amount'] as double,
      rewardAmount: map['reward_amount'] as double,
      riskRewardRatio: map['risk_reward_ratio'] as double,
      positionSize: map['position_size'] as double,
      outcome: TradeOutcome.values.byName(map['outcome'] as String),
      notes: map['notes'] as String?,
      openedAt: DateTime.parse(map['opened_at'] as String),
      closedAt: closedAt == null ? null : DateTime.parse(closedAt),
    );
  }
}
