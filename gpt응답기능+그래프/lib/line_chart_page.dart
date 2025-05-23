import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'emotion_storage.dart';

class LineChartPage extends StatefulWidget {
  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  List<int> _scores = [];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    List<int> scores = await EmotionStorage.loadEmotionScoreList();
    setState(() {
      _scores = scores;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (int i = 0; i < _scores.length; i++) {
      spots.add(FlSpot(i.toDouble(), _scores[i].toDouble()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('이달의 감정 점수 그래프'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _scores.isEmpty
            ? Center(child: Text('저장된 감정 점수가 없습니다.'))
            : LineChart(
                LineChartData(
                  gridData: FlGridData(show: true), // 눈금선은 보임
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => SizedBox.shrink(),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => SizedBox.shrink(),
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => SizedBox.shrink(),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => SizedBox.shrink(),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      spots: spots,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
