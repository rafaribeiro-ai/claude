import 'package:flutter/material.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/core/constants/trading_constants.dart';

/// Visible, unmissable confirmation that the Golden Rule is active: the
/// futures side of the ticket is locked to a single contract and cannot
/// be edited from this screen.
class LockedContractBadge extends StatelessWidget {
  const LockedContractBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            '${TradingConstants.fixedFuturesContractQuantity} CONTRATO '
            '(Regra de Ouro)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
