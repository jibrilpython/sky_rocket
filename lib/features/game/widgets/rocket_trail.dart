import 'package:flutter/material.dart';
import '../../../models/rocket_skin.dart';

/// Animated rocket trail that follows behind the rocket during flight.
class RocketTrail extends StatefulWidget {
  const RocketTrail({
    super.key,
    required this.skin,
    required this.isFlying,
    required this.rocketY,
  });

  final RocketSkin skin;
  final bool isFlying;
  final double rocketY;

  @override
  State<RocketTrail> createState() => _RocketTrailState();
}

class _RocketTrailState extends State<RocketTrail>
    with SingleTickerProviderStateMixin {
  late AnimationController _trailCtrl;
  final List<TrailParticle> _trailParticles = [];

  @override
  void initState() {
    super.initState();
    _trailCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void didUpdateWidget(RocketTrail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlying && !oldWidget.isFlying) {
      _trailCtrl.repeat();
    } else if (!widget.isFlying && oldWidget.isFlying) {
      _trailCtrl.stop();
      _trailParticles.clear();
    }
  }

  @override
  void dispose() {
    _trailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _trailCtrl,
      builder: (context, child) {
        // Add new trail particles as the rocket flies
        if (widget.isFlying && _trailCtrl.value % 0.05 < 0.02) {
          _trailParticles.add(
            TrailParticle(
              y: widget.rocketY,
              createdAt: _trailCtrl.value,
              color: widget.skin.flameColor,
            ),
          );

          // Keep list size manageable
          if (_trailParticles.length > 30) {
            _trailParticles.removeAt(0);
          }
        }

        return CustomPaint(
          painter: _TrailPainter(
            particles: _trailParticles,
            progress: _trailCtrl.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class TrailParticle {
  final double y;
  final double createdAt;
  final Color color;

  TrailParticle({
    required this.y,
    required this.createdAt,
    required this.color,
  });
}

class _TrailPainter extends CustomPainter {
  final List<TrailParticle> particles;
  final double progress;

  _TrailPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final age = progress - particle.createdAt;
      if (age < 0 || age > 1.0) continue;

      // Fade out over time
      final alpha = (1.0 - age) * 200;
      final paint = Paint()
        ..color = particle.color.withValues(alpha: alpha / 255)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Trail expands slightly
      final width = 12 + age * 20;
      final height = 20 + age * 10;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, particle.y),
            width: width,
            height: height,
          ),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles.length != particles.length;
  }
}
