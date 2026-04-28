import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Premium volume slider with icon background, custom track,
/// and percentage display in a contained card.
class VolumeSlider extends StatelessWidget {
  const VolumeSlider({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).toInt();
    final isZero = pct == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.panelBorder.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isZero
                  ? AppColors.textMuted.withValues(alpha: 0.1)
                  : AppColors.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isZero
                  ? AppColors.textMuted.withValues(alpha: 0.4)
                  : AppColors.accentOrange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Label
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isZero ? AppColors.textMuted : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: AppColors.accentOrange,
                inactiveTrackColor: AppColors.panelBorder.withValues(alpha: 0.4),
                thumbColor: AppColors.accentOrange,
                overlayColor: AppColors.accentOrange.withValues(alpha: 0.12),
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0,
                max: 1,
              ),
            ),
          ),
          // Percentage badge
          Container(
            width: 42,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isZero
                  ? AppColors.textMuted.withValues(alpha: 0.1)
                  : AppColors.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$pct%',
              style: AppTextStyles.label.copyWith(
                color: isZero ? AppColors.textMuted : AppColors.accentOrange,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
