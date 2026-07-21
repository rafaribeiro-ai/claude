import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_annotation.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/repositories/chart_annotation_repository.dart';

class SaveChartAnnotationParams extends Equatable {
  const SaveChartAnnotationParams(this.annotation);

  final ChartAnnotation annotation;

  @override
  List<Object?> get props => [annotation];
}

class SaveChartAnnotationUseCase
    implements UseCase<Unit, SaveChartAnnotationParams> {
  const SaveChartAnnotationUseCase(this._repository);

  final ChartAnnotationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveChartAnnotationParams params) {
    return _repository.saveAnnotation(params.annotation);
  }
}
