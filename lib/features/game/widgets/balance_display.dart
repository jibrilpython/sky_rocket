import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';

/// Displays the player's balance in the top bar.
class BalanceDisplay extends StatelessWidget {
  const BalanceDisplay({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkNavyLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.panelBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_rounded,
              color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Text(
            NumberFormatter.formatCurrency(balance),
            style: AppTextStyles.pixelSmall.copyWith(
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}
