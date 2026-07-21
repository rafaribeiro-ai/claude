import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/core/utils/currency_formatter.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/trade_outcome.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final isLong = entry.direction == TradeDirection.long;
    final directionColor = isLong ? AppColors.longPosition : AppColors.shortPosition;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLong ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: directionColor,
                ),
                const SizedBox(width: 6),
                Text(
                  entry.instrumentSymbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _OutcomeBadge(outcome: entry.outcome),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Metric(label: 'Risco', value: CurrencyFormatter.usd(entry.riskAmount), color: AppColors.loss),
                const SizedBox(width: 16),
                _Metric(label: 'Retorno', value: CurrencyFormatter.usd(entry.rewardAmount), color: AppColors.profit),
                const SizedBox(width: 16),
                _Metric(label: 'R:R', value: '1:${entry.riskRewardRatio.toStringAsFixed(2)}', color: AppColors.textPrimary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(entry.openedAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(entry.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

class _OutcomeBadge extends StatelessWidget {
  const _OutcomeBadge({required this.outcome});

  final TradeOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (outcome) {
      TradeOutcome.open => ('ABERTA', AppColors.accent),
      TradeOutcome.win => ('GANHO', AppColors.profit),
      TradeOutcome.loss => ('PERDA', AppColors.loss),
      TradeOutcome.breakeven => ('EMPATE', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
