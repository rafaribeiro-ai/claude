import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/macro_news_headline.dart';

/// Feeds the bottom news ticker. No real implementation ships in the
/// MVP - see `data/repositories/macro_news_repository_impl.dart` for the
/// placeholder - but the chart screen already depends on this interface
/// so wiring in a live macro calendar/news API later doesn't touch
/// presentation code.
abstract class MacroNewsRepository {
  Future<Either<Failure, List<MacroNewsHeadline>>> getLatestHeadlines();
}
