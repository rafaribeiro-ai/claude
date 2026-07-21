import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/repositories/instrument_repository.dart';

class GetAvailableInstrumentsUseCase
    implements UseCase<List<Instrument>, NoParams> {
  const GetAvailableInstrumentsUseCase(this._repository);

  final InstrumentRepository _repository;

  @override
  Future<Either<Failure, List<Instrument>>> call(NoParams params) {
    return _repository.getAvailableInstruments();
  }
}
