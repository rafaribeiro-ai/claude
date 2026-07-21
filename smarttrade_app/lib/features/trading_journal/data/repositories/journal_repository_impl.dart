import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/trading_journal/data/datasources/journal_local_datasource.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/journal_entry.dart';
import 'package:smarttrade_app/features/trading_journal/domain/repositories/journal_repository.dart';

class JournalRepositoryImpl implements JournalRepository {
  const JournalRepositoryImpl(this._localDataSource);

  final JournalLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<JournalEntry>>> getEntries() async {
    try {
      return Right(await _localDataSource.getEntries());
    } catch (error) {
      return Left(DatabaseFailure('Falha ao carregar o diário: $error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addEntry(JournalEntry entry) async {
    try {
      await _localDataSource.addEntry(entry);
      return const Right(unit);
    } catch (error) {
      return Left(DatabaseFailure('Falha ao salvar a operação: $error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEntry(String id) async {
    try {
      await _localDataSource.deleteEntry(id);
      return const Right(unit);
    } catch (error) {
      return Left(DatabaseFailure('Falha ao remover a operação: $error'));
    }
  }
}
