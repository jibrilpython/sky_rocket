import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/bonus_event.dart';
import '../services/crash_algorithm_service.dart';
import '../services/storage_service.dart';
import 'player_stats_provider.dart';

/// The current phase of the game.
enum GamePhase {
  waiting,
  flying,
  crashed,
  cashedOut,
}

/// Immutable game state.
class GameState {
  const GameState({
    this.phase = GamePhase.waiting,
    this.currentMultiplier = 1.00,
    this.crashPoint = 0.0,
    this.roundHistory = const [],
    this.countdownSeconds = 5,
    this.exclamationMessage,
    this.bonusEvent,
  });

  final GamePhase phase;
  final double currentMultiplier;
  final double crashPoint;
  final List<double> roundHistory;
  final int countdownSeconds;
  final String? exclamationMessage;
  final BonusEvent? bonusEvent;

  GameState copyWith({
    GamePhase? phase,
    double? currentMultiplier,
    double? crashPoint,
    List<double>? roundHistory,
    int? countdownSeconds,
    String? exclamationMessage,
    BonusEvent? bonusEvent,
    bool clearExclamation = false,
    bool clearBonus = false,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      currentMultiplier: currentMultiplier ?? this.currentMultiplier,
      crashPoint: crashPoint ?? this.crashPoint,
      roundHistory: roundHistory ?? this.roundHistory,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      exclamationMessage:
          clearExclamation ? null : (exclamationMessage ?? this.exclamationMessage),
      bonusEvent: clearBonus ? null : (bonusEvent ?? this.bonusEvent),
    );
  }
}

/// Manages the core game loop: betting window → flight → crash → repeat.
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this._ref, this._storageService)
      : _crashAlgo = CrashAlgorithmService(),
        super(const GameState()) {
    // Load round history from storage
    final savedHistory = _storageService.getRoundHistory();
    state = state.copyWith(roundHistory: savedHistory);
    // Start the first betting window
    _startBettingWindow();
  }

  final Ref _ref;
  final StorageService _storageService;
  final CrashAlgorithmService _crashAlgo;

  Timer? _gameTimer;
  Timer? _countdownTimer;
  Timer? _exclamationTimer;
  double _elapsedSeconds = 0;
  final Random _random = Random();

  /// Callback for Flame engine to react to phase changes.
  void Function(GamePhase phase, double multiplier)? onPhaseChanged;

  /// Start the betting countdown window.
  void _startBettingWindow() {
    _cancelAllTimers();
    state = state.copyWith(
      phase: GamePhase.waiting,
      currentMultiplier: 1.00,
      countdownSeconds: AppConstants.bettingWindowSeconds,
      clearExclamation: true,
    );
    onPhaseChanged?.call(GamePhase.waiting, 1.00);

    var countdown = AppConstants.bettingWindowSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if (countdown <= 0) {
        timer.cancel();
        _startFlying();
      } else {
        state = state.copyWith(countdownSeconds: countdown);
      }
    });
  }

  /// Begin the flight phase — multiplier starts rising.
  void _startFlying() {
    final newCrashPoint = _crashAlgo.generateCrashPoint();
    final bonusEvent = BonusEvent.getRandomBonusEvent();
    
    _elapsedSeconds = 0;

    state = state.copyWith(
      phase: GamePhase.flying,
      currentMultiplier: 1.00,
      crashPoint: newCrashPoint,
      bonusEvent: bonusEvent,
      clearExclamation: true,
    );
    onPhaseChanged?.call(GamePhase.flying, 1.00);

    // Start the multiplier ticker
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.tickIntervalMs),
      (_) => _tick(),
    );

    // Start random exclamation messages
    _scheduleExclamation();
  }

  /// Called every 100ms during flight.
  void _tick() {
    _elapsedSeconds += AppConstants.tickIntervalMs / 1000.0;
    var newMultiplier = _crashAlgo.calculateMultiplier(_elapsedSeconds);

    // Apply bonus event multiplier if active
    if (state.bonusEvent != null) {
      if (_elapsedSeconds >= state.bonusEvent!.triggerTime &&
          _elapsedSeconds <= state.bonusEvent!.triggerTime + (state.bonusEvent!.durationMs / 1000.0)) {
        newMultiplier *= state.bonusEvent!.multiplierModifier;
      }
    }

    if (newMultiplier >= state.crashPoint) {
      _crash();
    } else {
      state = state.copyWith(currentMultiplier: newMultiplier);
      onPhaseChanged?.call(GamePhase.flying, newMultiplier);
    }
  }

  /// Rocket has reached the crash point.
  void _crash() {
    _cancelAllTimers();

    final updatedHistory = [
      state.crashPoint,
      ...state.roundHistory.take(AppConstants.roundHistoryLength - 1),
    ];

    state = state.copyWith(
      phase: GamePhase.crashed,
      currentMultiplier: state.crashPoint,
      roundHistory: updatedHistory,
    );
    onPhaseChanged?.call(GamePhase.crashed, state.crashPoint);

    // Persist history
    _storageService.saveRoundHistory(updatedHistory);

    // Update stats for players who didn't cash out (loss handled in bet_provider)
    _ref.read(playerStatsProvider.notifier).onRoundComplete(
          crashPoint: state.crashPoint,
          cashedOutAt: null,
          betAmount: 0,
        );

    // Wait 3 seconds then start next round
    Future.delayed(
      const Duration(seconds: AppConstants.crashDisplaySeconds),
      () {
        if (mounted) _startBettingWindow();
      },
    );
  }

  /// Player chose to cash out.
  void playerCashedOut(double cashedOutMultiplier) {
    if (state.phase != GamePhase.flying) return;
    state = state.copyWith(
      phase: GamePhase.cashedOut,
      currentMultiplier: cashedOutMultiplier,
    );
    onPhaseChanged?.call(GamePhase.cashedOut, cashedOutMultiplier);
  }

  /// Schedule random exclamation messages during flight.
  void _scheduleExclamation() {
    final delay = Duration(seconds: 2 + _random.nextInt(4));
    _exclamationTimer = Timer(delay, () {
      if (state.phase == GamePhase.flying) {
        final msg = AppConstants
            .exclamations[_random.nextInt(AppConstants.exclamations.length)];
        state = state.copyWith(exclamationMessage: msg);

        // Clear after 1.2 seconds
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            state = state.copyWith(clearExclamation: true);
          }
        });

        // Schedule next
        _scheduleExclamation();
      }
    });
  }

  void _cancelAllTimers() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _exclamationTimer?.cancel();
    _gameTimer = null;
    _countdownTimer = null;
    _exclamationTimer = null;
  }

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }
}

/// Provider for the game state.
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return GameNotifier(ref, storageService);
});

/// Provider for the storage service (initialized in main.dart).
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden at app startup');
});
