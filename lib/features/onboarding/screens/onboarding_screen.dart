import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/onboarding_provider.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  // Stars animation
  late AnimationController _starsController;
  final List<_TwinkleStar> _stars = [];

  // Rocket bounce animation
  late AnimationController _rocketBounce;
  late Animation<double> _rocketBounceAnim;

  @override
  void initState() {
    super.initState();
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _rocketBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _rocketBounceAnim =
        Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(
      parent: _rocketBounce,
      curve: Curves.easeInOut,
    ));

    // Generate stars
    final random = Random();
    for (var i = 0; i < 80; i++) {
      _stars.add(_TwinkleStar(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.5 + random.nextDouble() * 1.5,
        speed: 0.5 + random.nextDouble() * 2,
        phase: random.nextDouble() * pi * 2,
      ));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _starsController.dispose();
    _rocketBounce.dispose();
    super.dispose();
  }

  void _onGetStarted() async {
    final name = _nameController.text.trim();
    await ref
        .read(onboardingProvider.notifier)
        .completeOnboarding(name.isEmpty ? 'Pilot' : name);
    if (mounted) {
      context.go('/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated stars background
          AnimatedBuilder(
            animation: _starsController,
            builder: (context, child) {
              return CustomPaint(
                painter: _StarfieldPainter(
                  stars: _stars,
                  time: _starsController.value * 10,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Sky gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC0D1B2A),
                  Color(0xFF0D1B2A),
                ],
              ),
            ),
          ),

          // Pages
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      // Page 1: Logo + Tagline
                      OnboardingPageWidget(
                        icon: AnimatedBuilder(
                          animation: _rocketBounceAnim,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _rocketBounceAnim.value),
                              child: child,
                            );
                          },
                          child: _buildPixelSpaceship(100),
                        ),
                        title: 'SKY ROCKET',
                        description: 'How high can you fly?',
                      ),

                      // Page 2: How to play
                      OnboardingPageWidget(
                        icon: _buildHowToPlayIcon(),
                        title: 'HOW TO PLAY',
                        description:
                            'Place your bet, watch the spaceship fly,\ncash out before it crashes!',
                      ),

                      // Page 3: Username
                      OnboardingPageWidget(
                        icon: Icon(
                          Icons.person_outline_rounded,
                          size: 80,
                          color: AppColors.accentOrange,
                        ),
                        title: 'ENTER YOUR NAME',
                        description: 'Choose your pilot name',
                        child: _buildNameInput(),
                      ),
                    ],
                  ),
                ),

                // Indicator + Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    children: [
                      OnboardingIndicator(
                        count: 3,
                        currentIndex: _currentPage,
                      ),
                      const SizedBox(height: 32),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _currentPage == 2
                            ? _buildGetStartedButton()
                            : _buildNextButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixelSpaceship(double size) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(
        painter: _PixelSpaceshipPainter(),
      ),
    );
  }

  Widget _buildHowToPlayIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentOrange, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 56,
        color: AppColors.accentOrange,
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkNavyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder, width: 1.5),
      ),
      child: TextField(
        controller: _nameController,
        style: AppTextStyles.bodyLarge,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Pilot',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        key: const ValueKey('next'),
        onPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkNavyLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.panelBorder),
          ),
        ),
        child: Text('NEXT', style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        key: const ValueKey('getStarted'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppColors.accentOrange, Color(0xFFFF8F35)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentOrange.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _onGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'GET STARTED',
            style: AppTextStyles.button.copyWith(
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter for the twinkling star field.
class _StarfieldPainter extends CustomPainter {
  final List<_TwinkleStar> stars;
  final double time;

  _StarfieldPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (sin(star.phase + time * star.speed) + 1) / 2;
      final alpha = 0.2 + twinkle * 0.8;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => true;
}

class _TwinkleStar {
  final double x, y, radius, speed, phase;
  _TwinkleStar({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}

/// Draws a pixel-art spaceship for the onboarding illustration.
/// Matches the in-game saucer shape: fuselage, dome, pods, wings, nozzles.
class _PixelSpaceshipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // ── Wing stabilisers ─────────────────────────────────
    final finColor = const Color(0xFFFF6B35);
    final leftWing = Path()
      ..moveTo(cx - w * 0.24, cy + h * 0.06)
      ..lineTo(cx - w * 0.48, cy + h * 0.32)
      ..lineTo(cx - w * 0.36, cy + h * 0.36)
      ..lineTo(cx - w * 0.16, cy + h * 0.14)
      ..close();
    final rightWing = Path()
      ..moveTo(cx + w * 0.24, cy + h * 0.06)
      ..lineTo(cx + w * 0.48, cy + h * 0.32)
      ..lineTo(cx + w * 0.36, cy + h * 0.36)
      ..lineTo(cx + w * 0.16, cy + h * 0.14)
      ..close();
    canvas.drawPath(leftWing, Paint()..color = finColor);
    canvas.drawPath(leftWing, outlinePaint);
    canvas.drawPath(rightWing, Paint()..color = finColor);
    canvas.drawPath(rightWing, outlinePaint);

    // ── Main fuselage (saucer ellipse) ───────────────────
    final bodyColor = const Color(0xFFCFD8DC);
    final fuselageRect = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.04),
      width: w * 0.72,
      height: h * 0.34,
    );
    final bodyGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [bodyColor, bodyColor.withValues(alpha: 0.6)],
    );
    canvas.drawOval(
      fuselageRect,
      Paint()..shader = bodyGrad.createShader(fuselageRect),
    );
    canvas.drawOval(fuselageRect, outlinePaint);

    // ── Glare highlight on body ──────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - w * 0.06, cy - h * 0.02),
        width: w * 0.28,
        height: h * 0.08,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );

    // ── Engine pods ──────────────────────────────────────
    final podPaint = Paint()..color = finColor;
    for (final px in [cx - w * 0.22, cx + w * 0.22]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(px, cy + h * 0.16),
            width: w * 0.16,
            height: h * 0.1,
          ),
          const Radius.circular(4),
        ),
        podPaint,
      );
    }

    // ── 3 flame nozzles ──────────────────────────────────
    final flamePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (final fx in [cx - w * 0.22, cx, cx + w * 0.22]) {
      canvas.drawCircle(Offset(fx, cy + h * 0.28), w * 0.04, flamePaint);
    }
    // Inner white core
    final coreFlame = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    for (final fx in [cx - w * 0.22, cx, cx + w * 0.22]) {
      canvas.drawCircle(Offset(fx, cy + h * 0.27), w * 0.018, coreFlame);
    }

    // ── Domed cockpit (upper half) ───────────────────────
    final noseColor = const Color(0xFFE53935);
    final domeRect = Rect.fromCenter(
      center: Offset(cx, cy - h * 0.08),
      width: w * 0.32,
      height: h * 0.3,
    );
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(cx - w * 0.2, cy - h * 0.28, w * 0.4, h * 0.22),
    );
    canvas.drawOval(domeRect, Paint()..color = noseColor);
    canvas.drawOval(domeRect, outlinePaint);
    canvas.restore();

    // ── Cockpit window ──────────────────────────────────
    final windowPaint = Paint()..color = const Color(0xFF64B5F6);
    canvas.drawCircle(Offset(cx, cy - h * 0.11), w * 0.07, windowPaint);
    canvas.drawCircle(
      Offset(cx, cy - h * 0.11),
      w * 0.07,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // ── Glare arc on cockpit ─────────────────────────────
    final glarePath = Path()
      ..moveTo(cx - w * 0.035, cy - h * 0.18)
      ..quadraticBezierTo(
        cx + w * 0.015, cy - h * 0.22,
        cx + w * 0.05, cy - h * 0.14,
      );
    canvas.drawPath(
      glarePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // ── Fuselage stripe ─────────────────────────────────
    canvas.drawLine(
      Offset(cx - w * 0.28, cy + h * 0.02),
      Offset(cx + w * 0.28, cy + h * 0.02),
      Paint()
        ..color = noseColor.withValues(alpha: 0.5)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
