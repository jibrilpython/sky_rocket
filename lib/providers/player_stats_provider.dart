import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart';
import 'game_provider.dart';

/// Manages aggregated player statistics.
class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  PlayerStatsNotifier(this._ref) : super(const PlayerStats()) {
    _loadFromStorage();
  }

  final Ref _ref;

  void _loadFromStorage() {
    final storage = _ref.read(storageServiceProvider);
    state = storage.getStats();
  }

  /// Called when a round completes.
  /// [cashedOutAt] is null if the player didn't cash out (or didn't bet).
  void onRoundComplete({
    required double crashPoint,
    required double? cashedOutAt,
    required double betAmount,
  }) {
    if (betAmount <= 0) return; // Player didn't bet

    final isWin = cashedOutAt != null;
    final profit = isWin ? (betAmount * cashedOutAt) - betAmount : -betAmount;

    state = state.copyWith(
      totalGames: state.totalGames + 1,
      totalWins: state.totalWins + (isWin ? 1 : 0),
      totalLosses: state.totalLosses + (isWin ? 0 : 1),
      netProfit: state.netProfit + profit,
      bestMultiplier: isWin
          ? max(state.bestMultiplier, cashedOutAt)
          : state.bestMultiplier,
      currentStreak: isWin ? state.currentStreak + 1 : 0,
    );

    _ref.read(storageServiceProvider).saveStats(state);
  }

  /// Reset all stats.
  void resetStats() {
    state = const PlayerStats();
    _ref.read(storageServiceProvider).saveStats(state);
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStats>((ref) {
  return PlayerStatsNotifier(ref);
});
