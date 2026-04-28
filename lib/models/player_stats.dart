/// Aggregated player statistics.
class PlayerStats {
  const PlayerStats({
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.netProfit = 0.0,
    this.bestMultiplier = 0.0,
    this.currentStreak = 0,
    this.level = 1,
    this.totalXP = 0,
  });

  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final double netProfit;
  final double bestMultiplier;
  final int currentStreak;
  final int level;
  final int totalXP;

  /// Get XP required for next level.
  static int getXPForNextLevel(int currentLevel) {
    return 100 * currentLevel; // Level 1 = 100 XP, Level 2 = 200 XP, etc.
  }

  /// Get total XP accumulated up to this level.
  static int getTotalXPForLevel(int level) {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += getXPForNextLevel(i);
    }
    return total;
  }

  /// Get progress to next level (0.0 to 1.0).
  double getLevelProgress() {
    final xpRequired = getXPForNextLevel(level);
    final xpInThisLevel = totalXP - getTotalXPForLevel(level);
    return (xpInThisLevel / xpRequired).clamp(0.0, 1.0);
  }

  /// Max bet amount unlocked at this level.
  double getMaxBetUnlock() {
    return 100.0 * level; // Level 1 = 100, Level 2 = 200, etc.
  }

  PlayerStats copyWith({
    int? totalGames,
    int? totalWins,
    int? totalLosses,
    double? netProfit,
    double? bestMultiplier,
    int? currentStreak,
    int? level,
    int? totalXP,
  }) {
    return PlayerStats(
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      netProfit: netProfit ?? this.netProfit,
      bestMultiplier: bestMultiplier ?? this.bestMultiplier,
      currentStreak: currentStreak ?? this.currentStreak,
      level: level ?? this.level,
      totalXP: totalXP ?? this.totalXP,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalGames': totalGames,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'netProfit': netProfit,
        'bestMultiplier': bestMultiplier,
        'currentStreak': currentStreak,
        'level': level,
        'totalXP': totalXP,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        totalGames: json['totalGames'] as int? ?? 0,
        totalWins: json['totalWins'] as int? ?? 0,
        totalLosses: json['totalLosses'] as int? ?? 0,
        netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
        bestMultiplier: (json['bestMultiplier'] as num?)?.toDouble() ?? 0.0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        totalXP: json['totalXP'] as int? ?? 0,
      );
}
