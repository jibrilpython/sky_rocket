import 'dart:math';

/// Utility for formatting numbers in the game UI.
abstract final class NumberFormatter {
  /// Format a multiplier value: "2.35x"
  static String formatMultiplier(double value) {
    return '${value.toStringAsFixed(2)}x';
  }

  /// Format currency: "$1,234.56"
  static String formatCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final parts = absValue.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add comma separators
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    final formatted = '\$${buffer.toString()}.$decPart';
    return isNegative ? '-$formatted' : formatted;
  }

  /// Format compact: "1.2K", "350"
  static String formatCompact(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  /// Clamp a value between min and max.
  static double clamp(double value, double minVal, double maxVal) {
    return max(minVal, min(maxVal, value));
  }
}
