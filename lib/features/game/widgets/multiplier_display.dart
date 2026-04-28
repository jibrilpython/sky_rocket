import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';

/// Multiplier text overlay with animated outer glow pulse, colour shift,
/// orbital ring decoration, and scale-bounce on milestone multipliers.
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
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _orbitCtrl;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  double _lastMilestone = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(MultiplierDisplay old) {
    super.didUpdateWidget(old);
    // Bounce on milestone crossings (2x, 3x, 5x, 10x, 20x, 50x)
    const milestones = [2.0, 3.0, 5.0, 10.0, 20.0, 50.0];
    for (final m in milestones) {
      if (old.multiplier < m && widget.multiplier >= m && _lastMilestone != m) {
        _lastMilestone = m;
        _bounceCtrl.forward(from: 0);
        break;
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _orbitCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  Color _getColor() {
    if (widget.isCrashed) return AppColors.accentRed;
    if (widget.isCashedOut) return AppColors.accentGreen;
    if (widget.multiplier >= 10.0) return const Color(0xFFFF6D00); // deep orange
    if (widget.multiplier >= 5.0) return AppColors.gold;
    if (widget.multiplier >= 3.0) return AppColors.accentOrange;
    return AppColors.textPrimary;
  }

  double _getFontSize() {
    if (!widget.isFlying && !widget.isCrashed && !widget.isCashedOut) return 24;
    if (widget.multiplier >= 10.0) return 48;
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
      animation: Listenable.merge([_pulseAnim, _orbitCtrl, _bounceAnim]),
      builder: (context, child) {
        // Glow intensity scales with both pulse and multiplier
        final multiplierBoost =
            (widget.multiplier / 5.0).clamp(0.0, 1.5);
        final glowSpread = isActive
            ? 8 + _pulseAnim.value * 16 * multiplierBoost
            : 0.0;
        final glowAlpha = isActive ? 0.25 + _pulseAnim.value * 0.45 : 0.0;

        return Transform.scale(
          scale: _bounceAnim.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbital ring decoration (only during flight at high multipliers)
              if (isActive && widget.multiplier >= 3.0)
                Transform.rotate(
                  angle: _orbitCtrl.value * 2 * pi,
                  child: Container(
                    width: fontSize * 3.5,
                    height: fontSize * 3.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.6),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Second orbital ring (counter-rotate, only at 5x+)
              if (isActive && widget.multiplier >= 5.0)
                Transform.rotate(
                  angle: -_orbitCtrl.value * 2 * pi * 0.7,
                  child: Container(
                    width: fontSize * 4.2,
                    height: fontSize * 4.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.06),
                        width: 0.8,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),

              // Main multiplier text
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // "MULTIPLIER" sub-label during flight
                    if (isActive)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'MULTIPLIER',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label.copyWith(
                            fontSize: 8,
                            letterSpacing: 3,
                            color: color.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    // Use a symmetric fixed-width box so FittedBox
                    // scales from the true centre on both sides.
                    SizedBox(
                      width: fontSize * 5.5,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          widget.isCrashed
                              ? 'CRASHED!'
                              : NumberFormatter.formatMultiplier(
                                  widget.multiplier),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pixelLarge.copyWith(
                            color: color,
                            fontSize: fontSize,
                            shadows: [
                              Shadow(
                                color: color.withValues(
                                    alpha: isActive ? 0.7 : 0.4),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
