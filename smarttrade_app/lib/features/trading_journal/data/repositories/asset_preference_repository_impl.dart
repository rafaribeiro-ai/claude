import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/trading_journal/data/datasources/asset_preference_local_datasource.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/asset_preference.dart';
import 'package:smarttrade_app/features/trading_journal/domain/repositories/asset_preference_repository.dart';

class AssetPreferenceRepositoryImpl implements AssetPreferenceRepository {
  const AssetPreferenceRepositoryImpl(this._localDataSource);

  final AssetPreferenceLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<AssetPreference>>> getAll() async {
    try {
      return Right(await _localDataSource.getAll());
    } catch (error) {
      return Left(DatabaseFailure('Falha ao carregar preferências: $error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(AssetPreference preference) async {
    try {
      await _localDataSource.save(preference);
      return const Right(unit);
    } catch (error) {
      return Left(DatabaseFailure('Falha ao salvar preferência: $error'));
    }
  }
}
