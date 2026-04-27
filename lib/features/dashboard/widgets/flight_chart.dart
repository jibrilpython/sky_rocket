import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Line chart showing last N round multipliers.
class FlightChart extends StatelessWidget {
  const FlightChart({super.key, required this.roundMultipliers});

  final List<double> roundMultipliers;

  @override
  Widget build(BuildContext context) {
    if (roundMultipliers.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'No flight data yet',
          style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < roundMultipliers.length; i++) {
      spots.add(FlSpot(i.toDouble(), roundMultipliers[i]));
    }

    final maxY = roundMultipliers.reduce((a, b) => a > b ? a : b) + 1;

    return Container(
      height: 180,
      padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.panelBorder, width: 1),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
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
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(1)}x',
                    style: AppTextStyles.label.copyWith(fontSize: 8),
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
              color: AppColors.accentGreen,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, xValue, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.accentGreen,
                    strokeWidth: 1,
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
                    AppColors.accentGreen.withValues(alpha: 0.3),
                    AppColors.accentGreen.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(2)}x',
                    AppTextStyles.chipText.copyWith(
                      color: AppColors.accentGreen,
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
