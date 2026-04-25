import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';

/// Multiplier text overlay on the game area.
/// Color shifts based on multiplier value; font size scales up
/// but is constrained by a FittedBox to prevent overflow.
class MultiplierDisplay extends StatelessWidget {
  const MultiplierDisplay({
    super.key,
    required this.multiplier,
    required this.isFlying,
    required this.isCrashed,
    required this.isCashedOut,
  });

  final double multiplier;
  final bool isFlying;
  final bool isCrashed;
  final bool isCashedOut;

  Color _getColor() {
    if (isCrashed) return AppColors.accentRed;
    if (isCashedOut) return AppColors.accentGreen;
    if (multiplier > 5.0) return AppColors.gold;
    if (multiplier > 3.0) return AppColors.accentOrange;
    return AppColors.textPrimary;
  }

  double _getFontSize() {
    if (!isFlying && !isCrashed && !isCashedOut) return 24;
    // Snap to multiples of 8 for clean pixel font rendering: 24 → 32 → 40 → 48
    if (multiplier >= 8.0) return 48;
    if (multiplier >= 5.0) return 40;
    if (multiplier >= 2.5) return 32;
    return 24;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final fontSize = _getFontSize();

    // Use a plain Text (no AnimatedDefaultTextStyle) — the multiplier
    // updates every 100ms so animation interpolation fights itself and
    // causes text to smear / disappear.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          isCrashed
              ? 'CRASHED!'
              : NumberFormatter.formatMultiplier(multiplier),
          style: AppTextStyles.pixelLarge.copyWith(
            color: color,
            fontSize: fontSize,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 16,
              ),
              const Shadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
