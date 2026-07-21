import 'package:equatable/equatable.dart';

enum MacroImpact { low, medium, high }

/// One line of the bottom news ticker. Placeholder shape for the
/// macroeconomic data feed the ticker will eventually consume (CPI,
/// FOMC, NFP, etc.) - the MVP only needs the UI to reserve the space and
/// render this shape, not a real feed.
class MacroNewsHeadline extends Equatable {
  const MacroNewsHeadline({
    required this.headline,
    required this.impact,
    required this.publishedAt,
  });

  final String headline;
  final MacroImpact impact;
  final DateTime publishedAt;

  @override
  List<Object?> get props => [headline, impact, publishedAt];
}
