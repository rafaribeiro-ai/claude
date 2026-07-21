import 'package:sqflite/sqflite.dart';
import 'package:smarttrade_app/core/database/app_database.dart';
import 'package:smarttrade_app/features/chart_analysis/data/models/chart_annotation_model.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_annotation.dart';

class ChartAnnotationLocalDataSource {
  const ChartAnnotationLocalDataSource(this._database);

  final Database _database;

  Future<List<ChartAnnotation>> getAnnotations(String instrumentSymbol) async {
    final rows = await _database.query(
      AppDatabaseTables.chartAnnotations,
      where: 'instrument_symbol = ?',
      whereArgs: [instrumentSymbol],
      orderBy: 'created_at DESC',
    );
    return rows.map(ChartAnnotationModel.fromMap).toList();
  }

  Future<void> saveAnnotation(ChartAnnotation annotation) async {
    await _database.insert(
      AppDatabaseTables.chartAnnotations,
      ChartAnnotationModel.toMap(annotation),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAnnotation(String id) async {
    await _database.delete(
      AppDatabaseTables.chartAnnotations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
