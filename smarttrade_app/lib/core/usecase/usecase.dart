import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/core/error/failures.dart';

/// Contract every Clean Architecture use case implements.
///
/// [Result] is the successful return value, [Params] is the input the
/// presentation layer must supply. Use [NoParams] when a use case takes
/// no arguments.
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Synchronous counterpart of [UseCase] for pure, non-IO calculations
/// such as the risk/reward math in the Boleta Inteligente.
abstract class SyncUseCase<Result, Params> {
  Either<Failure, Result> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
