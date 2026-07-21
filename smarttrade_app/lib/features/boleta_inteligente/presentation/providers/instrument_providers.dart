import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/boleta_inteligente/data/repositories/instrument_repository_impl.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/repositories/instrument_repository.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/usecases/calculate_position_risk_usecase.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/usecases/get_available_instruments_usecase.dart';

final instrumentRepositoryProvider = Provider<InstrumentRepository>((ref) {
  return const InstrumentRepositoryImpl();
});

final getAvailableInstrumentsUseCaseProvider =
    Provider<GetAvailableInstrumentsUseCase>((ref) {
  return GetAvailableInstrumentsUseCase(ref.watch(instrumentRepositoryProvider));
});

final calculatePositionRiskUseCaseProvider =
    Provider<CalculatePositionRiskUseCase>((ref) {
  return const CalculatePositionRiskUseCase();
});

/// Shared instrument catalog. Both the Boleta Inteligente and the chart
/// screen watch this instead of calling the repository directly, so the
/// list is fetched once and cached by Riverpod.
final availableInstrumentsProvider = FutureProvider<List<Instrument>>((ref) async {
  final result =
      await ref.watch(getAvailableInstrumentsUseCaseProvider).call(const NoParams());
  return result.fold((failure) => <Instrument>[], (data) => data);
});
