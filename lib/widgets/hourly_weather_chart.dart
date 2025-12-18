import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HourlyWeatherChart extends StatelessWidget {
  final List<dynamic> forecast;

  const HourlyWeatherChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final items = forecast.take(8).toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < items.length; i++) {
      final temp = (items[i]["main"]["temp"] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), temp));
    }

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
