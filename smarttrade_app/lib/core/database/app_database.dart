import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Table names shared by every feature's local data source, kept in one
/// place so the schema is visible without hunting through the repo.
abstract final class AppDatabaseTables {
  static const String journalEntries = 'journal_entries';
  static const String assetPreferences = 'asset_preferences';
  static const String chartAnnotations = 'chart_annotations';
}

/// Owns the single sqflite [Database] instance used to persist the
/// offline "Diário de Trading" and asset preferences. Injected as a
/// Riverpod provider (see `core/providers/core_providers.dart`) so every
/// repository shares one connection instead of opening its own.
class AppDatabase {
  AppDatabase._(this._database);

  static const String _fileName = 'smarttrade_app.db';
  static const int _schemaVersion = 1;

  final Database _database;

  Database get instance => _database;

  static Future<AppDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, _fileName);

    final database = await openDatabase(
      dbPath,
      version: _schemaVersion,
      onCreate: _createSchema,
    );

    return AppDatabase._(database);
  }

  static Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppDatabaseTables.journalEntries} (
        id TEXT PRIMARY KEY,
        instrument_symbol TEXT NOT NULL,
        direction TEXT NOT NULL,
        entry_price REAL NOT NULL,
        stop_price REAL NOT NULL,
        target_price REAL NOT NULL,
        risk_amount REAL NOT NULL,
        reward_amount REAL NOT NULL,
        risk_reward_ratio REAL NOT NULL,
        position_size REAL NOT NULL,
        outcome TEXT NOT NULL,
        notes TEXT,
        opened_at TEXT NOT NULL,
        closed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppDatabaseTables.assetPreferences} (
        instrument_symbol TEXT PRIMARY KEY,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        default_forex_lot_size REAL,
        display_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppDatabaseTables.chartAnnotations} (
        id TEXT PRIMARY KEY,
        instrument_symbol TEXT NOT NULL,
        type TEXT NOT NULL,
        label TEXT,
        price_high REAL,
        price_low REAL,
        secondary_price_high REAL,
        secondary_price_low REAL,
        anchor_time TEXT,
        expansion_time TEXT,
        note TEXT,
        extra TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() => _database.close();
}
