import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import 'balance_provider.dart';
import 'game_provider.dart';
import 'player_stats_provider.dart';

/// Bet state for the current round.
class BetState {
  const BetState({
    this.betAmount = AppConstants.defaultBetAmount,
    this.hasBet = false,
  });

  final double betAmount;
  final bool hasBet;

  BetState copyWith({double? betAmount, bool? hasBet}) {
    return BetState(
      betAmount: betAmount ?? this.betAmount,
      hasBet: hasBet ?? this.hasBet,
    );
  }
}

/// Manages betting logic: bet amount, placing bets, and cashing out.
class BetNotifier extends StateNotifier<BetState> {
  BetNotifier(this._ref) : super(const BetState()) {
    // Listen to game phase changes to reset bet state
    _ref.listen<GameState>(gameProvider, (prev, next) {
      if (next.phase == GamePhase.waiting && prev?.phase != GamePhase.waiting) {
        // New round — reset hasBet
        state = state.copyWith(hasBet: false);
      }
    });
  }

  final Ref _ref;

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
    final newAmount = (state.betAmount + AppConstants.betIncrement)
        .clamp(AppConstants.minBet, balance.clamp(AppConstants.minBet, AppConstants.maxBet));
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

    final success = _ref.read(balanceProvider.notifier).deductBet(state.betAmount);
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

    // Update stats
    _ref.read(playerStatsProvider.notifier).onRoundComplete(
          crashPoint: gameState.crashPoint,
          cashedOutAt: gameState.currentMultiplier,
          betAmount: state.betAmount,
        );

    // Notify the game that we cashed out
    _ref.read(gameProvider.notifier).playerCashedOut(gameState.currentMultiplier);
  }
}

final betProvider = StateNotifierProvider<BetNotifier, BetState>((ref) {
  return BetNotifier(ref);
});
