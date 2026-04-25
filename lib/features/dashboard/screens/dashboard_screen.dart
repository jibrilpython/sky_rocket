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

/// Dashboard overlay showing player stats and flight performance.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final stats = ref.watch(playerStatsProvider);
    final gameState = ref.watch(gameProvider);
    final storage = ref.read(storageServiceProvider);
    final playerName = storage.getPlayerName();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.panelBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLAYER DASHBOARD',
                          style: AppTextStyles.pixelSmall
                              .copyWith(fontSize: 10, color: AppColors.gold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          playerName,
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.panelBorder, height: 1),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Balance Card ──────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentGreen.withValues(alpha: 0.2),
                            AppColors.accentGreen.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              AppColors.accentGreen.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GAME POT',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.accentGreen,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  NumberFormatter.formatCurrency(balance),
                                  style:
                                      AppTextStyles.pixelMedium.copyWith(
                                    color: AppColors.accentGreen,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text: NumberFormatter.formatCurrency(
                                    balance),
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Balance copied!',
                                      style: AppTextStyles.bodySmall),
                                  backgroundColor:
                                      AppColors.darkNavyLight,
                                  duration:
                                      const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded,
                                color: AppColors.accentGreen, size: 20),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

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
                        ),
                        StatCard(
                          icon: Icons.trending_up_rounded,
                          label: 'Net Profit',
                          value: NumberFormatter.formatCurrency(
                              stats.netProfit),
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

                    const SizedBox(height: 24),

                    // ── Flight Performance Chart ─────────
                    Text(
                      'FLIGHT PERFORMANCE',
                      style: AppTextStyles.label.copyWith(
                        letterSpacing: 2,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FlightChart(
                      roundMultipliers: gameState.roundHistory,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
