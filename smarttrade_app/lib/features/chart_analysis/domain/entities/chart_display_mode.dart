/// How the chart lays out candles on the horizontal axis.
///
/// [timeBased] is the classic clock-driven candle chart. [renko] is
/// atemporal: bricks are drawn purely from price movement past a fixed
/// size, so the same price history can produce a different number of
/// bricks depending on [RenkoSettings.brickSize]. The MVP chart engine
/// (see `presentation/widgets/chart_renderer.dart`) only implements
/// [timeBased] today; [renko] exists so the interface doesn't need to
/// change shape when a Renko-capable charting library is plugged in.
enum ChartDisplayMode { timeBased, renko }

/// Configuration a future Renko renderer will need. Kept here, next to
/// [ChartDisplayMode], so the domain layer already models what "atemporal"
/// charting requires even though no renderer consumes it yet.
class RenkoSettings {
  const RenkoSettings({required this.brickSize, this.useWicks = false});

  /// Minimum price movement, in points, required to draw a new brick.
  final double brickSize;

  /// Whether bricks show high/low wicks or are drawn as flat boxes.
  final bool useWicks;
}
