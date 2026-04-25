import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// A single onboarding page with icon/animation, title, and description.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.child,
  });

  final Widget icon;
  final String title;
  final String description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          icon,
          const SizedBox(height: 40),
          Text(
            title,
            style: AppTextStyles.pixelMedium.copyWith(
              color: AppColors.gold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (child != null) ...[
            const SizedBox(height: 32),
            child!,
          ],
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
