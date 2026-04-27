import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';

/// Multiplier text overlay with animated outer glow pulse and colour shift.
///
/// The glow ring pulses continuously while flying.
/// Colour shifts: white → orange → gold → hot-orange as multiplier climbs.
class MultiplierDisplay extends StatefulWidget {
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

  @override
  State<MultiplierDisplay> createState() => _MultiplierDisplayState();
}

class _MultiplierDisplayState extends State<MultiplierDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _getColor() {
    if (widget.isCrashed) return AppColors.accentRed;
    if (widget.isCashedOut) return AppColors.accentGreen;
    if (widget.multiplier >= 8.0) return const Color(0xFFFF6D00); // deep orange
    if (widget.multiplier >= 5.0) return AppColors.gold;
    if (widget.multiplier >= 3.0) return AppColors.accentOrange;
    return AppColors.textPrimary;
  }

  double _getFontSize() {
    if (!widget.isFlying && !widget.isCrashed && !widget.isCashedOut) return 24;
    if (widget.multiplier >= 8.0) return 48;
    if (widget.multiplier >= 5.0) return 40;
    if (widget.multiplier >= 2.5) return 32;
    return 24;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final fontSize = _getFontSize();
    final isActive = widget.isFlying;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        // Glow intensity scales with both pulse and multiplier
        final multiplierBoost =
            (widget.multiplier / 5.0).clamp(0.0, 1.5);
        final glowSpread = isActive
            ? 8 + _pulseAnim.value * 16 * multiplierBoost
            : 0.0;
        final glowAlpha = isActive ? 0.25 + _pulseAnim.value * 0.45 : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: glowAlpha),
                      blurRadius: glowSpread,
                      spreadRadius: glowSpread * 0.4,
                    ),
                  ],
                )
              : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.isCrashed
                  ? 'CRASHED!'
                  : NumberFormatter.formatMultiplier(widget.multiplier),
              style: AppTextStyles.pixelLarge.copyWith(
                color: color,
                fontSize: fontSize,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: isActive ? 0.7 : 0.4),
                    blurRadius: isActive ? 20 : 10,
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
      },
    );
  }
}
