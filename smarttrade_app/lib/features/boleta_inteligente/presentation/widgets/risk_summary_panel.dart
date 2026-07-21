import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/app/theme/app_text_styles.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/core/utils/currency_formatter.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/risk_calculation.dart';

/// The payoff of the whole ticket: exact dollar risk and reward for the
/// single position the Golden Rule allows, recomputed live as the user
/// edits entry/stop/target.
class RiskSummaryPanel extends StatelessWidget {
  const RiskSummaryPanel({super.key, required this.calculation});

  final Either<Failure, RiskCalculation>? calculation;

  @override
  Widget build(BuildContext context) {
    final result = calculation;

    if (result == null) {
      return _EmptyState();
    }

    return result.fold(
      (failure) => _ErrorState(message: failure.message),
      (calc) => _ResultState(calculation: calc),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Preencha entrada, stop e alvo para calcular o risco.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.loss.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.loss.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.loss, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.loss)),
          ),
        ],
      ),
    );
  }
}

class _ResultState extends StatelessWidget {
  const _ResultState({required this.calculation});

  final RiskCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final isFutures = calculation.instrument is FuturesInstrument;
    final ratioColor = calculation.isHealthyRiskReward
        ? AppColors.profit
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RESUMO DE RISCO', style: AppTextStyles.sectionLabel),
              Text(
                isFutures
                    ? '1 contrato'
                    : '${calculation.positionSize.toStringAsFixed(2)} lote(s)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AmountColumn(
                  label: 'Risco (\$)',
                  value: CurrencyFormatter.usd(calculation.riskAmount),
                  color: AppColors.loss,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountColumn(
                  label: 'Retorno (\$)',
                  value: CurrencyFormatter.usd(calculation.rewardAmount),
                  color: AppColors.profit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Relação Risco/Retorno', style: AppTextStyles.body),
              Text(
                '1 : ${calculation.riskRewardRatio.toStringAsFixed(2)}',
                style: AppTextStyles.monoValueSmall.copyWith(color: ratioColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.monoValue.copyWith(color: color)),
      ],
    );
  }
}
