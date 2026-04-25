import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import 'game_provider.dart';

/// Manages the player's virtual currency balance.
class BalanceNotifier extends StateNotifier<double> {
  BalanceNotifier(this._ref) : super(0) {
    // Load persisted balance
    final storage = _ref.read(storageServiceProvider);
    state = storage.getBalance();
  }

  final Ref _ref;

  /// Add winnings to the balance.
  void addWinnings(double amount) {
    state += amount;
    _persist();
  }

  /// Deduct a bet from the balance.
  bool deductBet(double amount) {
    if (state < amount) return false;
    state -= amount;
    _persist();
    return true;
  }

  /// Reset balance to default.
  void resetBalance() {
    state = AppConstants.defaultBalance;
    _persist();
  }

  void _persist() {
    _ref.read(storageServiceProvider).saveBalance(state);
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, double>((ref) {
  return BalanceNotifier(ref);
});
