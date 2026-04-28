import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/player_stats.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/player_stats_provider.dart';

/// Displays player level and XP progress.
class LevelDisplay extends ConsumerWidget {
  const LevelDisplay({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider);
    final nextLevelXpRequired = PlayerStats.getXPForNextLevel(stats.level);
    final currentLevelStartXp = PlayerStats.getTotalXPForLevel(stats.level);
    final xpInCurrentLevel = stats.totalXP - currentLevelStartXp;
    final progress = (xpInCurrentLevel / nextLevelXpRequired).clamp(0.0, 1.0);
    final maxBetUnlock = stats.getMaxBetUnlock();

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.panelBorder.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⭐ LVL ${stats.level}',
              style: AppTextStyles.pixelSmall.copyWith(
                fontSize: 11,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.panelBorder.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.accentGreen.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Full display
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.8),
            AppColors.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.panelBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL',
                style: AppTextStyles.label.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'NEXT: $nextLevelXpRequired XP',
                style: AppTextStyles.label.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Level number
          Row(
            children: [
              Text(
                '${stats.level}',
                style: AppTextStyles.pixelSmall.copyWith(
                  fontSize: 32,
                  color: AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // XP bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            AppColors.panelBorder.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.accentGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$xpInCurrentLevel / $nextLevelXpRequired XP',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Max bet unlock info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.accentGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  size: 14,
                  color: AppColors.accentGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Max Bet Unlocked: \$${maxBetUnlock.toStringAsFixed(0)}',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 9,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
