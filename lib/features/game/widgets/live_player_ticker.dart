import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Animated "LIVE PLAYERS" ticker that smoothly shifts between
/// random player counts to give the impression of a busy lobby.
class LivePlayerTicker extends StatefulWidget {
  const LivePlayerTicker({super.key});

  @override
  State<LivePlayerTicker> createState() => _LivePlayerTickerState();
}

class _LivePlayerTickerState extends State<LivePlayerTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotPulse;
  late Timer _countTimer;
  int _playerCount = 1247;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _dotPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _countTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        // Drift ±5–20 players each tick
        final delta = 5 + _rng.nextInt(16);
        _playerCount += _rng.nextBool() ? delta : -delta;
        _playerCount = _playerCount.clamp(980, 2400);
      });
    });
  }

  @override
  void dispose() {
    _dotPulse.dispose();
    _countTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing live dot
          AnimatedBuilder(
            animation: _dotPulse,
            builder: (_, _) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen
                        .withValues(alpha: 0.3 + _dotPulse.value * 0.5),
                    blurRadius: 4 + _dotPulse.value * 4,
                    spreadRadius: _dotPulse.value * 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              '$_playerCount',
              key: ValueKey<int>(_playerCount),
              style: AppTextStyles.chipText.copyWith(
                color: AppColors.accentGreen,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'ONLINE',
            style: AppTextStyles.chipText.copyWith(
              color: AppColors.accentGreen.withValues(alpha: 0.7),
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }
}
