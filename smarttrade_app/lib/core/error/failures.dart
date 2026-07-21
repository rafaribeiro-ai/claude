import 'package:equatable/equatable.dart';

/// Base class for all recoverable domain/data failures.
///
/// Repositories and use cases return `Either<Failure, T>` (via dartz)
/// instead of throwing, so the presentation layer always has a typed
/// error to render.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// The user tried to size a position in a way that violates a hard
/// business rule (e.g. more than 1 contract on a futures instrument).
class RiskRuleViolationFailure extends Failure {
  const RiskRuleViolationFailure(super.message);
}

/// Entry, stop or target prices are missing/invalid for a calculation.
class InvalidTradeParametersFailure extends Failure {
  const InvalidTradeParametersFailure(super.message);
}

/// Local persistence (sqflite) read/write error.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Requested instrument/annotation/journal entry does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Catch-all for unexpected errors surfaced from the data layer.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Erro inesperado.']);
}
