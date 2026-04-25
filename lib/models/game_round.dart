/// Represents a single completed game round.
class GameRound {
  const GameRound({
    required this.crashPoint,
    this.cashedOutAt,
    required this.betAmount,
    required this.winnings,
    required this.timestamp,
  });

  final double crashPoint;
  final double? cashedOutAt;
  final double betAmount;
  final double winnings;
  final DateTime timestamp;

  bool get didCashOut => cashedOutAt != null;
  bool get isWin => winnings > 0;

  Map<String, dynamic> toJson() => {
        'crashPoint': crashPoint,
        'cashedOutAt': cashedOutAt,
        'betAmount': betAmount,
        'winnings': winnings,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GameRound.fromJson(Map<String, dynamic> json) => GameRound(
        crashPoint: (json['crashPoint'] as num).toDouble(),
        cashedOutAt: json['cashedOutAt'] != null
            ? (json['cashedOutAt'] as num).toDouble()
            : null,
        betAmount: (json['betAmount'] as num).toDouble(),
        winnings: (json['winnings'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
