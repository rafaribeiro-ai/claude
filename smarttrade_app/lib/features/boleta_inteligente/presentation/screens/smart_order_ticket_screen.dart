import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/app/theme/app_text_styles.dart';
import 'package:smarttrade_app/core/constants/trading_constants.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/providers/boleta_notifier.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/widgets/instrument_selector.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/widgets/locked_contract_badge.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/widgets/risk_summary_panel.dart';

/// "Boleta Inteligente" - the Smart Order Ticket. The MVP's core screen:
/// pick an instrument, set direction/entry/stop/target, and watch the
/// exact dollar risk and reward update live underneath.
class SmartOrderTicketScreen extends HookConsumerWidget {
  const SmartOrderTicketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryController = useTextEditingController();
    final stopController = useTextEditingController();
    final targetController = useTextEditingController();
    final lotController = useTextEditingController(
      text: TradingConstants.defaultForexLotSize.toString(),
    );

    final asyncState = ref.watch(boletaNotifierProvider);
    final notifier = ref.read(boletaNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Boleta Inteligente')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Não foi possível carregar os instrumentos.',
            style: const TextStyle(color: AppColors.loss),
          ),
        ),
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InstrumentSelector(
                  instruments: state.instruments,
                  selected: state.selectedInstrument,
                  onChanged: notifier.selectInstrument,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('DIREÇÃO', style: AppTextStyles.sectionLabel),
                    const Spacer(),
                    if (state.isFuturesSelected) const LockedContractBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                _DirectionToggle(
                  direction: state.direction,
                  onChanged: notifier.setDirection,
                ),
                const SizedBox(height: 16),
                _PriceField(
                  label: 'Entrada',
                  controller: entryController,
                  onChanged: (v) => notifier.setEntryPrice(double.tryParse(v)),
                ),
                const SizedBox(height: 12),
                _PriceField(
                  label: 'Stop Loss',
                  controller: stopController,
                  onChanged: (v) => notifier.setStopPrice(double.tryParse(v)),
                ),
                const SizedBox(height: 12),
                _PriceField(
                  label: 'Alvo (Take Profit)',
                  controller: targetController,
                  onChanged: (v) => notifier.setTargetPrice(double.tryParse(v)),
                ),
                if (state.isForexSelected) ...[
                  const SizedBox(height: 12),
                  _PriceField(
                    label: 'Tamanho do Lote',
                    controller: lotController,
                    onChanged: (v) {
                      final parsed = double.tryParse(v);
                      if (parsed != null) notifier.setForexLotSize(parsed);
                    },
                  ),
                ],
                const SizedBox(height: 20),
                RiskSummaryPanel(calculation: state.calculation),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DirectionToggle extends StatelessWidget {
  const _DirectionToggle({required this.direction, required this.onChanged});

  final TradeDirection direction;
  final ValueChanged<TradeDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TradeDirection>(
      segments: const [
        ButtonSegment(
          value: TradeDirection.long,
          label: Text('COMPRA'),
          icon: Icon(Icons.arrow_upward, size: 16),
        ),
        ButtonSegment(
          value: TradeDirection.short,
          label: Text('VENDA'),
          icon: Icon(Icons.arrow_downward, size: 16),
        ),
      ],
      selected: {direction},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.monoValueSmall,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
}
