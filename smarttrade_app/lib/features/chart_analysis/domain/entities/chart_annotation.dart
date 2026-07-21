import 'package:equatable/equatable.dart';

/// Whether a [SupportResistanceZone] is acting as a floor or a ceiling.
enum ZoneKind { support, resistance }

/// A saved study mark on an instrument's chart.
///
/// Sealed over the four study types the MVP needs to persist: price
/// zones, reference channels, channel expansions, and cycle-tracking
/// time markers. Every concrete subtype is backed by the same
/// `chart_annotations` sqlite table (see `data/models/chart_annotation_model.dart`
/// for the mapping), so adding a new study type later is a data-layer
/// change, not a schema migration.
sealed class ChartAnnotation extends Equatable {
  const ChartAnnotation({
    required this.id,
    required this.instrumentSymbol,
    required this.createdAt,
    this.label,
    this.note,
  });

  final String id;
  final String instrumentSymbol;
  final DateTime createdAt;
  final String? label;
  final String? note;
}

/// A horizontal price band the user marked as support or resistance.
class SupportResistanceZone extends ChartAnnotation {
  const SupportResistanceZone({
    required super.id,
    required super.instrumentSymbol,
    required super.createdAt,
    super.label,
    super.note,
    required this.kind,
    required this.priceHigh,
    required this.priceLow,
  });

  final ZoneKind kind;
  final double priceHigh;
  final double priceLow;

  @override
  List<Object?> get props =>
      [id, instrumentSymbol, createdAt, label, note, kind, priceHigh, priceLow];
}

/// Two parallel trendlines (upper/lower bound) drawn between two points
/// in time, used as a reference for the prevailing trend structure.
class ReferenceChannel extends ChartAnnotation {
  const ReferenceChannel({
    required super.id,
    required super.instrumentSymbol,
    required super.createdAt,
    super.label,
    super.note,
    required this.anchorTime,
    required this.endTime,
    required this.upperPriceStart,
    required this.lowerPriceStart,
    required this.upperPriceEnd,
    required this.lowerPriceEnd,
  });

  final DateTime anchorTime;
  final DateTime endTime;
  final double upperPriceStart;
  final double lowerPriceStart;
  final double upperPriceEnd;
  final double lowerPriceEnd;

  @override
  List<Object?> get props => [
        id,
        instrumentSymbol,
        createdAt,
        label,
        note,
        anchorTime,
        endTime,
        upperPriceStart,
        lowerPriceStart,
        upperPriceEnd,
        lowerPriceEnd,
      ];
}

/// A projected expansion of an existing [ReferenceChannel] (e.g. a
/// Fibonacci-style multiple of the channel width projected forward in
/// time), kept as its own annotation so the original channel is never
/// mutated once drawn.
class ChannelExpansion extends ChartAnnotation {
  const ChannelExpansion({
    required super.id,
    required super.instrumentSymbol,
    required super.createdAt,
    super.label,
    super.note,
    required this.sourceChannelId,
    required this.expansionFactor,
    required this.projectedTime,
    required this.projectedUpperPrice,
    required this.projectedLowerPrice,
  });

  /// [ReferenceChannel.id] this expansion was projected from.
  final String sourceChannelId;

  /// Multiple of the source channel's width (e.g. 1.618).
  final double expansionFactor;
  final DateTime projectedTime;
  final double projectedUpperPrice;
  final double projectedLowerPrice;

  @override
  List<Object?> get props => [
        id,
        instrumentSymbol,
        createdAt,
        label,
        note,
        sourceChannelId,
        expansionFactor,
        projectedTime,
        projectedUpperPrice,
        projectedLowerPrice,
      ];
}

/// A temporal marker used to track recurring market cycles (e.g. "this
/// looks like the start of a new accumulation cycle").
class CycleAnnotation extends ChartAnnotation {
  const CycleAnnotation({
    required super.id,
    required super.instrumentSymbol,
    required super.createdAt,
    super.label,
    super.note,
    required this.cycleStart,
    this.cycleEnd,
    this.expectedCycleLengthDays,
  });

  final DateTime cycleStart;
  final DateTime? cycleEnd;
  final int? expectedCycleLengthDays;

  @override
  List<Object?> get props => [
        id,
        instrumentSymbol,
        createdAt,
        label,
        note,
        cycleStart,
        cycleEnd,
        expectedCycleLengthDays,
      ];
}
