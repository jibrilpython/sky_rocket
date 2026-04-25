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
                // Mini pixel rocket preview
                SizedBox(
                  width: 30,
                  height: 50,
                  child: CustomPaint(
                    painter: _MiniRocketPainter(skin: skin),
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

/// Draws a small preview of the rocket with the given skin colors.
class _MiniRocketPainter extends CustomPainter {
  final RocketSkin skin;

  _MiniRocketPainter({required this.skin});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.22, w * 0.6, h * 0.52),
        const Radius.circular(3),
      ),
      Paint()..color = skin.bodyColor,
    );

    // Nose
    final nose = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.2, h * 0.22)
      ..lineTo(w * 0.8, h * 0.22)
      ..close();
    canvas.drawPath(nose, Paint()..color = skin.noseColor);

    // Window
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.38),
      w * 0.12,
      Paint()..color = skin.windowColor,
    );

    // Fins
    final lFin = Path()
      ..moveTo(w * 0.2, h * 0.6)
      ..lineTo(w * 0.02, h * 0.76)
      ..lineTo(w * 0.2, h * 0.74)
      ..close();
    canvas.drawPath(lFin, Paint()..color = skin.finColor);

    final rFin = Path()
      ..moveTo(w * 0.8, h * 0.6)
      ..lineTo(w * 0.98, h * 0.76)
      ..lineTo(w * 0.8, h * 0.74)
      ..close();
    canvas.drawPath(rFin, Paint()..color = skin.finColor);

    // Flame
    final flame = Path()
      ..moveTo(w * 0.28, h * 0.74)
      ..quadraticBezierTo(w * 0.5, h * 0.98, w * 0.72, h * 0.74);
    canvas.drawPath(
      flame,
      Paint()
        ..color = skin.flameColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRocketPainter old) =>
      old.skin.id != skin.id;
}
