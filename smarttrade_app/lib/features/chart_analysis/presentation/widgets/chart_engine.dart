import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/candle.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_display_mode.dart';

/// Contract the trading chart screen renders against. Swapping the MVP's
/// simple line-chart engine for a full candlestick/Renko-capable library
/// (e.g. a dedicated financial charting package) later only means
/// implementing this interface and overriding [chartEngineProvider] -
/// `TradingChartScreen` never changes.
abstract class CandleChartEngine {
  Widget buildChart({
    required List<Candle> candles,
    required ChartDisplayMode mode,
    RenkoSettings? renkoSettings,
  });
}

/// MVP engine: draws a close-price line with fl_chart. It intentionally
/// does not implement [ChartDisplayMode.renko] - fl_chart has no notion
/// of atemporal bricks - so a Renko-capable engine is a straight drop-in
/// replacement behind [CandleChartEngine], not a rewrite of this screen.
class FlChartLineEngine implements CandleChartEngine {
  const FlChartLineEngine();

  @override
  Widget buildChart({
    required List<Candle> candles,
    required ChartDisplayMode mode,
    RenkoSettings? renkoSettings,
  }) {
    if (candles.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados de preço carregados.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    if (mode == ChartDisplayMode.renko) {
      return const Center(
        child: Text(
          'Visualização Renko requer um motor de gráfico dedicado.\n'
          'Implemente CandleChartEngine para habilitá-la.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final spots = [
      for (var i = 0; i < candles.length; i++)
        FlSpot(i.toDouble(), candles[i].close),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _niceInterval(candles),
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 48),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: AppColors.accent,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  double _niceInterval(List<Candle> candles) {
    final closes = candles.map((c) => c.close);
    final min = closes.reduce((a, b) => a < b ? a : b);
    final max = closes.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    return range <= 0 ? 1 : range / 4;
  }
}
