import 'dart:math';
import 'package:flutter/material.dart';

/// Full-screen coin splash overlay — golden coins burst from the centre,
/// arc outward with gravity, spin, and fade out over ~1.5 s.
///
/// Usage: Stack it on top of the game area and call the [trigger] method
/// via a GlobalKey when the player cashes out.
class CoinSplashOverlay extends StatefulWidget {
  const CoinSplashOverlay({super.key});

  @override
  State<CoinSplashOverlay> createState() => CoinSplashOverlayState();
}

class CoinSplashOverlayState extends State<CoinSplashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Coin> _coins = [];
  final Random _rng = Random();

  static const int _coinCount = 45;
  static const Duration _duration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _duration)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Call this to fire the coin splash from the centre of the overlay.
  void trigger() {
    _coins.clear();
    for (var i = 0; i < _coinCount; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 280 + _rng.nextDouble() * 520;
      _coins.add(_Coin(
        vx: cos(angle) * speed * (0.6 + _rng.nextDouble() * 0.4),
        vy: sin(angle) * speed * 0.9 - 180, // bias upward initially
        spin: (_rng.nextDouble() - 0.5) * 12,
        size: 14 + _rng.nextDouble() * 14,
        delay: _rng.nextDouble() * 0.12, // stagger spawns slightly
        shade: _rng.nextInt(3), // 0 = gold, 1 = bright gold, 2 = pale
      ));
    }
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ctrl.isAnimating && _ctrl.value == 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _CoinPainter(
          coins: _coins,
          progress: _ctrl.value,
          duration: _duration.inMilliseconds / 1000.0,
        ),
      ),
    );
  }
}

class _Coin {
  final double vx, vy, spin, size, delay;
  final int shade;
  _Coin({
    required this.vx,
    required this.vy,
    required this.spin,
    required this.size,
    required this.delay,
    required this.shade,
  });
}

class _CoinPainter extends CustomPainter {
  final List<_Coin> coins;
  final double progress; // 0→1
  final double duration; // seconds

  _CoinPainter({
    required this.coins,
    required this.progress,
    required this.duration,
  });

  static const _gravity = 900.0;

  // Three gold tones
  static const _colors = [
    Color(0xFFFFD700), // classic gold
    Color(0xFFFFC107), // amber gold
    Color(0xFFFFECB3), // pale gold highlight
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final t = progress * duration;

    for (final coin in coins) {
      final ct = t - coin.delay;
      if (ct < 0) continue;

      final x = cx + coin.vx * ct;
      final y = cy + coin.vy * ct + 0.5 * _gravity * ct * ct;

      // Fade out in last 40% of animation
      final life = 1.0 - progress;
      final alpha = (life / 0.4).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      // Skip coins that have fallen off screen
      if (y > size.height + 40) continue;

      // Spin creates an "ellipse width" oscillation — looks like a spinning coin
      final spinAngle = coin.spin * ct;
      final scaleX = cos(spinAngle).abs().clamp(0.25, 1.0);

      final coinColor = _colors[coin.shade];

      canvas.save();
      canvas.translate(x, y);
      canvas.scale(scaleX, 1.0);

      final r = coin.size / 2;

      // Outer rim
      canvas.drawCircle(
        Offset.zero,
        r,
        Paint()..color = coinColor.withValues(alpha: alpha),
      );
      // Inner darker ring
      canvas.drawCircle(
        Offset.zero,
        r * 0.78,
        Paint()
          ..color = const Color(0xFFFF8F00).withValues(alpha: alpha * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // Glint highlight
      canvas.drawCircle(
        Offset(-r * 0.22, -r * 0.25),
        r * 0.28,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.55),
      );

      // Dollar symbol
      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$',
          style: TextStyle(
            color: const Color(0xFFE65100).withValues(alpha: alpha),
            fontSize: coin.size * 0.52,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) => old.progress != progress;
}
