import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';

/// Displays the player's balance in the top bar with a pulsing
/// coin icon, animated value transitions, and gradient background.
class BalanceDisplay extends StatefulWidget {
  const BalanceDisplay({super.key, required this.balance});

  final double balance;

  @override
  State<BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<BalanceDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  double _prevBalance = 0;
  bool _justChanged = false;

  @override
  void initState() {
    super.initState();
    _prevBalance = widget.balance;
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didUpdateWidget(BalanceDisplay old) {
    super.didUpdateWidget(old);
    if (old.balance != widget.balance) {
      _justChanged = true;
      _prevBalance = old.balance;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _justChanged = false);
      });
    }
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUp = widget.balance > _prevBalance;
    final flashColor = isUp ? AppColors.accentGreen : AppColors.accentRed;

    return AnimatedContainer(
      height: 40,
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _justChanged
              ? [
                  flashColor.withValues(alpha: 0.25),
                  flashColor.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.darkNavyLight,
                  AppColors.darkNavyLight.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _justChanged
              ? flashColor.withValues(alpha: 0.5)
              : AppColors.panelBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _justChanged
                ? flashColor.withValues(alpha: 0.2)
                : AppColors.shadow,
            blurRadius: _justChanged ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated shimmer on the coin icon
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, _) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gold,
                      AppColors.gold.withValues(alpha: 0.4),
                      AppColors.gold,
                    ],
                    stops: [
                      (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                      _shimmerCtrl.value,
                      (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BALANCE',
                style: AppTextStyles.label.copyWith(
                  fontSize: 7,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 1),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, isUp ? -0.5 : 0.5),
                      end: Offset.zero,
                    ).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: Text(
                  NumberFormatter.formatCurrency(widget.balance),
                  key: ValueKey<double>(widget.balance),
                  style: AppTextStyles.pixelSmall.copyWith(
                    color: AppColors.gold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
