/// All magic numbers and game configuration constants.
abstract final class AppConstants {
  // ── Balance ────────────────────────────────────────────────
  static const double defaultBalance = 1000.00;

  // ── Betting ────────────────────────────────────────────────
  static const double defaultBetAmount = 10.00;
  static const double betIncrement = 10.00;
  static const double minBet = 10.00;
  static const double maxBet = 500.00;
  static const List<double> quickBets = [10.0, 50.0, 100.0];

  // ── Game Timing ────────────────────────────────────────────
  static const int tickIntervalMs = 100;
  static const int bettingWindowSeconds = 5;
  static const int crashDisplaySeconds = 3;

  // ── Multiplier Growth ──────────────────────────────────────
  static const double baseGrowthRate = 0.08;
  static const double growthAcceleration = 0.002;
  static const int multiplierPrecision = 2;

  // ── History ────────────────────────────────────────────────
  static const int roundHistoryLength = 10;
  static const int chartHistoryLength = 20;

  // ── Chip Thresholds ────────────────────────────────────────
  static const double chipYellowThreshold = 2.0;
  static const double chipGreenThreshold = 5.0;

  // ── Rocket Skins ───────────────────────────────────────────
  static const int totalSkins = 6;

  // ── Audio Paths ────────────────────────────────────────────
  static const String bgMusicPath = 'audio/bg_music.mp3';
  static const String whooshPath = 'audio/whoosh.mp3';
  static const String explosionPath = 'audio/explosion.mp3';
  static const String cashoutPath = 'audio/cashout.mp3';

  // ── Exclamation Messages ───────────────────────────────────
  static const List<String> exclamations = [
    'TURBO!',
    'UNSTOPPABLE!',
    'WOOOO!',
    'TO THE MOON!',
    'LEGENDARY!',
    'INSANE!',
    'GODLIKE!',
    'MEGA!',
  ];

  // ── SharedPreferences Keys ─────────────────────────────────
  static const String keyBalance = 'balance';
  static const String keyPlayerName = 'playerName';
  static const String keySelectedSkin = 'selectedSkin';
  static const String keyOnboardingComplete = 'hasSeenOnboarding';
  static const String keyRoundHistory = 'roundHistory';
  static const String keyStats = 'playerStats';
  static const String keyMusicVolume = 'musicVolume';
  static const String keySfxVolume = 'sfxVolume';
}
