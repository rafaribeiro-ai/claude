import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';
import 'package:smarttrade_app/features/trading_journal/domain/repositories/journal_repository.dart';

class AddJournalEntryParams extends Equatable {
  const AddJournalEntryParams(this.entry);

  final JournalEntry entry;

  @override
  List<Object?> get props => [entry];
}

class AddJournalEntryUseCase implements UseCase<Unit, AddJournalEntryParams> {
  const AddJournalEntryUseCase(this._repository);

  final JournalRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AddJournalEntryParams params) {
    return _repository.addEntry(params.entry);
  }
}
