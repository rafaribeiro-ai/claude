import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttrade_app/core/providers/core_providers.dart';
import 'package:smarttrade_app/features/chart_analysis/data/datasources/chart_annotation_local_datasource.dart';
import 'package:smarttrade_app/features/chart_analysis/data/repositories/chart_annotation_repository_impl.dart';
import 'package:smarttrade_app/features/chart_analysis/data/repositories/macro_news_repository_impl.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/candle.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_annotation.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/macro_news_headline.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/repositories/chart_annotation_repository.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/repositories/macro_news_repository.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/usecases/get_chart_annotations_usecase.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/usecases/save_chart_annotation_usecase.dart';
import 'package:smarttrade_app/features/chart_analysis/presentation/widgets/chart_engine.dart';

final chartAnnotationLocalDataSourceProvider =
    Provider<ChartAnnotationLocalDataSource>((ref) {
  return ChartAnnotationLocalDataSource(ref.watch(databaseProvider).instance);
});

final chartAnnotationRepositoryProvider =
    Provider<ChartAnnotationRepository>((ref) {
  return ChartAnnotationRepositoryImpl(
    ref.watch(chartAnnotationLocalDataSourceProvider),
  );
});

final getChartAnnotationsUseCaseProvider =
    Provider<GetChartAnnotationsUseCase>((ref) {
  return GetChartAnnotationsUseCase(ref.watch(chartAnnotationRepositoryProvider));
});

final saveChartAnnotationUseCaseProvider =
    Provider<SaveChartAnnotationUseCase>((ref) {
  return SaveChartAnnotationUseCase(ref.watch(chartAnnotationRepositoryProvider));
});

/// Annotations saved for a given instrument symbol. `.family` keys the
/// cache per symbol so switching instruments doesn't refetch/mix marks.
final chartAnnotationsProvider = FutureProvider.family<List<ChartAnnotation>, String>(
  (ref, instrumentSymbol) async {
    final useCase = ref.watch(getChartAnnotationsUseCaseProvider);
    final result = await useCase(GetChartAnnotationsParams(instrumentSymbol));
    return result.fold((failure) => <ChartAnnotation>[], (data) => data);
  },
);

final macroNewsRepositoryProvider = Provider<MacroNewsRepository>((ref) {
  return const MacroNewsRepositoryImpl();
});

final macroNewsHeadlinesProvider = FutureProvider<List<MacroNewsHeadline>>((ref) async {
  final result = await ref.watch(macroNewsRepositoryProvider).getLatestHeadlines();
  return result.fold((failure) => <MacroNewsHeadline>[], (data) => data);
});

final chartEngineProvider = Provider<CandleChartEngine>((ref) {
  return const FlChartLineEngine();
});

/// Deterministic placeholder price series. There is no live market data
/// feed in the MVP yet; this only exists so the chart screen has
/// something to render while that integration is built.
final sampleCandlesProvider = Provider.family<List<Candle>, String>((ref, symbol) {
  final seed = symbol.codeUnits.fold<int>(0, (sum, c) => sum + c);
  var price = 100.0 + (seed % 50);
  final now = DateTime.now();

  return List.generate(60, (i) {
    final drift = ((seed + i * 7) % 11 - 5) * 0.35;
    final open = price;
    price = (price + drift).clamp(1.0, double.infinity);
    final close = price;
    final high = [open, close].reduce((a, b) => a > b ? a : b) + 0.5;
    final low = [open, close].reduce((a, b) => a < b ? a : b) - 0.5;
    return Candle(
      time: now.subtract(Duration(minutes: (60 - i) * 5)),
      open: open,
      high: high,
      low: low,
      close: close,
    );
  });
});
