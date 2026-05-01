import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_provider.dart';

/// Manages onboarding completion state.
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._ref) : super(false) {
    state = !_ref.read(storageServiceProvider).hasCompletedOnboarding();
  }

  final Ref _ref;

  /// Mark onboarding as complete.
  Future<void> completeOnboarding(String playerName) async {
    final storage = _ref.read(storageServiceProvider);
    await storage.setOnboardingComplete();
    if (playerName.trim().isNotEmpty) {
      await storage.savePlayerName(playerName.trim());
    }
    state = true;
  }
}

/// `true` if onboarding has been completed.
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  return OnboardingNotifier(ref);
});
