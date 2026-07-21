// Domain-level tests for the Boleta Inteligente's core business rule:
// futures orders are always sized at exactly one contract, and the
// dollar risk/reward math is derived from that fixed size.

import 'package:flutter_test/flutter_test.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/instrument.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/entities/trade_direction.dart';
import 'package:smarttrade_app/features/boleta_inteligente/domain/usecases/calculate_position_risk_usecase.dart';

void main() {
  const useCase = CalculatePositionRiskUseCase();

  const mnq = FuturesInstrument(
    symbol: 'MNQ',
    displayName: 'Micro E-mini Nasdaq-100',
    exchange: 'CME',
    tickSize: 0.25,
    tickValue: 0.50,
  );

  const xauusd = ForexInstrument(
    symbol: 'XAUUSD',
    displayName: 'Ouro (Spot)',
    exchange: 'OTC',
    pipSize: 0.01,
    contractSize: 100,
  );

  group('CalculatePositionRiskUseCase - futures Golden Rule', () {
    test('always locks position size to exactly 1 contract', () {
      final result = useCase(
        const CalculatePositionRiskParams(
          instrument: mnq,
          direction: TradeDirection.long,
          entryPrice: 20000,
          stopPrice: 19980,
          targetPrice: 20040,
        ),
      );

      final calculation = result.getOrElse(() => throw StateError('expected Right'));
      expect(calculation.positionSize, 1);
    });

    test('computes exact dollar risk from stop distance and tick value', () {
      final result = useCase(
        const CalculatePositionRiskParams(
          instrument: mnq,
          direction: TradeDirection.long,
          entryPrice: 20000,
          stopPrice: 19980, // 20 points away
          targetPrice: 20040, // 40 points away
        ),
      );

      final calculation = result.getOrElse(() => throw StateError('expected Right'));

      // valuePerPoint = tickValue / tickSize = 0.50 / 0.25 = $2/point
      expect(calculation.riskAmount, closeTo(40.0, 0.001));
      expect(calculation.rewardAmount, closeTo(80.0, 0.001));
      expect(calculation.riskRewardRatio, closeTo(2.0, 0.001));
    });

    test('rejects a stop placed on the wrong side of a long entry', () {
      final result = useCase(
        const CalculatePositionRiskParams(
          instrument: mnq,
          direction: TradeDirection.long,
          entryPrice: 20000,
          stopPrice: 20010,
          targetPrice: 20040,
        ),
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('CalculatePositionRiskUseCase - forex lot sizing', () {
    test('supports fractional lot sizes for non-futures instruments', () {
      final result = useCase(
        const CalculatePositionRiskParams(
          instrument: xauusd,
          direction: TradeDirection.long,
          entryPrice: 2400,
          stopPrice: 2395, // $5 distance
          targetPrice: 2415, // $15 distance
          desiredForexLotSize: 0.1,
        ),
      );

      final calculation = result.getOrElse(() => throw StateError('expected Right'));

      expect(calculation.positionSize, closeTo(0.1, 0.001));
      // riskAmount = stopDistance * contractSize * lotSize = 5 * 100 * 0.1
      expect(calculation.riskAmount, closeTo(50.0, 0.001));
      expect(calculation.rewardAmount, closeTo(150.0, 0.001));
    });
  });
}
