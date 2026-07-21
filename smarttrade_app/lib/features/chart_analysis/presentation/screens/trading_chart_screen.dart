import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/app/theme/app_text_styles.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/providers/instrument_providers.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_display_mode.dart';
import 'package:smarttrade_app/features/chart_analysis/presentation/providers/chart_providers.dart';
import 'package:smarttrade_app/features/chart_analysis/presentation/widgets/macro_news_ticker.dart';

/// Chart screen for technical study. Reuses the instrument catalog
/// exposed by the Boleta Inteligente's domain layer (a shared domain
/// concept, not a presentation widget) so both screens always agree on
/// which instruments exist.
class TradingChartScreen extends HookConsumerWidget {
  const TradingChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMode = useState(ChartDisplayMode.timeBased);
    final instrumentsAsync = ref.watch(availableInstrumentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gráfico')),
      body: instrumentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text(
            'Não foi possível carregar os instrumentos.',
            style: TextStyle(color: AppColors.loss),
          ),
        ),
        data: (instruments) {
          if (instruments.isEmpty) {
            return const SizedBox.shrink();
          }

          final symbol = instruments.first.symbol;
          final candles = ref.watch(sampleCandlesProvider(symbol));
          final engine = ref.watch(chartEngineProvider);
          final annotationsAsync = ref.watch(chartAnnotationsProvider(symbol));
          final headlinesAsync = ref.watch(macroNewsHeadlinesProvider);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(symbol, style: AppTextStyles.screenTitle),
                    SegmentedButton<ChartDisplayMode>(
                      segments: const [
                        ButtonSegment(
                          value: ChartDisplayMode.timeBased,
                          label: Text('Tempo'),
                        ),
                        ButtonSegment(
                          value: ChartDisplayMode.renko,
                          label: Text('Renko'),
                        ),
                      ],
                      selected: {displayMode.value},
                      onSelectionChanged: (s) => displayMode.value = s.first,
                    ),
                  ],
                ),
              ),
              annotationsAsync.when(
                data: (annotations) => annotations.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${annotations.length} marcação(ões) salva(s)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: engine.buildChart(
                    candles: candles,
                    mode: displayMode.value,
                  ),
                ),
              ),
              headlinesAsync.when(
                data: (headlines) => MacroNewsTicker(headlines: headlines),
                loading: () => const MacroNewsTicker(headlines: []),
                error: (_, _) => const MacroNewsTicker(headlines: []),
              ),
            ],
          );
        },
      ),
    );
  }
}
