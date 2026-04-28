import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';

/// Betting controls: quick bet buttons, +/- buttons, and bet amount display.
/// Enhanced with gradient selected state and subtle animations.
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
                  isSelected: isSelected,
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
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surface,
                      AppColors.surface.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.toll_rounded,
                          color: AppColors.gold.withValues(alpha: 0.5),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          NumberFormatter.formatCurrency(betAmount),
                          style: AppTextStyles.pixelMedium.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                      ],
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

/// A pixel-style button with 3D shadow depth and optional selected state glow.
class _PixelButton extends StatelessWidget {
  const _PixelButton({
    required this.label,
    required this.color,
    required this.borderColor,
    this.onTap,
    this.width,
    this.isSelected = false,
  });

  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;
  final double? width;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: width,
        height: 42,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isSelected ? null : (isEnabled ? color : color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withValues(alpha: 0.3)
                  : AppColors.shadow.withValues(alpha: 0.6),
              blurRadius: isSelected ? 8 : 0,
              offset: isSelected ? Offset.zero : const Offset(0, 3),
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
