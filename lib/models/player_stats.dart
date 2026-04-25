/// Aggregated player statistics.
class PlayerStats {
  const PlayerStats({
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.netProfit = 0.0,
    this.bestMultiplier = 0.0,
    this.currentStreak = 0,
  });

  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final double netProfit;
  final double bestMultiplier;
  final int currentStreak;

  PlayerStats copyWith({
    int? totalGames,
    int? totalWins,
    int? totalLosses,
    double? netProfit,
    double? bestMultiplier,
    int? currentStreak,
  }) {
    return PlayerStats(
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      netProfit: netProfit ?? this.netProfit,
      bestMultiplier: bestMultiplier ?? this.bestMultiplier,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalGames': totalGames,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'netProfit': netProfit,
        'bestMultiplier': bestMultiplier,
        'currentStreak': currentStreak,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        totalGames: json['totalGames'] as int? ?? 0,
        totalWins: json['totalWins'] as int? ?? 0,
        totalLosses: json['totalLosses'] as int? ?? 0,
        netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
        bestMultiplier: (json['bestMultiplier'] as num?)?.toDouble() ?? 0.0,
        currentStreak: json['currentStreak'] as int? ?? 0,
      );
}
