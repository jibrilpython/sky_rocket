import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';

/// Betting controls: quick bet buttons, +/- buttons, and bet amount display.
class BetControls extends StatelessWidget {
  const BetControls({
    super.key,
    required this.betAmount,
    required this.enabled,
    required this.onQuickBet,
    required this.onIncrement,
    required this.onDecrement,
  });

  final double betAmount;
  final bool enabled;
  final ValueChanged<double> onQuickBet;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick bet buttons
        Row(
          children: AppConstants.quickBets.map((amount) {
            final isSelected = betAmount == amount;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _PixelButton(
                  label: '\$${amount.toInt()}',
                  color: isSelected
                      ? AppColors.accentOrange
                      : AppColors.darkNavyLight,
                  borderColor: isSelected
                      ? AppColors.accentOrange
                      : AppColors.panelBorder,
                  onTap: enabled ? () => onQuickBet(amount) : null,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Amount display with +/- buttons
        Row(
          children: [
            _PixelButton(
              label: '−',
              color: AppColors.darkNavyLight,
              borderColor: AppColors.panelBorder,
              onTap: enabled ? onDecrement : null,
              width: 48,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.panelBorder, width: 1.5),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      NumberFormatter.formatCurrency(betAmount),
                      style: AppTextStyles.pixelMedium.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _PixelButton(
              label: '+',
              color: AppColors.darkNavyLight,
              borderColor: AppColors.panelBorder,
              onTap: enabled ? onIncrement : null,
              width: 48,
            ),
          ],
        ),
      ],
    );
  }
}

/// A pixel-style button with 3D shadow depth.
class _PixelButton extends StatelessWidget {
  const _PixelButton({
    required this.label,
    required this.color,
    required this.borderColor,
    this.onTap,
    this.width,
  });

  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width,
        height: 42,
        decoration: BoxDecoration(
          color: isEnabled ? color : color.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.6),
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
