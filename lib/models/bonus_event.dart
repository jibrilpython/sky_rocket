/// Types of bonus round events.
enum BonusEventType {
  cometStrike,
  fuelBoost,
  slowMotion,
  multiplierDouble,
}

/// Represents a bonus event that can occur during a round.
class BonusEvent {
  const BonusEvent({
    required this.type,
    required this.name,
    required this.description,
    required this.triggerTime, // seconds into flight when event triggers
    required this.multiplierModifier, // 1.0 = no change, 1.5 = 50% boost, etc.
    required this.durationMs, // how long the effect lasts
    this.emoji = '✨',
  });

  final BonusEventType type;
  final String name;
  final String description;
  final double triggerTime;
  final double multiplierModifier;
  final int durationMs;
  final String emoji;

  /// Get a random bonus event (if bonus triggers, ~20% chance per round).
  static BonusEvent? getRandomBonusEvent() {
    final rand = DateTime.now().millisecondsSinceEpoch % 100;
    
    // 20% chance to trigger any bonus
    if (rand > 80) {
      final eventIndex = DateTime.now().millisecondsSinceEpoch % 4;
      switch (eventIndex) {
        case 0:
          return const BonusEvent(
            type: BonusEventType.fuelBoost,
            name: 'Fuel Boost! 🚀',
            description: 'Multiplier growth accelerates',
            triggerTime: 2.0,
            multiplierModifier: 1.5,
            durationMs: 3000,
            emoji: '⛽',
          );
        case 1:
          return const BonusEvent(
            type: BonusEventType.slowMotion,
            name: 'Time Warp ⏱️',
            description: 'Multiplier growth slows (but you have time!)',
            triggerTime: 3.0,
            multiplierModifier: 0.5,
            durationMs: 4000,
            emoji: '⏳',
          );
        case 2:
          return const BonusEvent(
            type: BonusEventType.multiplierDouble,
            name: 'Double Power! 💥',
            description: 'Next multiplier milestone doubled',
            triggerTime: 1.5,
            multiplierModifier: 2.0,
            durationMs: 2000,
            emoji: '🎯',
          );
        default:
          return const BonusEvent(
            type: BonusEventType.cometStrike,
            name: 'Comet Strike! ☄️',
            description: 'Crash point increased by 1.5x',
            triggerTime: 2.5,
            multiplierModifier: 1.3,
            durationMs: 1000,
            emoji: '☄️',
          );
      }
    }
    return null;
  }
}
