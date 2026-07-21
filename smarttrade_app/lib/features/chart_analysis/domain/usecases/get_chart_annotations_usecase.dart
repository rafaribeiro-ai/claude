import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_annotation.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/repositories/chart_annotation_repository.dart';

class GetChartAnnotationsParams extends Equatable {
  const GetChartAnnotationsParams(this.instrumentSymbol);

  final String instrumentSymbol;

  @override
  List<Object?> get props => [instrumentSymbol];
}

class GetChartAnnotationsUseCase
    implements UseCase<List<ChartAnnotation>, GetChartAnnotationsParams> {
  const GetChartAnnotationsUseCase(this._repository);

  final ChartAnnotationRepository _repository;

  @override
  Future<Either<Failure, List<ChartAnnotation>>> call(
    GetChartAnnotationsParams params,
  ) {
    return _repository.getAnnotations(params.instrumentSymbol);
  }
}
