import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A cloud that scrolls downward to create the illusion of upward flight.
class CloudComponent extends PositionComponent {
  CloudComponent({
    required Vector2 gameSize,
    double? startY,
  }) : super(
          anchor: Anchor.center,
        ) {
    final random = Random();
    final cloudWidth = 40.0 + random.nextDouble() * 60;
    final cloudHeight = 14.0 + random.nextDouble() * 12;

    size = Vector2(cloudWidth, cloudHeight);
    position = Vector2(
      random.nextDouble() * gameSize.x,
      startY ?? random.nextDouble() * gameSize.y,
    );

    _speed = 30 + random.nextDouble() * 50;
    _opacity = 0.15 + random.nextDouble() * 0.35;
    _gameWidth = gameSize.x;
    _gameHeight = gameSize.y;
  }

  double _speed = 40;
  double _opacity = 0.3;
  double _gameWidth = 0;
  double _gameHeight = 0;
  bool _isScrolling = false;

  void startScrolling() => _isScrolling = true;
  void stopScrolling() => _isScrolling = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isScrolling) return;

    position.y += _speed * dt;

    // Respawn at top when off screen
    if (position.y > _gameHeight + size.y) {
      position.y = -size.y;
      position.x = Random().nextDouble() * _gameWidth;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: _opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Draw cloud as overlapping rounded rectangles
    final mainRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.y * 0.2, size.x, size.y * 0.6),
      Radius.circular(size.y * 0.3),
    );
    canvas.drawRRect(mainRect, paint);

    // Top bumps
    final bumpPaint = Paint()
      ..color = Colors.white.withValues(alpha: _opacity * 0.8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.3, size.y * 0.3),
        width: size.x * 0.4,
        height: size.y * 0.5,
      ),
      bumpPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.65, size.y * 0.25),
        width: size.x * 0.35,
        height: size.y * 0.45,
      ),
      bumpPaint,
    );
  }
}
