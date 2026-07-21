import 'package:equatable/equatable.dart';

/// Per-instrument preferences persisted offline (favorited assets, the
/// last forex lot size used, display order in pickers).
class AssetPreference extends Equatable {
  const AssetPreference({
    required this.instrumentSymbol,
    this.isFavorite = false,
    this.defaultForexLotSize,
    this.displayOrder = 0,
  });

  final String instrumentSymbol;
  final bool isFavorite;
  final double? defaultForexLotSize;
  final int displayOrder;

  AssetPreference copyWith({
    bool? isFavorite,
    double? defaultForexLotSize,
    int? displayOrder,
  }) {
    return AssetPreference(
      instrumentSymbol: instrumentSymbol,
      isFavorite: isFavorite ?? this.isFavorite,
      defaultForexLotSize: defaultForexLotSize ?? this.defaultForexLotSize,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  List<Object?> get props =>
      [instrumentSymbol, isFavorite, defaultForexLotSize, displayOrder];
}
