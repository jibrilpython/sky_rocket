import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/player_stats.dart';
import '../models/achievement.dart';

/// Wrapper around SharedPreferences for all persistence operations.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  // ── Balance ──────────────────────────────────────────────────
  Future<void> saveBalance(double balance) async {
    await _prefs.setDouble(AppConstants.keyBalance, balance);
  }

  double getBalance() {
    return _prefs.getDouble(AppConstants.keyBalance) ?? AppConstants.defaultBalance;
  }

  // ── Player Name ──────────────────────────────────────────────
  Future<void> savePlayerName(String name) async {
    await _prefs.setString(AppConstants.keyPlayerName, name);
  }

  String getPlayerName() {
    return _prefs.getString(AppConstants.keyPlayerName) ?? 'Pilot';
  }

  // ── Selected Skin ────────────────────────────────────────────
  Future<void> saveSelectedSkin(int skinId) async {
    await _prefs.setInt(AppConstants.keySelectedSkin, skinId);
  }

  int getSelectedSkin() {
    return _prefs.getInt(AppConstants.keySelectedSkin) ?? 0;
  }

  // ── Onboarding ───────────────────────────────────────────────
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(AppConstants.keyOnboardingComplete, true);
  }

  bool hasCompletedOnboarding() {
    return _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  // ── Round History ────────────────────────────────────────────
  Future<void> saveRoundHistory(List<double> history) async {
    final encoded = history.map((e) => e.toString()).toList();
    await _prefs.setStringList(AppConstants.keyRoundHistory, encoded);
  }

  List<double> getRoundHistory() {
    final list = _prefs.getStringList(AppConstants.keyRoundHistory);
    if (list == null) return [];
    return list.map((e) => double.tryParse(e) ?? 1.0).toList();
  }

  // ── Player Stats ─────────────────────────────────────────────
  Future<void> saveStats(PlayerStats stats) async {
    final encoded = jsonEncode(stats.toJson());
    await _prefs.setString(AppConstants.keyStats, encoded);
  }

  PlayerStats getStats() {
    final encoded = _prefs.getString(AppConstants.keyStats);
    if (encoded == null) return const PlayerStats();
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      return PlayerStats.fromJson(json);
    } catch (_) {
      return const PlayerStats();
    }
  }

  // ── Volume Settings ──────────────────────────────────────────
  Future<void> saveMusicVolume(double volume) async {
    await _prefs.setDouble(AppConstants.keyMusicVolume, volume);
  }

  double getMusicVolume() {
    return _prefs.getDouble(AppConstants.keyMusicVolume) ?? 0.5;
  }

  Future<void> saveSfxVolume(double volume) async {
    await _prefs.setDouble(AppConstants.keySfxVolume, volume);
  }

  double getSfxVolume() {
    return _prefs.getDouble(AppConstants.keySfxVolume) ?? 0.5;
  }

  // ── Achievements ────────────────────────────────────────────
  Future<void> saveAchievements(List<Achievement> achievements) async {
    final encoded = jsonEncode(achievements.map((a) => a.toJson()).toList());
    await _prefs.setString('achievements', encoded);
  }

  List<Achievement> getAchievements() {
    final encoded = _prefs.getString('achievements');
    if (encoded == null) return [];
    try {
      final json = jsonDecode(encoded) as List;
      return json
          .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
