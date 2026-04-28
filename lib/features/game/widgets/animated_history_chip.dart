import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Animated round history chip that slides + scales in when first rendered.
/// Each chip shows the crash multiplier with a colour-coded background and
/// a subtle inner glow for premium feel.
class AnimatedHistoryChip extends StatefulWidget {
  const AnimatedHistoryChip({
    super.key,
    required this.value,
    required this.index,
  });

  final double value;
  final int index;

  @override
  State<AnimatedHistoryChip> createState() => _AnimatedHistoryChipState();
}

class _AnimatedHistoryChipState extends State<AnimatedHistoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    // Stagger by index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _chipColor() {
    if (widget.value >= 10.0) return AppColors.gold;
    if (widget.value >= 5.0) return AppColors.chipGreen;
    if (widget.value >= 2.0) return AppColors.chipYellow;
    return AppColors.chipRed;
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor();
    final isHigh = widget.value >= 10.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: isHigh
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHigh) ...[
              Icon(Icons.local_fire_department_rounded,
                  color: color, size: 10),
              const SizedBox(width: 3),
            ],
            Text(
              '${widget.value.toStringAsFixed(2)}x',
              style: AppTextStyles.chipText.copyWith(
                color: color,
                fontWeight: isHigh ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
