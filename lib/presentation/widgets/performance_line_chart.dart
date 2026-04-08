import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PerformanceLineChart extends StatelessWidget {
  const PerformanceLineChart({super.key, required this.points});

  final List<double> points;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    var minY = points.reduce((a, b) => a < b ? a : b);
    var maxY = points.reduce((a, b) => a > b ? a : b);
    if ((maxY - minY).abs() < 1e-6) {
      minY -= 5;
      maxY += 5;
    }
    final pad = (maxY - minY) * 0.12;

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i]),
    ];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY - pad,
          maxY: maxY + pad,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.textMuted.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.75), fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i % 2 != 0 || i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.65), fontSize: 10),
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
              curveSmoothness: 0.22,
              color: AppColors.neonCyan,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonCyan.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
