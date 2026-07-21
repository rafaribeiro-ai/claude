import 'package:flutter/material.dart';

/// Sober, professional palette for the SmartTrade App dark theme.
///
/// Deliberately desaturated grays with a single accent (teal/blue) so
/// the only saturated colors on screen are the ones that carry meaning:
/// green for gain/long, red for loss/short.
abstract final class AppColors {
  static const Color background = Color(0xFF0B0E11);
  static const Color surface = Color(0xFF14181D);
  static const Color surfaceElevated = Color(0xFF1C2127);
  static const Color border = Color(0xFF2A2F36);

  static const Color textPrimary = Color(0xFFE6E9ED);
  static const Color textSecondary = Color(0xFF8B93A1);
  static const Color textDisabled = Color(0xFF4E545D);

  static const Color accent = Color(0xFF2F81F7);
  static const Color accentMuted = Color(0xFF1E4A82);

  static const Color profit = Color(0xFF17C67F);
  static const Color loss = Color(0xFFE5484D);
  static const Color warning = Color(0xFFE5A93D);

  static const Color longPosition = profit;
  static const Color shortPosition = loss;

  static const Color tickerBackground = Color(0xFF0F1319);
}
