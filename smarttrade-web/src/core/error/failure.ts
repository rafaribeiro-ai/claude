/**
 * Base type for all recoverable domain/data failures.
 *
 * Repositories and use cases return `Result<T>` (see `core/result/result.ts`)
 * instead of throwing, so the UI always has a typed error to render.
 */
export abstract class Failure {
  readonly message: string

  constructor(message: string) {
    this.message = message
  }
}

/** A hard business rule was about to be violated (e.g. >1 futures contract). */
export class RiskRuleViolationFailure extends Failure {}

/** Entry, stop or target prices are missing/invalid for a calculation. */
export class InvalidTradeParametersFailure extends Failure {}

/** IndexedDB (Dexie) read/write error. */
export class DatabaseFailure extends Failure {}

/** Requested instrument/annotation/journal entry does not exist. */
export class NotFoundFailure extends Failure {}

/** Catch-all for unexpected errors surfaced from the data layer. */
export class UnexpectedFailure extends Failure {
  constructor(message = 'Erro inesperado.') {
    super(message)
  }
}
