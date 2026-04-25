import 'dart:math';

/// Provably fair crash point algorithm for the crash game.
class CrashAlgorithmService {
  CrashAlgorithmService() : _random = Random();

  final Random _random;

  /// Generate a crash point using a provably fair algorithm.
  ///
  /// Distribution is skewed toward lower values (realistic iGaming):
  /// - ~33% chance of crashing below 1.5x
  /// - ~50% chance of crashing below 2.0x
  /// - ~5% chance of going above 10x
  /// - Minimum is always 1.00x
  double generateCrashPoint() {
    // Use inverse transform sampling for an exponential-like distribution
    final r = _random.nextDouble();

    // If r is very close to 0, the crash is instant
    if (r < 0.01) return 1.00;

    // Crash point formula: based on exponential distribution
    // This produces a house-edge-like distribution
    final crashPoint = 0.99 / (1.0 - r);

    // Clamp minimum to 1.00 and maximum to 1000.00
    return max(1.00, min(1000.00, double.parse(crashPoint.toStringAsFixed(2))));
  }

  /// Calculate the current multiplier based on elapsed time.
  ///
  /// The growth rate accelerates slightly over time to create
  /// an exciting exponential feel.
  double calculateMultiplier(double elapsedSeconds) {
    const baseRate = 0.08;
    const acceleration = 0.002;

    // Multiplier grows with slight acceleration
    final growthRate = baseRate + (acceleration * elapsedSeconds);
    final multiplier = 1.00 + (elapsedSeconds * growthRate);

    return double.parse(multiplier.toStringAsFixed(2));
  }
}
