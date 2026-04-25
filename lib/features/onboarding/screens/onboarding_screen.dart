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
                          child: _buildPixelRocket(80),
                        ),
                        title: 'SKY ROCKET',
                        description: 'How high can you fly?',
                      ),

                      // Page 2: How to play
                      OnboardingPageWidget(
                        icon: _buildHowToPlayIcon(),
                        title: 'HOW TO PLAY',
                        description:
                            'Place your bet, watch the rocket fly,\ncash out before it crashes!',
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

  Widget _buildPixelRocket(double size) {
    return SizedBox(
      width: size,
      height: size * 1.8,
      child: CustomPaint(
        painter: _PixelRocketPainter(),
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
        Icons.rocket_launch_rounded,
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

/// Draws a pixel-art rocket for the onboarding illustration.
class _PixelRocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.2, w * 0.5, h * 0.55),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Nose
    final nosePaint = Paint()..color = const Color(0xFFE53935);
    final nosePath = Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..lineTo(w * 0.25, h * 0.2)
      ..lineTo(w * 0.75, h * 0.2)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Window
    final windowPaint = Paint()..color = const Color(0xFF64B5F6);
    canvas.drawCircle(Offset(w * 0.5, h * 0.36), w * 0.12, windowPaint);

    // Left Fin
    final finPaint = Paint()..color = const Color(0xFFFF6B35);
    final leftFin = Path()
      ..moveTo(w * 0.25, h * 0.6)
      ..lineTo(w * 0.05, h * 0.78)
      ..lineTo(w * 0.25, h * 0.75)
      ..close();
    canvas.drawPath(leftFin, finPaint);

    // Right Fin
    final rightFin = Path()
      ..moveTo(w * 0.75, h * 0.6)
      ..lineTo(w * 0.95, h * 0.78)
      ..lineTo(w * 0.75, h * 0.75)
      ..close();
    canvas.drawPath(rightFin, finPaint);

    // Flame
    final flamePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final flame = Path()
      ..moveTo(w * 0.3, h * 0.75)
      ..quadraticBezierTo(w * 0.5, h * 1.0, w * 0.7, h * 0.75);
    canvas.drawPath(flame, flamePaint);

    final innerFlame = Paint()
      ..color = const Color(0xFFFF6B35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final flame2 = Path()
      ..moveTo(w * 0.35, h * 0.75)
      ..quadraticBezierTo(w * 0.5, h * 0.92, w * 0.65, h * 0.75);
    canvas.drawPath(flame2, innerFlame);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
