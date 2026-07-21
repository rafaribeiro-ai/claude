import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/chart_analysis/data/datasources/chart_annotation_local_datasource.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_annotation.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/repositories/chart_annotation_repository.dart';

class ChartAnnotationRepositoryImpl implements ChartAnnotationRepository {
  const ChartAnnotationRepositoryImpl(this._localDataSource);

  final ChartAnnotationLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<ChartAnnotation>>> getAnnotations(
    String instrumentSymbol,
  ) async {
    try {
      final annotations =
          await _localDataSource.getAnnotations(instrumentSymbol);
      return Right(annotations);
    } catch (error) {
      return Left(DatabaseFailure('Falha ao carregar marcações: $error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveAnnotation(
    ChartAnnotation annotation,
  ) async {
    try {
      await _localDataSource.saveAnnotation(annotation);
      return const Right(unit);
    } catch (error) {
      return Left(DatabaseFailure('Falha ao salvar marcação: $error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAnnotation(String id) async {
    try {
      await _localDataSource.deleteAnnotation(id);
      return const Right(unit);
    } catch (error) {
      return Left(DatabaseFailure('Falha ao remover marcação: $error'));
    }
  }
}
