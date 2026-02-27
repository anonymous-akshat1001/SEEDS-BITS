import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class for responsive UI sizing.
/// Designed to make the app work well on very small screens
/// like the Blackzone Winx 4G (240x320) while still looking
/// good on normal phones.
class UIUtils {
  /// Base design width (standard small phone)
  static const double _baseWidth = 360.0;

  /// Get scale factor based on screen width
  static double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final raw = width / _baseWidth;
    return math.min(math.max(raw, 0.5), 1.5);
  }

  /// Whether this is a tiny screen (like Blackzone Winx 240x320)
  static bool isTiny(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // Tiny if width < 260 OR height < 400
    return width < 260 || (width < 320 && height < 500);
  }

  /// Whether this device likely has a physical keypad (estimated by aspect ratio and size)
  static bool isKeypad(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // Classic keypad phone ratio is roughly 3:4. Normal phones are 9:16 or 9:19.
    final ratio = width / height;
    return isTiny(context) && ratio > 0.6; 
  }

  /// Scaled font size
  static double fontSize(BuildContext context, double base) {
    final s = scale(context);
    // On keypad devices, we actually want text slightly LARGER than pure scale 
    // because the screen is physically small and far from the eye.
    final factor = isKeypad(context) ? s * 1.1 : s;
    final v = base * factor;
    return math.min(math.max(v, 9.0), base * 1.8);
  }

  /// Scaled padding value
  static double padding(BuildContext context, double base) {
    final v = base * scale(context);
    return math.min(math.max(v, 2.0), base * 1.5);
  }

  /// Scaled icon size
  static double iconSize(BuildContext context, double base) {
    final v = base * scale(context);
    return math.min(math.max(v, 12.0), base * 1.5);
  }

  /// Scaled spacing (SizedBox heights/widths)
  static double spacing(BuildContext context, double base) {
    final v = base * scale(context);
    return math.min(math.max(v, 2.0), base * 1.5);
  }

  /// Scaled EdgeInsets.all
  static EdgeInsets paddingAll(BuildContext context, double base) {
    final p = padding(context, base);
    return EdgeInsets.all(p);
  }

  /// Scaled symmetric padding
  static EdgeInsets paddingSymmetric(BuildContext context, {double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: padding(context, horizontal),
      vertical: padding(context, vertical),
    );
  }

  // --- Modern Minimal Theme Colors ---
  static const Color primaryColor = Color(0xFF2D3436); // Deep charcoal
  static const Color accentColor = Color(0xFF0984E3);  // Professional blue
  static const Color backgroundColor = Color(0xFFF5F6FA); // Light grey/white
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2D3436);
  static const Color subtextColor = Color(0xFF636E72);
}
