import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/macro_news_headline.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/repositories/macro_news_repository.dart';

/// Placeholder implementation: returns a fixed sample so the ticker has
/// something to scroll in the MVP. Replace with a data source that hits
/// a real macroeconomic calendar/news API once one is chosen.
class MacroNewsRepositoryImpl implements MacroNewsRepository {
  const MacroNewsRepositoryImpl();

  @override
  Future<Either<Failure, List<MacroNewsHeadline>>> getLatestHeadlines() async {
    final now = DateTime.now();
    return Right([
      MacroNewsHeadline(
        headline: 'FOMC mantém juros; mercado aguarda fala de Powell.',
        impact: MacroImpact.high,
        publishedAt: now,
      ),
      MacroNewsHeadline(
        headline: 'CPI dos EUA em linha com o consenso.',
        impact: MacroImpact.medium,
        publishedAt: now,
      ),
      MacroNewsHeadline(
        headline: 'Payroll acima do esperado pressiona yields.',
        impact: MacroImpact.high,
        publishedAt: now,
      ),
      MacroNewsHeadline(
        headline: 'Feed de dados macro em desenvolvimento.',
        impact: MacroImpact.low,
        publishedAt: now,
      ),
    ]);
  }
}
