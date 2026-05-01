import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../providers/balance_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/player_stats_provider.dart';
import '../widgets/flight_chart.dart';
import '../widgets/stat_card.dart';
import '../../game/widgets/level_display.dart';

/// Premium dashboard overlay showing player stats and flight performance.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final stats = ref.watch(playerStatsProvider);
    final gameState = ref.watch(gameProvider);
    final storage = ref.read(storageServiceProvider);
    final playerName = storage.getPlayerName();

    final winRate = stats.totalGames > 0
        ? ((stats.totalWins / stats.totalGames) * 100).toStringAsFixed(1)
        : '0.0';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E1E38), AppColors.darkNavy],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.accentOrange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.8),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentOrange.withValues(alpha: 0.5),
                          AppColors.gold.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Player avatar circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accentOrange,
                                AppColors.accentOrange.withValues(alpha: 0.6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentOrange.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              playerName.isNotEmpty
                                  ? playerName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.pixelMedium.copyWith(
                                color: AppColors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playerName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentOrange.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${stats.totalGames} GAMES',
                                      style: AppTextStyles.label.copyWith(
                                        fontSize: 8,
                                        color: AppColors.accentOrange,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGreen.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$winRate% WIN',
                                      style: AppTextStyles.label.copyWith(
                                        fontSize: 8,
                                        color: AppColors.accentGreen,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Close button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.panelBorder.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider with gradient
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.panelBorder.withValues(alpha: 0),
                          AppColors.panelBorder,
                          AppColors.panelBorder.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // ── Balance Card ──────────────────────
                        _BalanceHeroCard(balance: balance),

                        const SizedBox(height: 20),

                        // ── Level Display ──────────────────────
                        const LevelDisplay(),

                        const SizedBox(height: 20),

                        // Section label
                        _SectionLabel(
                          title: 'STATISTICS',
                          icon: Icons.analytics_rounded,
                        ),
                        const SizedBox(height: 12),

                        // ── Stats Grid ───────────────────────
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.4,
                          children: [
                            StatCard(
                              icon: Icons.gamepad_rounded,
                              label: 'Total Games',
                              value: stats.totalGames.toString(),
                              valueColor: AppColors.textPrimary,
                            ),
                            StatCard(
                              icon: Icons.trending_up_rounded,
                              label: 'Net Profit',
                              value: NumberFormatter.formatCurrency(
                                stats.netProfit,
                              ),
                              valueColor: stats.netProfit >= 0
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed,
                            ),
                            StatCard(
                              icon: Icons.auto_awesome_rounded,
                              label: 'Best Multiplier',
                              value: stats.bestMultiplier > 0
                                  ? '${stats.bestMultiplier.toStringAsFixed(2)}x'
                                  : '—',
                              valueColor: AppColors.gold,
                            ),
                            StatCard(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Current Streak',
                              value: stats.currentStreak.toString(),
                              valueColor: stats.currentStreak > 0
                                  ? AppColors.accentOrange
                                  : AppColors.textPrimary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Extra stats row
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStatPill(
                                label: 'WINS',
                                value: '${stats.totalWins}',
                                color: AppColors.accentGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStatPill(
                                label: 'LOSSES',
                                value: '${stats.totalLosses}',
                                color: AppColors.accentRed,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStatPill(
                                label: 'WIN RATE',
                                value: '$winRate%',
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Flight Performance Chart ─────────
                        _SectionLabel(
                          title: 'FLIGHT PERFORMANCE',
                          icon: Icons.show_chart_rounded,
                        ),
                        const SizedBox(height: 12),
                        FlightChart(roundMultipliers: gameState.roundHistory),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Premium balance hero card with gradient and animated shimmer.
class _BalanceHeroCard extends StatefulWidget {
  const _BalanceHeroCard({required this.balance});
  final double balance;

  @override
  State<_BalanceHeroCard> createState() => _BalanceHeroCardState();
}

class _BalanceHeroCardState extends State<_BalanceHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentGreen.withValues(alpha: 0.18),
                AppColors.accentGreen.withValues(alpha: 0.06),
                AppColors.accentGreen.withValues(alpha: 0.12),
              ],
              stops: [0, _shimmerCtrl.value, 1],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.accentGreen.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Balance icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAME POT',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accentGreen.withValues(alpha: 0.7),
                        letterSpacing: 2,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormatter.formatCurrency(widget.balance),
                      style: AppTextStyles.pixelMedium.copyWith(
                        color: AppColors.accentGreen,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              // Copy button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: NumberFormatter.formatCurrency(widget.balance),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.accentGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Balance copied!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.darkNavyLight,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    color: AppColors.accentGreen,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Section label with icon and line decoration.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            letterSpacing: 2,
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.panelBorder.withValues(alpha: 0.5),
                  AppColors.panelBorder.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact stat pill for the supplementary stat row.
class _MiniStatPill extends StatelessWidget {
  const _MiniStatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.pixelSmall.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 7,
              letterSpacing: 1,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
