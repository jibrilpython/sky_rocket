import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A neon-bordered frame around the game viewport with animated
/// gradient border that shifts colour during flight and throbs red on crash.
class NeonGameFrame extends StatefulWidget {
  const NeonGameFrame({
    super.key,
    required this.child,
    required this.isFlying,
    required this.isCrashed,
  });

  final Widget child;
  final bool isFlying;
  final bool isCrashed;

  @override
  State<NeonGameFrame> createState() => _NeonGameFrameState();
}

class _NeonGameFrameState extends State<NeonGameFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final Color glowColor;
        final double glowIntensity;

        if (widget.isCrashed) {
          glowColor = AppColors.accentRed;
          glowIntensity = 0.5;
        } else if (widget.isFlying) {
          // Cycle through orange → gold → green → cyan → orange
          final t = _ctrl.value;
          final colors = [
            AppColors.accentOrange,
            AppColors.gold,
            AppColors.accentGreen,
            const Color(0xFF00E5FF),
            AppColors.accentOrange,
          ];
          final segment = t * (colors.length - 1);
          final i = segment.floor().clamp(0, colors.length - 2);
          final frac = segment - i;
          glowColor = Color.lerp(colors[i], colors[i + 1], frac)!;
          glowIntensity = 0.35;
        } else {
          glowColor = AppColors.panelBorder;
          glowIntensity = 0.15;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: glowColor.withValues(alpha: glowIntensity + 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: glowIntensity),
                blurRadius: widget.isFlying ? 16 : 6,
                spreadRadius: widget.isFlying ? 2 : 0,
              ),
              if (widget.isFlying)
                BoxShadow(
                  color: glowColor.withValues(alpha: glowIntensity * 0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
