import 'package:smarttrade_app/features/trading_journal/domain/entities/asset_preference.dart';

abstract final class AssetPreferenceModel {
  static Map<String, Object?> toMap(AssetPreference preference) {
    return {
      'instrument_symbol': preference.instrumentSymbol,
      'is_favorite': preference.isFavorite ? 1 : 0,
      'default_forex_lot_size': preference.defaultForexLotSize,
      'display_order': preference.displayOrder,
    };
  }

  static AssetPreference fromMap(Map<String, Object?> map) {
    return AssetPreference(
      instrumentSymbol: map['instrument_symbol'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
      defaultForexLotSize: map['default_forex_lot_size'] as double?,
      displayOrder: map['display_order'] as int,
    );
  }
}
