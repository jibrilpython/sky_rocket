import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

/// Horizontal scrollable row of colored chips showing last N crash multipliers.
class RoundHistoryBar extends StatelessWidget {
  const RoundHistoryBar({super.key, required this.history});

  final List<double> history;

  Color _chipColor(double value) {
    if (value >= AppConstants.chipGreenThreshold) return AppColors.chipGreen;
    if (value >= AppConstants.chipYellowThreshold) return AppColors.chipYellow;
    return AppColors.chipRed;
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        height: 36,
        alignment: Alignment.center,
        child: Text(
          'No rounds yet',
          style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: history.length,
        separatorBuilder: (_, i) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final value = history[index];
          final color = _chipColor(value);
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
            ),
            child: Text(
              '${value.toStringAsFixed(2)}x',
              style: AppTextStyles.chipText.copyWith(color: color),
            ),
          );
        },
      ),
    );
  }
}
