import 'package:flutter/material.dart';
import '../../../models/achievement.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Achievement badge display that shows when unlocked.
class AchievementBadgeNotification extends StatefulWidget {
  const AchievementBadgeNotification({
    super.key,
    required this.achievement,
  });

  final Achievement achievement;

  @override
  State<AchievementBadgeNotification> createState() =>
      _AchievementBadgeNotificationState();
}

class _AchievementBadgeNotificationState
    extends State<AchievementBadgeNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _slideCtrl.forward();

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _slideCtrl.reverse().then((_) {
          if (mounted) {
            setState(() => _isVisible = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentOrange.withValues(alpha: 0.15),
                AppColors.accentOrange.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentOrange.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentOrange.withValues(alpha: 0.3),
                      AppColors.gold.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.achievement.iconEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Achievement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ACHIEVEMENT UNLOCKED',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 8,
                        letterSpacing: 1.2,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.achievement.title,
                      style: AppTextStyles.pixelSmall.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+ ${widget.achievement.xpReward} XP',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

/// Achievement badge display for the profile/stats screen.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    this.compact = false,
  });

  final Achievement achievement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${achievement.title}\n${achievement.description}',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: achievement.unlocked
              ? AppColors.accentOrange.withValues(alpha: 0.15)
              : AppColors.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: achievement.unlocked
                ? AppColors.accentOrange.withValues(alpha: 0.5)
                : AppColors.panelBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.iconEmoji,
              style: TextStyle(
                fontSize: compact ? 24 : 32,
              ),
            ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 8,
                    color: achievement.unlocked
                        ? AppColors.accentOrange
                        : AppColors.textMuted,
                  ),
                ),
              ),
            if (!compact && achievement.unlocked)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${achievement.xpReward} XP',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 7,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            if (achievement.unlocked && !compact)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGreen,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
