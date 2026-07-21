import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttrade_app/core/usecase/usecase.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/usecases/calculate_position_risk_usecase.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/providers/boleta_state.dart';
import 'package:smarttrade_app/features/boleta_inteligente/presentation/providers/instrument_providers.dart';

final boletaNotifierProvider =
    AsyncNotifierProvider<BoletaNotifier, BoletaState>(BoletaNotifier.new);

/// Drives the Smart Order Ticket screen. Every setter re-runs
/// [CalculatePositionRiskUseCase] so the Risk/Reward panel updates live
/// as the user types, exactly like a real broker ticket.
class BoletaNotifier extends AsyncNotifier<BoletaState> {
  @override
  Future<BoletaState> build() async {
    final result =
        await ref.read(getAvailableInstrumentsUseCaseProvider).call(
              const NoParams(),
            );
    return result.fold(
      (failure) => BoletaState.initial(const []),
      (instruments) => BoletaState.initial(instruments),
    );
  }

  void selectInstrument(Instrument instrument) {
    _update((s) => s.copyWith(selectedInstrument: instrument));
  }

  void setDirection(TradeDirection direction) {
    _update((s) => s.copyWith(direction: direction));
  }

  void setEntryPrice(double? value) {
    _update((s) => s.copyWith(entryPrice: value));
  }

  void setStopPrice(double? value) {
    _update((s) => s.copyWith(stopPrice: value));
  }

  void setTargetPrice(double? value) {
    _update((s) => s.copyWith(targetPrice: value));
  }

  void setForexLotSize(double value) {
    _update((s) => s.copyWith(forexLotSize: value));
  }

  void _update(BoletaState Function(BoletaState current) transform) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(_recalculate(transform(current)));
  }

  BoletaState _recalculate(BoletaState s) {
    final instrument = s.selectedInstrument;
    final entry = s.entryPrice;
    final stop = s.stopPrice;
    final target = s.targetPrice;

    if (instrument == null || entry == null || stop == null || target == null) {
      return s.copyWith(calculation: null);
    }

    final useCase = ref.read(calculatePositionRiskUseCaseProvider);
    final result = useCase(
      CalculatePositionRiskParams(
        instrument: instrument,
        direction: s.direction,
        entryPrice: entry,
        stopPrice: stop,
        targetPrice: target,
        desiredForexLotSize: s.forexLotSize,
      ),
    );

    return s.copyWith(calculation: result);
  }
}
