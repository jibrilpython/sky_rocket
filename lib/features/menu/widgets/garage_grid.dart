import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/rocket_skin.dart';

/// 3x2 grid of rocket skin selection cards.
class GarageGrid extends StatelessWidget {
  const GarageGrid({
    super.key,
    required this.selectedSkinId,
    required this.onSkinSelected,
  });

  final int selectedSkinId;
  final ValueChanged<int> onSkinSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: RocketSkin.allSkins.length,
      itemBuilder: (context, index) {
        final skin = RocketSkin.allSkins[index];
        final isSelected = skin.id == selectedSkinId;
        return GestureDetector(
          onTap: () => onSkinSelected(skin.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentOrange
                    : AppColors.panelBorder,
                width: isSelected ? 2.5 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentOrange.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mini spaceship preview
                SizedBox(
                  width: 52,
                  height: 38,
                  child: CustomPaint(
                    painter: _MiniSpaceshipPainter(skin: skin),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  skin.name,
                  style: AppTextStyles.chipText.copyWith(
                    color: isSelected
                        ? AppColors.accentOrange
                        : AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.accentOrange,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Draws a scaled-down preview of the spaceship using the same visual language
/// as [RocketComponent] — saucer body, dome cockpit, engine pods, wings.
class _MiniSpaceshipPainter extends CustomPainter {
  final RocketSkin skin;
  _MiniSpaceshipPainter({required this.skin});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // ── Wing stabilisers ─────────────────────────────────
    final leftWing = Path()
      ..moveTo(cx - w * 0.28, cy + h * 0.08)
      ..lineTo(cx - w * 0.50, cy + h * 0.28)
      ..lineTo(cx - w * 0.38, cy + h * 0.32)
      ..lineTo(cx - w * 0.20, cy + h * 0.16)
      ..close();
    final rightWing = Path()
      ..moveTo(cx + w * 0.28, cy + h * 0.08)
      ..lineTo(cx + w * 0.50, cy + h * 0.28)
      ..lineTo(cx + w * 0.38, cy + h * 0.32)
      ..lineTo(cx + w * 0.20, cy + h * 0.16)
      ..close();
    canvas.drawPath(leftWing, Paint()..color = skin.finColor);
    canvas.drawPath(leftWing, outlinePaint);
    canvas.drawPath(rightWing, Paint()..color = skin.finColor);
    canvas.drawPath(rightWing, outlinePaint);

    // ── Main fuselage (saucer ellipse) ───────────────────
    final fuselageRect = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.06),
      width: w * 0.80,
      height: h * 0.30,
    );
    final bodyGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [skin.bodyColor, skin.bodyColor.withValues(alpha: 0.65)],
    );
    canvas.drawOval(
        fuselageRect, Paint()..shader = bodyGrad.createShader(fuselageRect));
    canvas.drawOval(fuselageRect, outlinePaint);

    // ── Engine pods ──────────────────────────────────────
    final podPaint = Paint()..color = skin.finColor;
    for (final px in [cx - w * 0.25, cx + w * 0.25]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(px, cy + h * 0.18), width: w * 0.2, height: h * 0.1),
          const Radius.circular(3),
        ),
        podPaint,
      );
    }

    // ── Flame nozzles (3 dots) ───────────────────────────
    final flamePaint = Paint()
      ..color = skin.flameColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    for (final fx in [cx - w * 0.25, cx, cx + w * 0.25]) {
      canvas.drawCircle(Offset(fx, cy + h * 0.28), w * 0.055, flamePaint);
    }

    // ── Domed cockpit (upper half only) ──────────────────
    final domeRect = Rect.fromCenter(
      center: Offset(cx, cy - h * 0.05),
      width: w * 0.38,
      height: h * 0.26,
    );
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(cx - w * 0.22, cy - h * 0.22, w * 0.44, h * 0.20));
    canvas.drawOval(domeRect, Paint()..color = skin.noseColor);
    canvas.drawOval(domeRect, outlinePaint);
    canvas.restore();

    // ── Porthole window ──────────────────────────────────
    canvas.drawCircle(
        Offset(cx, cy - h * 0.08), w * 0.09, Paint()..color = skin.windowColor);
    canvas.drawCircle(Offset(cx, cy - h * 0.08), w * 0.09, outlinePaint);

    // ── Glare arc on dome ────────────────────────────────
    final glarePath = Path()
      ..moveTo(cx - w * 0.05, cy - h * 0.16)
      ..quadraticBezierTo(cx + w * 0.02, cy - h * 0.18, cx + w * 0.07, cy - h * 0.12);
    canvas.drawPath(
      glarePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // ── Fuselage stripe ──────────────────────────────────
    canvas.drawLine(
      Offset(cx - w * 0.30, cy + h * 0.04),
      Offset(cx + w * 0.30, cy + h * 0.04),
      Paint()
        ..color = skin.noseColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniSpaceshipPainter old) =>
      old.skin.id != skin.id;
}
