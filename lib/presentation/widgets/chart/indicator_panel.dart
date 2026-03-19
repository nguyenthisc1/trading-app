import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../data/models/indicator_data.dart';

class RsiPanel extends StatelessWidget {
  final List<IndicatorPoint> points;
  final double height;

  const RsiPanel({super.key, required this.points, this.height = 80});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.clamp(0, 100));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            children: [
              const _IndicatorLabel('RSI(14)', AppColors.indicatorRsi),
              const SizedBox(width: 8),
              Text(
                NumberFormatter.formatIndicatorValue(
                  points.isNotEmpty ? points.first.value : 0,
                ),
                style: const TextStyle(
                  color: AppColors.indicatorRsi,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 30,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.darkBorder.withValues(alpha: 0.4),
                  strokeWidth: 0.5,
                  dashArray: value == 30 || value == 70 ? [4, 4] : null,
                ),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 30,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: AppColors.darkTextHint,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.indicatorRsi,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.indicatorRsi.withValues(alpha: 0.08),
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 70,
                    color: AppColors.bearish.withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
                  HorizontalLine(
                    y: 30,
                    color: AppColors.bullish.withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MacdPanel extends StatelessWidget {
  final List<MacdPoint> points;
  final double height;

  const MacdPanel({super.key, required this.points, this.height = 80});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final macdSpots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.macd))
        .toList();
    final signalSpots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.signal))
        .toList();

    final firstMacd = points.isNotEmpty ? points.first.macd : 0.0;
    final firstSignal = points.isNotEmpty ? points.first.signal : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            children: [
              const _IndicatorLabel('MACD', AppColors.indicatorMacd),
              const SizedBox(width: 8),
              Text(
                NumberFormatter.formatIndicatorValue(firstMacd),
                style: const TextStyle(
                  color: AppColors.indicatorMacd,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const _IndicatorLabel('Signal', AppColors.indicatorSignal),
              const SizedBox(width: 4),
              Text(
                NumberFormatter.formatIndicatorValue(firstSignal),
                style: const TextStyle(
                  color: AppColors.indicatorSignal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.darkBorder.withValues(alpha: 0.4),
                  strokeWidth: 0.5,
                ),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, _) => Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.darkTextHint,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: AppColors.darkTextHint.withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: macdSpots,
                  isCurved: false,
                  color: AppColors.indicatorMacd,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: signalSpots,
                  isCurved: true,
                  color: AppColors.indicatorSignal,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VolumePanel extends StatelessWidget {
  final List<double> volumes;
  final List<bool> isBullish;
  final double height;

  const VolumePanel({
    super.key,
    required this.volumes,
    required this.isBullish,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (volumes.isEmpty) return const SizedBox.shrink();

    final maxVol = volumes.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 4),
          child: _IndicatorLabel('Vol', AppColors.volume),
        ),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              barGroups: volumes.asMap().entries.map((e) {
                final bull = e.key < isBullish.length ? isBullish[e.key] : true;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value / maxVol * height,
                      color: (bull ? AppColors.bullish : AppColors.bearish)
                          .withValues(alpha: 0.6),
                      width: 2,
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                );
              }).toList(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IndicatorLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _IndicatorLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
