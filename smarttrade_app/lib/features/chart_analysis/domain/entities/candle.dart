import 'package:equatable/equatable.dart';

/// One OHLC price bar. Timeframe-agnostic on purpose: [time] is a real
/// timestamp for time-based candles, but a Renko engine can reuse this
/// same shape and simply ignore [time] spacing (Renko bricks form on
/// price movement, not on a clock).
class Candle extends Equatable {
  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume = 0,
  });

  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  bool get isBullish => close >= open;

  @override
  List<Object?> get props => [time, open, high, low, close, volume];
}
