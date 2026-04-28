import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../providers/game_provider.dart';

/// Context-aware action button that changes based on game phase.
///
/// - Waiting + hasBet: greyed "BET PLACED" label
/// - Waiting + !hasBet: orange "PLACE BET" button
/// - Flying + hasBet: green pulsing "CASH OUT $XX.XX" button
/// - Flying + !hasBet: grey "BETTING CLOSED" bar
/// - Crashed / CashedOut: result display
class CashOutButton extends StatefulWidget {
  const CashOutButton({
    super.key,
    required this.phase,
    required this.hasBet,
    required this.multiplier,
    required this.betAmount,
    required this.onPlaceBet,
    required this.onCashOut,
  });

  final GamePhase phase;
  final bool hasBet;
  final double multiplier;
  final double betAmount;
  final VoidCallback onPlaceBet;
  final VoidCallback onCashOut;

  @override
  State<CashOutButton> createState() => _CashOutButtonState();
}

class _CashOutButtonState extends State<CashOutButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.phase) {
      case GamePhase.waiting:
        return widget.hasBet ? _buildBetPlaced() : _buildPlaceBet();
      case GamePhase.flying:
        return widget.hasBet ? _buildCashOut() : _buildBettingClosed();
      case GamePhase.crashed:
        return widget.hasBet ? _buildCrashed() : _buildWaitingNext();
      case GamePhase.cashedOut:
        return _buildCashedOutResult();
    }
  }

  Widget _buildPlaceBet() {
    return _ActionButton(
      label: 'PLACE BET',
      color: AppColors.accentOrange,
      shadowColor: const Color(0xFFCC5500),
      onTap: widget.onPlaceBet,
    );
  }

  Widget _buildBetPlaced() {
    return _ActionButton(
      label: 'BET PLACED ✓',
      color: AppColors.darkNavyLight,
      shadowColor: AppColors.shadow,
    );
  }

  Widget _buildCashOut() {
    final winnings = widget.betAmount * widget.multiplier;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.03);
        return Transform.scale(
          scale: scale,
          child: _ActionButton(
            label: 'CASH OUT ${NumberFormatter.formatCurrency(winnings)}',
            color: AppColors.accentGreen,
            shadowColor: const Color(0xFF2E7D32),
            onTap: widget.onCashOut,
            glowing: true,
          ),
        );
      },
    );
  }

  Widget _buildBettingClosed() {
    return _ActionButton(
      label: 'BETTING CLOSED',
      color: AppColors.surfaceLight,
      shadowColor: AppColors.shadow,
    );
  }

  Widget _buildCrashed() {
    return _ActionButton(
      label: 'CRASHED 💥',
      color: AppColors.accentRed.withValues(alpha: 0.7),
      shadowColor: const Color(0xFF8B0000),
    );
  }

  Widget _buildWaitingNext() {
    return _ActionButton(
      label: 'NEXT ROUND SOON...',
      color: AppColors.surfaceLight,
      shadowColor: AppColors.shadow,
    );
  }

  Widget _buildCashedOutResult() {
    final winnings = widget.betAmount * widget.multiplier;
    return _ActionButton(
      label: 'WON ${NumberFormatter.formatCurrency(winnings)} 🎉',
      color: AppColors.accentGreen.withValues(alpha: 0.8),
      shadowColor: const Color(0xFF2E7D32),
      glowing: true,
    );
  }
}

/// An action button with an animated shimmer/glare sweep.
///
/// A light bar sweeps left→right across the button surface every 2.4 s —
/// the same "shiny" effect seen on premium slot machine buttons.
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.shadowColor,
    this.onTap,
    this.glowing = false,
  });

  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onTap;
  final bool glowing;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmerAnim =
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (context, child) {
          // Outer container owns the border + shadow — no clipping here.
          // Inner ClipRRect clips only the fill + shimmer, leaving the
          // border fully visible and perfectly aligned.
          return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor,
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                ),
                if (widget.glowing)
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: ClipRRect(
              // Clip radius is border-radius minus border-width so the
              // inner fill sits flush inside the border.
              borderRadius: BorderRadius.circular(10.5),
              child: Stack(
                children: [
                  // Filled background
                  Positioned.fill(
                    child: Container(
                      color: isEnabled
                          ? widget.color
                          : widget.color.withValues(alpha: 0.5),
                    ),
                  ),

                  // Button label — always perfectly centred
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.button.copyWith(
                            letterSpacing: 0.8,
                            color: isEnabled
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Shimmer sweep — light bar gliding left→right
                  if (isEnabled)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Transform.translate(
                          offset: Offset(
                            (_shimmerAnim.value * 3 - 1.0) * 400,
                            0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
