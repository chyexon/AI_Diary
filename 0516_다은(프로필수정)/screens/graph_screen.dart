import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphScreen extends StatefulWidget {
  final DateTime selectedDate;
  GraphScreen({required this.selectedDate});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late DateTimeRange selectedDateRange;
  late List<double> dataPoints;

  @override
  void initState() {
    super.initState();
    final firstDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    final lastDay = DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0);
    selectedDateRange = DateTimeRange(start: firstDay, end: lastDay);
    dataPoints = List.generate(
      selectedDateRange.end.day - selectedDateRange.start.day + 1,
      (i) => (i + 1) * 2.5,
    );
  }

  void updateGraphData(DateTimeRange range) {
    setState(() {
      selectedDateRange = range;
      dataPoints = List.generate(
        range.end.day - range.start.day + 1,
        (i) => (i + 1) * 2.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그래프 보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: '날짜 범위 선택',
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: selectedDateRange,
              );
              if (range != null) updateGraphData(range);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '범위: ${selectedDateRange.start.month}/${selectedDateRange.start.day} - '
              '${selectedDateRange.end.month}/${selectedDateRange.end.day}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final date = selectedDateRange.start.add(Duration(days: value.toInt()));
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text('${date.day}일', style: TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    belowBarData: BarAreaData(show: true),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}