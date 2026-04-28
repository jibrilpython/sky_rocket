import 'package:flutter/material.dart';
import '../../../models/bonus_event.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Displays bonus event notification during gameplay.
class BonusEventNotification extends StatefulWidget {
  const BonusEventNotification({
    super.key,
    required this.event,
  });

  final BonusEvent event;

  @override
  State<BonusEventNotification> createState() =>
      _BonusEventNotificationState();
}

class _BonusEventNotificationState extends State<BonusEventNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut),
    );

    _scaleCtrl.forward();

    // Auto-dismiss
    Future.delayed(
      Duration(milliseconds: 2000 + widget.event.durationMs),
      () {
        if (mounted) {
          _scaleCtrl.reverse();
        }
      },
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentOrange.withValues(alpha: 0.2),
              AppColors.gold.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentOrange.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.event.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: AppTextStyles.pixelSmall.copyWith(
                    fontSize: 14,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.event.description,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
