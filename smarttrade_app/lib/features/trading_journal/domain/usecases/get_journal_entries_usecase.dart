import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';
import 'package:smarttrade_app/features/trading_journal/domain/repositories/journal_repository.dart';

class GetJournalEntriesUseCase implements UseCase<List<JournalEntry>, NoParams> {
  const GetJournalEntriesUseCase(this._repository);

  final JournalRepository _repository;

  @override
  Future<Either<Failure, List<JournalEntry>>> call(NoParams params) {
    return _repository.getEntries();
  }
}
