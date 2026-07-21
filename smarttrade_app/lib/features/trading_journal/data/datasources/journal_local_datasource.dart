import 'package:sqflite/sqflite.dart';
import 'package:smarttrade_app/core/database/app_database.dart';
import 'package:smarttrade_app/features/trading_journal/data/models/journal_entry_model.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';

class JournalLocalDataSource {
  const JournalLocalDataSource(this._database);

  final Database _database;

  Future<List<JournalEntry>> getEntries() async {
    final rows = await _database.query(
      AppDatabaseTables.journalEntries,
      orderBy: 'opened_at DESC',
    );
    return rows.map(JournalEntryModel.fromMap).toList();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _database.insert(
      AppDatabaseTables.journalEntries,
      JournalEntryModel.toMap(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEntry(String id) async {
    await _database.delete(
      AppDatabaseTables.journalEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
