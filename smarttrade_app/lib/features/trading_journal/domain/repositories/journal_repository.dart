import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';

abstract class JournalRepository {
  Future<Either<Failure, List<JournalEntry>>> getEntries();

  Future<Either<Failure, Unit>> addEntry(JournalEntry entry);

  Future<Either<Failure, Unit>> deleteEntry(String id);
}
