import 'dart:convert';

import 'package:smarttrade_app/core/database/app_database.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/chart_annotation.dart';

/// Maps the sealed [ChartAnnotation] hierarchy to/from a row in
/// [AppDatabaseTables.chartAnnotations].
///
/// All four annotation types share one wide table: the fields each type
/// doesn't use stay null, and type-specific scalars that don't fit the
/// generic price/time columns (zone kind, source channel id, expansion
/// factor, expected cycle length) are packed into the `extra` JSON
/// column. This keeps the schema stable if a fifth study type is added
/// later.
abstract final class ChartAnnotationModel {
  static const _typeSupportResistance = 'support_resistance';
  static const _typeReferenceChannel = 'reference_channel';
  static const _typeChannelExpansion = 'channel_expansion';
  static const _typeCycle = 'cycle';

  static Map<String, Object?> toMap(ChartAnnotation annotation) {
    final base = <String, Object?>{
      'id': annotation.id,
      'instrument_symbol': annotation.instrumentSymbol,
      'label': annotation.label,
      'note': annotation.note,
      'created_at': annotation.createdAt.toIso8601String(),
    };

    return switch (annotation) {
      SupportResistanceZone a => {
          ...base,
          'type': _typeSupportResistance,
          'price_high': a.priceHigh,
          'price_low': a.priceLow,
          'extra': jsonEncode({'kind': a.kind.name}),
        },
      ReferenceChannel a => {
          ...base,
          'type': _typeReferenceChannel,
          'price_high': a.upperPriceStart,
          'price_low': a.lowerPriceStart,
          'secondary_price_high': a.upperPriceEnd,
          'secondary_price_low': a.lowerPriceEnd,
          'anchor_time': a.anchorTime.toIso8601String(),
          'expansion_time': a.endTime.toIso8601String(),
        },
      ChannelExpansion a => {
          ...base,
          'type': _typeChannelExpansion,
          'secondary_price_high': a.projectedUpperPrice,
          'secondary_price_low': a.projectedLowerPrice,
          'expansion_time': a.projectedTime.toIso8601String(),
          'extra': jsonEncode({
            'sourceChannelId': a.sourceChannelId,
            'expansionFactor': a.expansionFactor,
          }),
        },
      CycleAnnotation a => {
          ...base,
          'type': _typeCycle,
          'anchor_time': a.cycleStart.toIso8601String(),
          'expansion_time': a.cycleEnd?.toIso8601String(),
          'extra': jsonEncode({
            'expectedCycleLengthDays': a.expectedCycleLengthDays,
          }),
        },
    };
  }

  static ChartAnnotation fromMap(Map<String, Object?> map) {
    final extraRaw = map['extra'] as String?;
    final extra = extraRaw == null
        ? const <String, Object?>{}
        : jsonDecode(extraRaw) as Map<String, Object?>;

    final id = map['id'] as String;
    final instrumentSymbol = map['instrument_symbol'] as String;
    final label = map['label'] as String?;
    final note = map['note'] as String?;
    final createdAt = DateTime.parse(map['created_at'] as String);

    switch (map['type'] as String) {
      case _typeSupportResistance:
        return SupportResistanceZone(
          id: id,
          instrumentSymbol: instrumentSymbol,
          createdAt: createdAt,
          label: label,
          note: note,
          kind: ZoneKind.values.byName(extra['kind'] as String),
          priceHigh: map['price_high'] as double,
          priceLow: map['price_low'] as double,
        );
      case _typeReferenceChannel:
        return ReferenceChannel(
          id: id,
          instrumentSymbol: instrumentSymbol,
          createdAt: createdAt,
          label: label,
          note: note,
          anchorTime: DateTime.parse(map['anchor_time'] as String),
          endTime: DateTime.parse(map['expansion_time'] as String),
          upperPriceStart: map['price_high'] as double,
          lowerPriceStart: map['price_low'] as double,
          upperPriceEnd: map['secondary_price_high'] as double,
          lowerPriceEnd: map['secondary_price_low'] as double,
        );
      case _typeChannelExpansion:
        return ChannelExpansion(
          id: id,
          instrumentSymbol: instrumentSymbol,
          createdAt: createdAt,
          label: label,
          note: note,
          sourceChannelId: extra['sourceChannelId'] as String,
          expansionFactor: (extra['expansionFactor'] as num).toDouble(),
          projectedTime: DateTime.parse(map['expansion_time'] as String),
          projectedUpperPrice: map['secondary_price_high'] as double,
          projectedLowerPrice: map['secondary_price_low'] as double,
        );
      case _typeCycle:
        final expansionTime = map['expansion_time'] as String?;
        return CycleAnnotation(
          id: id,
          instrumentSymbol: instrumentSymbol,
          createdAt: createdAt,
          label: label,
          note: note,
          cycleStart: DateTime.parse(map['anchor_time'] as String),
          cycleEnd: expansionTime == null ? null : DateTime.parse(expansionTime),
          expectedCycleLengthDays: extra['expectedCycleLengthDays'] as int?,
        );
      default:
        throw StateError('Tipo de anotação desconhecido: ${map['type']}');
    }
  }
}
