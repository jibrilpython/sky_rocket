import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../providers/onboarding_provider.dart';

/// App router configuration using GoRouter.
/// / redirects to /onboarding or /game based on onboarding state.
/// Dashboard and Menu are overlays triggered from GameScreen.
final appRouterProvider = Provider<GoRouter>((ref) {
  final hasOnboarded = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return hasOnboarded ? '/game' : '/onboarding';
      }
      // If onboarding is done and user tries to visit /onboarding
      if (hasOnboarded && state.uri.path == '/onboarding') {
        return '/game';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
    ],
  );
});
