import 'package:flutter/material.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/app/theme/app_text_styles.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/market_type.dart';

class InstrumentSelector extends StatelessWidget {
  const InstrumentSelector({
    super.key,
    required this.instruments,
    required this.selected,
    required this.onChanged,
  });

  final List<Instrument> instruments;
  final Instrument? selected;
  final ValueChanged<Instrument> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ATIVO', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Instrument>(
              value: selected,
              isExpanded: true,
              dropdownColor: AppColors.surfaceElevated,
              icon: const Icon(Icons.expand_more, color: AppColors.textSecondary),
              items: [
                for (final instrument in instruments)
                  DropdownMenuItem(
                    value: instrument,
                    child: _InstrumentRow(instrument: instrument),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _InstrumentRow extends StatelessWidget {
  const _InstrumentRow({required this.instrument});

  final Instrument instrument;

  @override
  Widget build(BuildContext context) {
    final isFutures = instrument.marketType == MarketType.futures;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isFutures ? AppColors.accentMuted : AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              isFutures ? 'FUT' : 'FX',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isFutures ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            instrument.symbol,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              instrument.displayName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
