import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'emotion_storage.dart';

class EmotionDonutChartPage extends StatefulWidget {
  @override
  _EmotionDonutChartPageState createState() => _EmotionDonutChartPageState();
}

class _EmotionDonutChartPageState extends State<EmotionDonutChartPage> {
  List<int> _scores = [];
  Map<int, int> _counts = {};
  double _average = 0.0;

  final Map<int, Color> colorMap = {
    1: Colors.red,
    2: Colors.orange,
    3: Colors.yellow,
    4: Colors.lightGreen,
    5: Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final scores = await EmotionStorage.loadEmotionScoreList();

    // 점수별 개수 계산
    Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var s in scores) {
      if (counts.containsKey(s)) {
        counts[s] = counts[s]! + 1;
      }
    }

    // 평균 계산 (0점 제외)
    double avg = 0;
    if (scores.isNotEmpty) {
      avg = scores.reduce((a, b) => a + b) / scores.length;
    }

    setState(() {
      _scores = scores;
      _counts = counts;
      _average = avg;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_scores.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('감정 도넛 그래프')),
        body: Center(child: Text('저장된 감정 점수가 없습니다.')),
      );
    }

    // 전체 개수 (파이 비율 계산용)
    int totalCount = _counts.values.fold(0, (sum, val) => sum + val);

    return Scaffold(
      appBar: AppBar(title: Text('감정 도넛 그래프')),
      body: Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60, // 도넛 가운데 공간 크기
                  sections: _counts.entries
                      .where((entry) => entry.value > 0)
                      .map((entry) {
                    final percentage = entry.value / totalCount * 100;
                    return PieChartSectionData(
                      color: colorMap[entry.key],
                      value: entry.value.toDouble(),
                      title: '${entry.key}점\n${entry.value}개',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: 0.6,
                    );
                  }).toList(),
                ),
              ),
              // 도넛 중앙에 평균 점수 표시
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '평균',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _average.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
