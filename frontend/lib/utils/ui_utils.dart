import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class for responsive UI sizing.
/// Designed to make the app work well on very small screens
/// like the Blackzone Winx 4G (240x320) while still looking
/// good on normal phones.
class UIUtils {
  static final ValueNotifier<bool> highContrastListenable = ValueNotifier(true);
  static final ValueNotifier<double> textScaleListenable = ValueNotifier(1.0);

  static bool get isHighContrast => highContrastListenable.value;

  static void setHighContrastMode(bool enabled) {
    if (highContrastListenable.value != enabled) {
      highContrastListenable.value = enabled;
    }
  }

  static void setTextScale(double scale) {
    final normalized = scale.clamp(0.9, 1.5).toDouble();
    if (textScaleListenable.value != normalized) {
      textScaleListenable.value = normalized;
    }
  }

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

  /// Whether vertical space is tight enough to use compact controls.
  static bool isShort(BuildContext context) {
    return MediaQuery.of(context).size.height < 520;
  }

  /// Whether this device likely has a physical keypad (estimated by aspect ratio and size)
  static bool isKeypad(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // Classic keypad phone ratio is roughly 3:4. Normal phones are 9:16 or 9:19.
    final ratio = width / height;
    return isTiny(context) && ratio > 0.6;
  }

  /// Scaled font size, never below [minimumFontSize].
  static double fontSize(BuildContext context, double base) {
    return math.max(base * math.max(scale(context), 1.0), minimumFontSize);
  }

  static TextScaler combinedTextScaler(TextScaler system, double appScale) =>
      _AppTextScaler(system, appScale);

  static bool useStackedLayout(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360 ||
      MediaQuery.textScalerOf(context).scale(16) > 20;

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
  static EdgeInsets paddingSymmetric(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: padding(context, horizontal),
      vertical: padding(context, vertical),
    );
  }

  // --- Colours ---
  // Most SEEDS users are blind; some have low vision. High contrast (yellow
  // and white on black) is the default. Every foreground/background pair
  // below meets WCAG AAA (7:1) in high contrast and AA (4.5:1) otherwise.
  static Color get primaryColor =>
      isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF1F2A30);
  static Color get onPrimaryColor =>
      isHighContrast ? Colors.black : Colors.white;
  static Color get accentColor =>
      isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF004A99);
  static Color get onAccentColor =>
      isHighContrast ? Colors.black : Colors.white;
  static Color get backgroundColor =>
      isHighContrast ? Colors.black : const Color(0xFFF5F6FA);
  static Color get cardColor =>
      isHighContrast ? const Color(0xFF121212) : Colors.white;
  static Color get cardBorderColor =>
      isHighContrast ? Colors.white : const Color(0xFF5F6B73);
  static Color get textColor =>
      isHighContrast ? Colors.white : const Color(0xFF1F2A30);
  static Color get subtextColor =>
      isHighContrast ? const Color(0xFFFFF59D) : const Color(0xFF37474F);
  static Color get errorColor =>
      isHighContrast ? const Color(0xFFFF8A80) : const Color(0xFFB00020);
  static Color get successColor =>
      isHighContrast ? const Color(0xFF69F0AE) : const Color(0xFF1B5E20);

  /// Focus indicator: thick yellow ring with a black outline so it stays
  /// visible on any background colour.
  static const Color focusRingColor = Color(0xFFFFD600);
  static const double focusRingWidth = 4;

  /// Smallest font size used anywhere; low-vision users cannot read less.
  static const double minimumFontSize = 14;
}

class _AppTextScaler extends TextScaler {
  const _AppTextScaler(this.system, this.appScale);

  final TextScaler system;
  final double appScale;

  @override
  double scale(double fontSize) => system.scale(fontSize) * appScale;

  @override
  double get textScaleFactor => scale(14) / 14;
}
