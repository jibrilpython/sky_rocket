import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Reusable stat card for the dashboard.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkNavyLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.panelBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.pixelSmall.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
