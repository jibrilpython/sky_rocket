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
import '../components/sky_game.dart';
import '../widgets/balance_display.dart';
import '../widgets/bet_controls.dart';
import '../widgets/cash_out_button.dart';
import '../widgets/multiplier_display.dart';
import '../widgets/round_history_bar.dart';
import '../widgets/coin_splash_overlay.dart';
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

    // Only handle SFX on actual phase transitions, not on every tick.
    if (phase == _lastPhase) return;
    _lastPhase = phase;

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

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────
            // Wrapped in RepaintBoundary so it doesn't repaint
            // when the game area repaints.
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

            // ── Game Area ────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Flame game — isolated in its own repaint boundary
                  // so its Canvas doesn't interfere with Flutter text
                  RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GameWidget(game: _skyGame),
                    ),
                  ),

                  // Multiplier overlay — also in its own repaint boundary
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: Center(
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
                                child: Text(
                                  'CASHED OUT! 💰',
                                  style: AppTextStyles.pixelSmall.copyWith(
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                              ),
                          ],
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
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Bottom Controls ──────────────────────────────
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, -4),
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
          ],
        ),
      ),
    );
  }
}

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


class _CountdownLabel extends StatelessWidget {
  const _CountdownLabel({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accentOrange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          'STARTING IN ${seconds}s',
          style: AppTextStyles.pixelSmall.copyWith(
            color: AppColors.accentOrange,
          ),
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
    );
  }
}
