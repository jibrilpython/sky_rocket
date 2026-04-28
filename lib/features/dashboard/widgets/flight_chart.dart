import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Enhanced line chart showing last N round multipliers with
/// colour-coded dots, gradient fill, and interactive tooltips.
class FlightChart extends StatelessWidget {
  const FlightChart({super.key, required this.roundMultipliers});

  final List<double> roundMultipliers;

  Color _dotColor(double value) {
    if (value >= 10.0) return AppColors.gold;
    if (value >= 5.0) return AppColors.chipGreen;
    if (value >= 2.0) return AppColors.chipYellow;
    return AppColors.chipRed;
  }

  @override
  Widget build(BuildContext context) {
    if (roundMultipliers.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface,
              AppColors.surface.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.panelBorder.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: AppColors.textMuted.withValues(alpha: 0.3),
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'NO FLIGHT DATA YET',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  letterSpacing: 2,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Play rounds to see your performance',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < roundMultipliers.length; i++) {
      spots.add(FlSpot(i.toDouble(), roundMultipliers[i]));
    }

    final maxY = roundMultipliers.reduce((a, b) => a > b ? a : b) + 1;

    return Container(
      height: 200,
      padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.panelBorder.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.panelBorder.withValues(alpha: 0.15),
              strokeWidth: 0.8,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (roundMultipliers.length / 5).ceilToDouble().clamp(1, 10),
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= roundMultipliers.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '#${value.toInt() + 1}',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 7,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${value.toStringAsFixed(1)}x',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 8,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: const LinearGradient(
                colors: [
                  AppColors.accentOrange,
                  AppColors.accentGreen,
                ],
              ),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, xValue, barData, index) {
                  final color = _dotColor(spot.y);
                  return FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 1.5,
                    strokeColor: AppColors.darkNavy,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accentGreen.withValues(alpha: 0.25),
                    AppColors.accentGreen.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final color = _dotColor(spot.y);
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(2)}x',
                    AppTextStyles.chipText.copyWith(
                      color: color,
                      fontSize: 10,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
