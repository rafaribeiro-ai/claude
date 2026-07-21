import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/boleta_inteligente/data/datasources/instrument_local_datasource.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/repositories/instrument_repository.dart';

class InstrumentRepositoryImpl implements InstrumentRepository {
  const InstrumentRepositoryImpl();

  @override
  Future<Either<Failure, List<Instrument>>> getAvailableInstruments() async {
    return Right(InstrumentLocalDataSource.seedInstruments);
  }

  @override
  Future<Either<Failure, Instrument>> getInstrumentBySymbol(
    String symbol,
  ) async {
    for (final instrument in InstrumentLocalDataSource.seedInstruments) {
      if (instrument.symbol == symbol) {
        return Right(instrument);
      }
    }
    return Left(NotFoundFailure('Instrumento "$symbol" não encontrado.'));
  }
}
