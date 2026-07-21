import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_annotation.dart';

abstract class ChartAnnotationRepository {
  Future<Either<Failure, List<ChartAnnotation>>> getAnnotations(
    String instrumentSymbol,
  );

  Future<Either<Failure, Unit>> saveAnnotation(ChartAnnotation annotation);

  Future<Either<Failure, Unit>> deleteAnnotation(String id);
}
