import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import 'balance_provider.dart';
import 'game_provider.dart';
import 'player_stats_provider.dart';
import 'achievement_provider.dart';

/// Bet state for the current round.
class BetState {
  const BetState({
    this.betAmount = AppConstants.defaultBetAmount,
    this.hasBet = false,
    this.autoCashOutAt,
  });

  final double betAmount;
  final bool hasBet;

  /// If non-null, automatically cash out when multiplier reaches this value.
  final double? autoCashOutAt;

  BetState copyWith({
    double? betAmount,
    bool? hasBet,
    double? autoCashOutAt,
    bool clearAutoCashOut = false,
  }) {
    return BetState(
      betAmount: betAmount ?? this.betAmount,
      hasBet: hasBet ?? this.hasBet,
      autoCashOutAt: clearAutoCashOut
          ? null
          : (autoCashOutAt ?? this.autoCashOutAt),
    );
  }
}

/// Manages betting logic: bet amount, placing bets, and cashing out.
///
/// IMPORTANT: This notifier does NOT listen to gameProvider internally to
/// avoid a Riverpod circular dependency (gameProvider ↔ betProvider).
/// Round resets and auto cash-out are driven from the UI layer
/// (GameScreen._onGamePhaseChanged) which calls resetForNewRound() and cashOut().
class BetNotifier extends StateNotifier<BetState> {
  BetNotifier(this._ref) : super(const BetState());

  final Ref _ref;

  /// Called by the game screen at the start of each new betting window.
  void resetForNewRound() {
    state = state.copyWith(hasBet: false);
  }

  /// Set bet amount directly (quick bet).
  void setBetAmount(double amount) {
    if (state.hasBet) return;
    final balance = _ref.read(balanceProvider);
    final clamped = amount.clamp(AppConstants.minBet, balance);
    state = state.copyWith(betAmount: clamped);
  }

  /// Increment bet by $10.
  void incrementBet() {
    if (state.hasBet) return;
    final balance = _ref.read(balanceProvider);
    final newAmount = (state.betAmount + AppConstants.betIncrement).clamp(
        AppConstants.minBet,
        balance.clamp(AppConstants.minBet, AppConstants.maxBet));
    state = state.copyWith(betAmount: newAmount);
  }

  /// Decrement bet by $10.
  void decrementBet() {
    if (state.hasBet) return;
    final newAmount = (state.betAmount - AppConstants.betIncrement)
        .clamp(AppConstants.minBet, AppConstants.maxBet);
    state = state.copyWith(betAmount: newAmount);
  }

  /// Place the bet — deduct from balance.
  bool placeBet() {
    if (state.hasBet) return false;
    final gamePhase = _ref.read(gameProvider).phase;
    if (gamePhase != GamePhase.waiting) return false;

    final balance = _ref.read(balanceProvider);
    if (balance < state.betAmount) return false;

    final success =
        _ref.read(balanceProvider.notifier).deductBet(state.betAmount);
    if (success) {
      state = state.copyWith(hasBet: true);
    }
    return success;
  }

  /// Cash out at the current multiplier.
  void cashOut() {
    if (!state.hasBet) return;
    final gameState = _ref.read(gameProvider);
    if (gameState.phase != GamePhase.flying) return;

    final winnings = state.betAmount * gameState.currentMultiplier;
    _ref.read(balanceProvider.notifier).addWinnings(winnings);

    final playerStats = _ref.read(playerStatsProvider);
    _ref.read(playerStatsProvider.notifier).onRoundComplete(
          crashPoint: gameState.crashPoint,
          cashedOutAt: gameState.currentMultiplier,
          betAmount: state.betAmount,
        );

    // Check for achievements
    _ref.read(achievementProvider.notifier).checkAchievements(
      cashedOutAt: gameState.currentMultiplier,
      crashPoint: gameState.crashPoint,
      totalGames: playerStats.totalGames + 1,
      currentStreak: playerStats.currentStreak + 1,
      usedAutoCashout: state.autoCashOutAt != null && state.autoCashOutAt! <= gameState.currentMultiplier,
    );

    _ref.read(gameProvider.notifier).playerCashedOut(gameState.currentMultiplier);
  }

  /// Set (or clear) the auto cash-out target multiplier.
  void setAutoCashOut(double? target) {
    state = state.copyWith(
      autoCashOutAt: target,
      clearAutoCashOut: target == null,
    );
  }
}

final betProvider = StateNotifierProvider<BetNotifier, BetState>((ref) {
  return BetNotifier(ref);
});
