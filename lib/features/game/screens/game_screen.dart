import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/rocket_skin.dart';
import '../../../providers/balance_provider.dart';
import '../../../providers/bet_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/achievement_provider.dart';
import '../components/sky_game.dart';
import '../widgets/auto_cash_out_control.dart';
import '../widgets/balance_display.dart';
import '../widgets/bet_controls.dart';
import '../widgets/cash_out_button.dart';
import '../widgets/live_player_ticker.dart';
import '../widgets/multiplier_display.dart';
import '../widgets/neon_game_frame.dart';
import '../widgets/round_history_bar.dart';
import '../widgets/coin_splash_overlay.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/bonus_event_notification.dart';
import '../widgets/rocket_trail.dart';
import '../widgets/particle_effect.dart';
import '../../menu/screens/menu_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late SkyGame _skyGame;
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _whooshPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  GamePhase _lastPhase = GamePhase.waiting;
  final GlobalKey<CoinSplashOverlayState> _coinSplashKey = GlobalKey();
  bool _showCashoutEffect = false;

  @override
  void initState() {
    super.initState();
    final skinId = ref.read(settingsProvider).selectedSkinId;
    final skin =
        RocketSkin.allSkins[skinId.clamp(0, RocketSkin.allSkins.length - 1)];
    _skyGame = SkyGame(rocketSkin: skin);

    // Wire up game phase callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).onPhaseChanged = _onGamePhaseChanged;
    });

    _startBgMusic();
  }

  void _onGamePhaseChanged(GamePhase phase, double multiplier) {
    // Always forward to Flame (it needs every tick for visual updates).
    _skyGame.onGamePhaseChanged(phase, multiplier);

    // Auto cash-out: runs every flying tick (before the phase-transition guard)
    if (phase == GamePhase.flying) {
      final betState = ref.read(betProvider);
      if (betState.hasBet &&
          betState.autoCashOutAt != null &&
          multiplier >= betState.autoCashOutAt!) {
        ref.read(betProvider.notifier).cashOut();
      }
    }

    // Only handle SFX + reset on actual phase transitions, not on every tick.
    if (phase == _lastPhase) return;
    _lastPhase = phase;

    // Reset bet state for the new round
    if (phase == GamePhase.waiting) {
      ref.read(betProvider.notifier).resetForNewRound();
    }

    final sfxVol = ref.read(settingsProvider).sfxVolume;
    switch (phase) {
      case GamePhase.flying:
        _startWhoosh(sfxVol);
        break;
      case GamePhase.crashed:
        _stopWhoosh();
        _playSfx(AppConstants.explosionPath, sfxVol);
        break;
      case GamePhase.cashedOut:
        _stopWhoosh();
        _playSfx(AppConstants.cashoutPath, sfxVol);
        _coinSplashKey.currentState?.trigger();
        
        // Show particle effect for a limited time
        setState(() => _showCashoutEffect = true);
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) setState(() => _showCashoutEffect = false);
        });
        break;
      default:
        _stopWhoosh();
        break;
    }
  }

  Future<void> _startBgMusic() async {
    try {
      final vol = ref.read(settingsProvider).musicVolume;
      await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgMusicPlayer.setVolume(vol);
      await _bgMusicPlayer.play(AssetSource(AppConstants.bgMusicPath));
    } catch (e) {
      debugPrint('BG Music Error: $e');
    }
  }

  Future<void> _startWhoosh(double volume) async {
    try {
      await _whooshPlayer.setReleaseMode(ReleaseMode.loop);
      await _whooshPlayer.setVolume(volume);
      await _whooshPlayer.play(AssetSource(AppConstants.whooshPath));
    } catch (e) {
      debugPrint('Whoosh Error: $e');
    }
  }

  Future<void> _stopWhoosh() async {
    try {
      await _whooshPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playSfx(String path, double volume) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('SFX Error: $e');
    }
  }

  @override
  void dispose() {
    _bgMusicPlayer.dispose();
    _whooshPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MenuScreen(),
    ).then((_) {
      // Update skin if changed
      final newSkinId = ref.read(settingsProvider).selectedSkinId;
      final newSkin = RocketSkin
          .allSkins[newSkinId.clamp(0, RocketSkin.allSkins.length - 1)];
      _skyGame.updateSkin(newSkin);

      // Update music volume
      final musicVol = ref.read(settingsProvider).musicVolume;
      _bgMusicPlayer.setVolume(musicVol);
    });
  }

  void _openDashboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DashboardScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final betState = ref.watch(betProvider);
    final balance = ref.watch(balanceProvider);
    final newlyUnlockedAchievements = ref.watch(newlyUnlockedAchievementsProvider);
    
    final skinId = ref.watch(settingsProvider).selectedSkinId;
    final selectedSkin = RocketSkin.allSkins[skinId.clamp(0, RocketSkin.allSkins.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Top Bar ──────────────────────────────────────
                RepaintBoundary(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        BalanceDisplay(balance: balance),
                        const Spacer(),
                        _TopBarButton(
                          icon: Icons.menu_rounded,
                          onTap: _openMenu,
                        ),
                        const SizedBox(width: 8),
                        _TopBarButton(
                          icon: Icons.grid_view_rounded,
                          onTap: _openDashboard,
                          backgroundColor: AppColors.accentOrange,
                          iconColor: AppColors.white,
                          borderColor: AppColors.accentOrange.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Round History ────────────────────────────────
                RepaintBoundary(
                  child: RoundHistoryBar(history: gameState.roundHistory),
                ),

            const SizedBox(height: 4),

            // ── Game Area with Neon Frame ────────────────────
            Expanded(
              child: NeonGameFrame(
                isFlying: gameState.phase == GamePhase.flying,
                isCrashed: gameState.phase == GamePhase.crashed,
                child: Stack(
                  children: [
                    // Rocket trail effect
                    if (gameState.phase == GamePhase.flying)
                      RocketTrail(
                        skin: selectedSkin,
                        isFlying: true,
                        rocketY: _skyGame.rocketY,
                      ),

                    // Flame game — isolated in its own repaint boundary
                    RepaintBoundary(
                      child: GameWidget(game: _skyGame),
                    ),

                    // Bonus event notification overlay
                    if (gameState.bonusEvent != null && gameState.phase == GamePhase.flying)
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: BonusEventNotification(event: gameState.bonusEvent!),
                        ),
                      ),
                      
                    // Particle effects on cashout
                    if (_showCashoutEffect)
                      ParticleEffect(
                        type: ParticleType.shimmer,
                        position: Offset(
                          MediaQuery.of(context).size.width / 2,
                          _skyGame.rocketY,
                        ),
                        duration: const Duration(milliseconds: 1500),
                        color: AppColors.accentOrange,
                      ),

                    // Multiplier overlay
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Phase label
                                if (gameState.phase == GamePhase.waiting)
                                  _CountdownLabel(
                                      seconds: gameState.countdownSeconds),

                                MultiplierDisplay(
                                  multiplier: gameState.currentMultiplier,
                                  isFlying:
                                      gameState.phase == GamePhase.flying,
                                  isCrashed:
                                      gameState.phase == GamePhase.crashed,
                                  isCashedOut:
                                      gameState.phase == GamePhase.cashedOut,
                                ),

                                // Crash point display when crashed
                                if (gameState.phase == GamePhase.crashed)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '@ ${gameState.crashPoint.toStringAsFixed(2)}x',
                                      style: AppTextStyles.pixelSmall.copyWith(
                                        color: AppColors.accentRed
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),

                                // Cashed out amount
                                if (gameState.phase == GamePhase.cashedOut)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: _CashedOutBadge(
                                      multiplier: gameState.currentMultiplier,
                                      betAmount: betState.betAmount,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Exclamation messages
                    if (gameState.exclamationMessage != null)
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: RepaintBoundary(
                          child: _ExclamationBanner(
                              message: gameState.exclamationMessage!),
                        ),
                      ),

                    // Coin splash overlay — triggered on cash out
                    Positioned.fill(
                      child: CoinSplashOverlay(key: _coinSplashKey),
                    ),

                    // Round number badge (top-left corner of game area)
                    Positioned(
                      top: 8,
                      left: 10,
                      child: _RoundBadge(
                        roundNumber: gameState.roundHistory.length + 1,
                        isLive: gameState.phase == GamePhase.flying,
                      ),
                    ),

                    // Live player count — bottom-right corner of game canvas
                    const Positioned(
                      bottom: 10,
                      right: 10,
                      child: LivePlayerTicker(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Bottom Controls with glassmorphism ────────────
            RepaintBoundary(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.panelBorder.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.6),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BetControls(
                          betAmount: betState.betAmount,
                          enabled: gameState.phase == GamePhase.waiting &&
                              !betState.hasBet,
                          onQuickBet: (amount) =>
                              ref.read(betProvider.notifier).setBetAmount(amount),
                          onIncrement: () =>
                              ref.read(betProvider.notifier).incrementBet(),
                          onDecrement: () =>
                              ref.read(betProvider.notifier).decrementBet(),
                        ),
                        const SizedBox(height: 8),
                        AutoCashOutControl(
                          autoCashOutAt: betState.autoCashOutAt,
                          enabled: gameState.phase == GamePhase.waiting,
                          onChanged: (target) => ref
                              .read(betProvider.notifier)
                              .setAutoCashOut(target),
                        ),
                        const SizedBox(height: 10),
                        CashOutButton(
                          phase: gameState.phase,
                          hasBet: betState.hasBet,
                          multiplier: gameState.currentMultiplier,
                          betAmount: betState.betAmount,
                          onPlaceBet: () =>
                              ref.read(betProvider.notifier).placeBet(),
                          onCashOut: () =>
                              ref.read(betProvider.notifier).cashOut(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),

            // Achievement notifications overlay
            if (newlyUnlockedAchievements.isNotEmpty)
              Positioned(
                top: 100,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: newlyUnlockedAchievements.asMap().entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(top: entry.key * 80.0),
                      child: AchievementBadgeNotification(
                        key: ValueKey(entry.value.type),
                        achievement: entry.value,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Private widgets
// ────────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = AppColors.darkNavyLight,
    this.iconColor = AppColors.textSecondary,
    this.borderColor = AppColors.panelBorder,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

/// Round number badge with a blinking "LIVE" dot during flight.
class _RoundBadge extends StatefulWidget {
  const _RoundBadge({required this.roundNumber, required this.isLive});

  final int roundNumber;
  final bool isLive;

  @override
  State<_RoundBadge> createState() => _RoundBadgeState();
}

class _RoundBadgeState extends State<_RoundBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blink,
      builder: (_, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.darkNavy.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.panelBorder.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isLive) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentRed
                      .withValues(alpha: 0.5 + _blink.value * 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentRed
                          .withValues(alpha: _blink.value * 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              'ROUND #${widget.roundNumber}',
              style: AppTextStyles.label.copyWith(
                fontSize: 7,
                letterSpacing: 1.5,
                color: widget.isLive
                    ? AppColors.textPrimary.withValues(alpha: 0.8)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated countdown label with circular progress ring.
class _CountdownLabel extends StatefulWidget {
  const _CountdownLabel({required this.seconds});

  final int seconds;

  @override
  State<_CountdownLabel> createState() => _CountdownLabelState();
}

class _CountdownLabelState extends State<_CountdownLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = AppConstants.bettingWindowSeconds;
    final progress = widget.seconds / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress ring around countdown number
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, _) => SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor:
                          AppColors.panelBorder.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.seconds <= 2
                            ? AppColors.accentRed
                            : AppColors.accentOrange,
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: child,
                  ),
                  child: Text(
                    '${widget.seconds}',
                    key: ValueKey<int>(widget.seconds),
                    style: AppTextStyles.pixelMedium.copyWith(
                      color: widget.seconds <= 2
                          ? AppColors.accentRed
                          : AppColors.accentOrange,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'PLACE YOUR BETS',
              style: AppTextStyles.label.copyWith(
                color: AppColors.accentOrange,
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cashed-out result badge with win amount and multiplier.
class _CashedOutBadge extends StatefulWidget {
  const _CashedOutBadge({
    required this.multiplier,
    required this.betAmount,
  });

  final double multiplier;
  final double betAmount;

  @override
  State<_CashedOutBadge> createState() => _CashedOutBadgeState();
}

class _CashedOutBadgeState extends State<_CashedOutBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winnings = widget.betAmount * widget.multiplier;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentGreen.withValues(alpha: 0.25),
              AppColors.accentGreen.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentGreen.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💰', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CASHED OUT!',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accentGreen,
                    fontSize: 8,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '\$${winnings.toStringAsFixed(2)}',
                  style: AppTextStyles.pixelSmall.copyWith(
                    color: AppColors.accentGreen,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pop-in exclamation message during flight.
class _ExclamationBanner extends StatefulWidget {
  const _ExclamationBanner({required this.message});

  final String message;

  @override
  State<_ExclamationBanner> createState() => _ExclamationBannerState();
}

class _ExclamationBannerState extends State<_ExclamationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Text(
            widget.message,
            style: AppTextStyles.pixelMedium.copyWith(
              color: AppColors.gold,
              shadows: [
                Shadow(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
