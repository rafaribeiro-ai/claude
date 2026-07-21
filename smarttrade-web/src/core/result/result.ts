import type { Failure } from '@/core/error/failure'

/**
 * TypeScript stand-in for `Either<Failure, T>`: every use case and
 * repository method returns one of these instead of throwing, so callers
 * are forced to handle the failure case explicitly.
 */
export type Result<T> = { ok: true; value: T } | { ok: false; error: Failure }

export function ok<T>(value: T): Result<T> {
  return { ok: true, value }
}

export function err<T>(error: Failure): Result<T> {
  return { ok: false, error }
}

/** Folds a Result into a single value, mirroring dartz's `Either.fold`. */
export function fold<T, R>(
  result: Result<T>,
  onError: (error: Failure) => R,
  onSuccess: (value: T) => R,
): R {
  return result.ok ? onSuccess(result.value) : onError(result.error)
}
