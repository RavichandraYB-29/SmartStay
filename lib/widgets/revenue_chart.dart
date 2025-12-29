import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  final Map<String, double> data;

  const RevenueChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text('No revenue data available');
    }

    final keys = data.keys.toList();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            keys.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[keys[i]]!,
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF6C3BFF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
