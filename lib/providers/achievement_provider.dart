import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';
import 'game_provider.dart';

/// Manages player achievements and XP.
class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier(Ref ref, this._storageService)
      : super(Achievement.getAllAchievements()) {
    _loadFromStorage();
  }

  final StorageService _storageService;
  int _autoCashoutCount = 0;

  void _loadFromStorage() {
    final saved = _storageService.getAchievements();
    if (saved.isNotEmpty) {
      state = saved;
    }
  }

  /// Check for newly unlocked achievements.
  void checkAchievements({
    required double? cashedOutAt,
    required double crashPoint,
    required int totalGames,
    required int currentStreak,
    required bool usedAutoCashout,
  }) {
    final newState = state.map((achievement) {
      if (achievement.unlocked) return achievement;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.cashOut50x:
          shouldUnlock = cashedOutAt != null && cashedOutAt >= 50.0;
          break;
        case AchievementType.cashOut100x:
          shouldUnlock = cashedOutAt != null && cashedOutAt >= 100.0;
          break;
        case AchievementType.cashOut500x:
          shouldUnlock = cashedOutAt != null && cashedOutAt >= 500.0;
          break;
        case AchievementType.win5InARow:
          shouldUnlock = currentStreak >= 5;
          break;
        case AchievementType.win10InARow:
          shouldUnlock = currentStreak >= 10;
          break;
        case AchievementType.useAutoCashout10:
          if (usedAutoCashout) _autoCashoutCount++;
          shouldUnlock = _autoCashoutCount >= 10;
          break;
        case AchievementType.useAutoCashout50:
          if (usedAutoCashout) _autoCashoutCount++;
          shouldUnlock = _autoCashoutCount >= 50;
          break;
        case AchievementType.totalGamesReached100:
          shouldUnlock = totalGames >= 100;
          break;
        case AchievementType.totalGamesReached500:
          shouldUnlock = totalGames >= 500;
          break;
      }

      if (shouldUnlock) {
        return achievement.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
      return achievement;
    }).toList();

    state = newState;
    _storageService.saveAchievements(newState);
  }

  /// Get list of newly unlocked achievements.
  List<Achievement> getNewlyUnlocked() {
    return state.where((a) => a.unlocked && a.unlockedAt != null).toList();
  }

  /// Get total XP from all unlocked achievements.
  int getTotalXP() {
    return state
        .where((a) => a.unlocked)
        .fold<int>(0, (sum, a) => sum + a.xpReward);
  }

  /// Reset achievements (for testing).
  void resetAchievements() {
    state = Achievement.getAllAchievements();
    _autoCashoutCount = 0;
    _storageService.saveAchievements(state);
  }
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  return AchievementNotifier(ref, ref.watch(storageServiceProvider));
});

/// Provider to get total achievement XP.
final totalAchievementXpProvider = Provider<int>((ref) {
  final achievements = ref.watch(achievementProvider);
  return achievements
      .where((a) => a.unlocked)
      .fold<int>(0, (sum, a) => sum + a.xpReward);
});

/// Provider to get newly unlocked achievements.
final newlyUnlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final achievements = ref.watch(achievementProvider);
  return achievements
      .where((a) => a.unlocked && a.unlockedAt != null)
      .toList();
});
