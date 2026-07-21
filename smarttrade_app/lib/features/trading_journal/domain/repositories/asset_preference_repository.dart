import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/trading_journal/domain/entities/asset_preference.dart';

abstract class AssetPreferenceRepository {
  Future<Either<Failure, List<AssetPreference>>> getAll();

  Future<Either<Failure, Unit>> save(AssetPreference preference);
}
