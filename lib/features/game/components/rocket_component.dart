import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../models/rocket_skin.dart';

/// Wide-body pixel-art spaceship drawn with Canvas paths.
///
/// Features:
///   • Saucer fuselage with glare arcs
///   • Domed cockpit with porthole shine
///   • Engine pods + 3-nozzle thruster jets with glow
///   • Banking tilt into sway
///   • Smooth vertical bob (even at rest)
///   • Multi-colour animated thrust flame trail
class RocketComponent extends PositionComponent {
  RocketComponent({
    required this.skin,
    required Vector2 gameSize,
  }) : super(
          size: Vector2(72, 56),
          anchor: Anchor.center,
        ) {
    position = Vector2(gameSize.x / 2, gameSize.y * 0.62);
    _baseX = position.x;
    _baseY = position.y;
    _targetY = gameSize.y * 0.38;
  }

  final RocketSkin skin;

  double _baseX = 0;
  double _baseY = 0;
  double _targetY = 0;
  double _swayTime = 0;
  double _bobTime = 0;
  bool _isFlying = false;
  bool _hasExploded = false;
  double _tiltAngle = 0; // radians — banking into sway

  // Thrust particle accumulator
  double _particleTimer = 0;
  final List<_ThrustParticle> _thrustParticles = [];
  final Random _random = Random();

  // Glare shimmer pulse on cockpit
  double _glarePhase = 0;

  void startFlying() {
    _isFlying = true;
    _hasExploded = false;
    _swayTime = 0;
  }

  void stopFlying() {
    _isFlying = false;
  }

  void explode() {
    _hasExploded = true;
    _isFlying = false;
  }

  void resetPosition(Vector2 gameSize) {
    position = Vector2(gameSize.x / 2, gameSize.y * 0.62);
    _baseX = position.x;
    _baseY = position.y;
    _targetY = gameSize.y * 0.38;
    _hasExploded = false;
    _isFlying = false;
    _thrustParticles.clear();
    _tiltAngle = 0;
    _swayTime = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hasExploded) return;

    _bobTime += dt;
    _glarePhase += dt * 1.8;

    if (_isFlying) {
      _swayTime += dt;

      // Sine wave sway
      final swayX = sin(_swayTime * 2.2) * 14;
      position.x = _baseX + swayX;

      // Bank tilt proportional to sway velocity (cos = derivative of sin)
      final swayVelocity = cos(_swayTime * 2.2);
      _tiltAngle = swayVelocity * 0.18; // ~10° max

      // Smoothly move upward
      position.y = lerpDouble(position.y, _targetY, dt * 0.55)!;

      // Thrust particles
      _particleTimer += dt;
      if (_particleTimer > 0.025) {
        _particleTimer = 0;
        _spawnThrustParticles();
      }
    } else {
      // Idle bob — gentle float
      position.y = _baseY + sin(_bobTime * 1.4) * 5;
      _tiltAngle = 0;
    }

    // Update thrust particles
    _thrustParticles.removeWhere((p) {
      p.update(dt);
      return p.life <= 0;
    });
  }

  void _spawnThrustParticles() {
    // Three nozzle positions (local coords, Y pointing down)
    final nozzles = [
      Offset(size.x * 0.25, size.y * 0.78), // left
      Offset(size.x * 0.50, size.y * 0.85), // centre
      Offset(size.x * 0.75, size.y * 0.78), // right
    ];

    for (final nozzle in nozzles) {
      final worldX = position.x - size.x / 2 + nozzle.dx;
      final worldY = position.y - size.y / 2 + nozzle.dy;

      // Main flame blob
      _thrustParticles.add(_ThrustParticle(
        x: worldX + (_random.nextDouble() - 0.5) * 8,
        y: worldY,
        vx: (_random.nextDouble() - 0.5) * 20,
        vy: 55 + _random.nextDouble() * 80,
        life: 0.25 + _random.nextDouble() * 0.35,
        color: _random.nextBool() ? skin.flameColor : skin.flameColor.withValues(alpha: 0.7),
        size: 4 + _random.nextDouble() * 5,
      ));

      // Bright inner core
      if (_random.nextBool()) {
        _thrustParticles.add(_ThrustParticle(
          x: worldX,
          y: worldY,
          vx: (_random.nextDouble() - 0.5) * 8,
          vy: 30 + _random.nextDouble() * 40,
          life: 0.15 + _random.nextDouble() * 0.15,
          color: Colors.white,
          size: 2 + _random.nextDouble() * 2.5,
        ));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_hasExploded) return;

    // Save state, apply banking tilt around ship centre
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_tiltAngle);
    canvas.translate(-size.x / 2, -size.y / 2);

    // ── Draw thrust particles (behind ship) ───────────────
    for (final p in _thrustParticles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        Offset(
          p.x - position.x + size.x / 2,
          p.y - position.y + size.y / 2,
        ),
        p.size,
        paint,
      );
    }

    _drawShip(canvas);

    canvas.restore();
  }

  void _drawShip(Canvas canvas) {
    final cx = size.x / 2; // 36
    final cy = size.y / 2; // 28

    final nosePaint = Paint()..color = skin.noseColor;
    final finPaint = Paint()..color = skin.finColor;
    final windowPaint = Paint()..color = skin.windowColor;
    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // ── Engine glow beneath nozzles ───────────────────────
    if (_isFlying) {
      final glowPositions = [cx - 18, cx, cx + 18];
      for (final gx in glowPositions) {
        canvas.drawCircle(
          Offset(gx, cy + 18),
          9,
          Paint()
            ..color = skin.flameColor.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }

    // ── Rear wing stabilisers ────────────────────────────
    final leftWingPath = Path()
      ..moveTo(cx - 22, cy + 6)
      ..lineTo(cx - 36, cy + 20)
      ..lineTo(cx - 28, cy + 22)
      ..lineTo(cx - 16, cy + 12)
      ..close();
    final rightWingPath = Path()
      ..moveTo(cx + 22, cy + 6)
      ..lineTo(cx + 36, cy + 20)
      ..lineTo(cx + 28, cy + 22)
      ..lineTo(cx + 16, cy + 12)
      ..close();
    canvas.drawPath(leftWingPath, finPaint);
    canvas.drawPath(leftWingPath, outlinePaint);
    canvas.drawPath(rightWingPath, finPaint);
    canvas.drawPath(rightWingPath, outlinePaint);

    // ── Main fuselage (wide saucer ellipse) ───────────────
    final fuselageRect = Rect.fromCenter(
      center: Offset(cx, cy + 4),
      width: 58,
      height: 22,
    );
    // Subtle gradient on body — lighter at top, darker at bottom
    final bodyGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        skin.bodyColor.withValues(alpha: 1.0),
        skin.bodyColor.withValues(alpha: 0.7),
      ],
    );
    canvas.drawOval(
      fuselageRect,
      Paint()..shader = bodyGrad.createShader(fuselageRect),
    );
    canvas.drawOval(fuselageRect, outlinePaint);

    // ── Body glare highlight ──────────────────────────────
    final glareHi = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 4, cy - 1), width: 28, height: 6),
      glareHi,
    );

    // ── Engine pods (left + right) ─────────────────────────
    final podPaint = Paint()..color = skin.finColor;
    // Left pod
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 20, cy + 10), width: 14, height: 8),
        const Radius.circular(4),
      ),
      podPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 20, cy + 10), width: 14, height: 8),
        const Radius.circular(4),
      ),
      outlinePaint,
    );
    // Right pod
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 20, cy + 10), width: 14, height: 8),
        const Radius.circular(4),
      ),
      podPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 20, cy + 10), width: 14, height: 8),
        const Radius.circular(4),
      ),
      outlinePaint,
    );

    // Nozzle circles on pods + centre
    final nozzlePaint = Paint()..color = Colors.black54;
    for (final nx in [cx - 20.0, cx + 0.0, cx + 20.0]) {
      canvas.drawCircle(Offset(nx, cy + 17), 3.5, nozzlePaint);
    }

    // ── Domed cockpit ────────────────────────────────────
    final domeRect = Rect.fromCenter(
      center: Offset(cx, cy - 5),
      width: 26,
      height: 18,
    );
    // Clip to upper hemisphere
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(cx - 14, cy - 14, 28, 14));
    canvas.drawOval(domeRect, nosePaint);
    canvas.drawOval(domeRect, outlinePaint);
    canvas.restore();

    // ── Cockpit window ───────────────────────────────────
    canvas.drawCircle(Offset(cx, cy - 7), 6, windowPaint);
    canvas.drawCircle(
      Offset(cx, cy - 7),
      6,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // ── Glare arc on cockpit window ───────────────────────
    // Animated shimmer pulse
    final glareAlpha = (sin(_glarePhase) * 0.5 + 0.5) * 0.65 + 0.1;
    final glarePath = Path()
      ..moveTo(cx - 3.5, cy - 10.5)
      ..quadraticBezierTo(cx + 1, cy - 12.5, cx + 4, cy - 9);
    canvas.drawPath(
      glarePath,
      Paint()
        ..color = Colors.white.withValues(alpha: glareAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // ── Fuselage stripe ──────────────────────────────────
    canvas.drawLine(
      Offset(cx - 22, cy + 4),
      Offset(cx + 22, cy + 4),
      Paint()
        ..color = skin.noseColor.withValues(alpha: 0.55)
        ..strokeWidth = 2,
    );
  }
}

/// Internal thrust particle for the spaceship trail.
class _ThrustParticle {
  _ThrustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  }) : maxLife = life;

  double x, y, vx, vy;
  double life;
  final double maxLife;
  final Color color;
  double size;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    size *= 0.96;
  }
}
