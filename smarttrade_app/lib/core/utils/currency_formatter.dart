import 'package:intl/intl.dart';

/// Shared USD formatting for the risk/reward figures shown across the
/// Boleta Inteligente and the trading journal.
abstract final class CurrencyFormatter {
  static final NumberFormat _usd = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  static String usd(double value) => _usd.format(value);

  static String signedUsd(double value) {
    final formatted = _usd.format(value.abs());
    return value < 0 ? '-$formatted' : '+$formatted';
  }
}
