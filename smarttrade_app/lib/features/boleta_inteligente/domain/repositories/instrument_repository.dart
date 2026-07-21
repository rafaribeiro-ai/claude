import 'package:dartz/dartz.dart';
import 'package:smarttrade_app/core/error/failures.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';

/// Source of tradable instruments for the Boleta Inteligente.
///
/// The MVP data layer backs this with a hard-coded seed list (Nasdaq
/// futures, XAU/USD), but the domain layer only knows this contract, so
/// swapping in a remote/broker-fed catalog later is a data-layer-only
/// change.
abstract class InstrumentRepository {
  Future<Either<Failure, List<Instrument>>> getAvailableInstruments();

  Future<Either<Failure, Instrument>> getInstrumentBySymbol(String symbol);
}
