import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Styled volume slider with label, icon, and value display.
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0,
                max: 1,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(value * 100).toInt()}%',
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
