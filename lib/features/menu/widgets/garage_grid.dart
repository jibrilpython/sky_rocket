import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/rocket_skin.dart';

/// Premium 3x2 grid of rocket skin selection cards with
/// animated selection state, glow effects, and skin preview badges.
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
        childAspectRatio: 0.82,
      ),
      itemCount: RocketSkin.allSkins.length,
      itemBuilder: (context, index) {
        final skin = RocketSkin.allSkins[index];
        final isSelected = skin.id == selectedSkinId;
        return _SkinCard(
          skin: skin,
          isSelected: isSelected,
          onTap: () => onSkinSelected(skin.id),
        );
      },
    );
  }
}

class _SkinCard extends StatefulWidget {
  const _SkinCard({
    required this.skin,
    required this.isSelected,
    required this.onTap,
  });

  final RocketSkin skin;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SkinCard> createState() => _SkinCardState();
}

class _SkinCardState extends State<_SkinCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isSelected) _glowCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_SkinCard old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _glowCtrl.repeat(reverse: true);
    } else if (!widget.isSelected && old.isSelected) {
      _glowCtrl.stop();
      _glowCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (_, child) {
          final glowAlpha = widget.isSelected ? 0.15 + _glowCtrl.value * 0.2 : 0.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSelected
                    ? [
                        AppColors.accentOrange.withValues(alpha: 0.15),
                        AppColors.surface.withValues(alpha: 0.8),
                      ]
                    : [
                        AppColors.surface,
                        AppColors.surface.withValues(alpha: 0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.accentOrange
                    : AppColors.panelBorder.withValues(alpha: 0.5),
                width: widget.isSelected ? 2.0 : 1.0,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentOrange
                            .withValues(alpha: glowAlpha),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                // Mini spaceship preview
                SizedBox(
                  width: 52,
                  height: 38,
                  child: CustomPaint(
                    painter: _MiniSpaceshipPainter(skin: widget.skin),
                  ),
                ),
                const SizedBox(height: 8),
                // Skin name
                Text(
                  widget.skin.name,
                  style: AppTextStyles.chipText.copyWith(
                    color: widget.isSelected
                        ? AppColors.accentOrange
                        : AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 4),
                // Color dots preview
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ColorDot(color: widget.skin.bodyColor),
                    const SizedBox(width: 3),
                    _ColorDot(color: widget.skin.noseColor),
                    const SizedBox(width: 3),
                    _ColorDot(color: widget.skin.flameColor),
                  ],
                ),
              ],
            ),

            // Selected badge
            if (widget.isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentOrange,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentOrange.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small colour preview dot.
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
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
