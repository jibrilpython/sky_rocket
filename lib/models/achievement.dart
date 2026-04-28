/// Achievement types and definitions.
enum AchievementType {
  cashOut50x,
  cashOut100x,
  cashOut500x,
  win5InARow,
  win10InARow,
  useAutoCashout10,
  useAutoCashout50,
  totalGamesReached100,
  totalGamesReached500,
}

/// Represents an achievement.
class Achievement {
  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.unlocked,
    this.unlockedAt,
    this.iconEmoji = '🏆',
  });

  final AchievementType type;
  final String title;
  final String description;
  final int xpReward;
  final bool unlocked;
  final DateTime? unlockedAt;
  final String iconEmoji;

  Achievement copyWith({
    AchievementType? type,
    String? title,
    String? description,
    int? xpReward,
    bool? unlocked,
    DateTime? unlockedAt,
    String? iconEmoji,
  }) {
    return Achievement(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'iconEmoji': iconEmoji,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        type: AchievementType.values
            .firstWhere((e) => e.toString() == json['type']),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        xpReward: json['xpReward'] as int? ?? 0,
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
        iconEmoji: json['iconEmoji'] as String? ?? '🏆',
      );

  /// Returns all default achievements.
  static List<Achievement> getAllAchievements() {
    return [
      Achievement(
        type: AchievementType.cashOut50x,
        title: 'Fifty Times!',
        description: 'Cash out at 50x multiplier',
        xpReward: 100,
        unlocked: false,
        iconEmoji: '🚀',
      ),
      Achievement(
        type: AchievementType.cashOut100x,
        title: 'Century Club',
        description: 'Cash out at 100x multiplier',
        xpReward: 250,
        unlocked: false,
        iconEmoji: '🌟',
      ),
      Achievement(
        type: AchievementType.cashOut500x,
        title: 'Legend',
        description: 'Cash out at 500x multiplier',
        xpReward: 500,
        unlocked: false,
        iconEmoji: '👑',
      ),
      Achievement(
        type: AchievementType.win5InARow,
        title: 'Hot Streak',
        description: 'Win 5 games in a row',
        xpReward: 150,
        unlocked: false,
        iconEmoji: '🔥',
      ),
      Achievement(
        type: AchievementType.win10InARow,
        title: 'Unstoppable',
        description: 'Win 10 games in a row',
        xpReward: 300,
        unlocked: false,
        iconEmoji: '💪',
      ),
      Achievement(
        type: AchievementType.useAutoCashout10,
        title: 'Auto Pilot',
        description: 'Use auto cash-out 10 times',
        xpReward: 75,
        unlocked: false,
        iconEmoji: '⚙️',
      ),
      Achievement(
        type: AchievementType.useAutoCashout50,
        title: 'Set It and Forget It',
        description: 'Use auto cash-out 50 times',
        xpReward: 200,
        unlocked: false,
        iconEmoji: '🎯',
      ),
      Achievement(
        type: AchievementType.totalGamesReached100,
        title: 'Centennial',
        description: 'Play 100 games',
        xpReward: 120,
        unlocked: false,
        iconEmoji: '💯',
      ),
      Achievement(
        type: AchievementType.totalGamesReached500,
        title: 'Veteran',
        description: 'Play 500 games',
        xpReward: 350,
        unlocked: false,
        iconEmoji: '⭐',
      ),
    ];
  }
}
