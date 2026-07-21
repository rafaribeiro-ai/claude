import 'package:sqflite/sqflite.dart';
import 'package:smarttrade_app/core/database/app_database.dart';
import 'package:smarttrade_app/features/trading_journal/data/models/asset_preference_model.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/asset_preference.dart';

class AssetPreferenceLocalDataSource {
  const AssetPreferenceLocalDataSource(this._database);

  final Database _database;

  Future<List<AssetPreference>> getAll() async {
    final rows = await _database.query(
      AppDatabaseTables.assetPreferences,
      orderBy: 'display_order ASC',
    );
    return rows.map(AssetPreferenceModel.fromMap).toList();
  }

  Future<void> save(AssetPreference preference) async {
    await _database.insert(
      AppDatabaseTables.assetPreferences,
      AssetPreferenceModel.toMap(preference),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
