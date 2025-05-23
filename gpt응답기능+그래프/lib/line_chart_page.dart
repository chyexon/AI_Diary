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
                  minY: 0.5,
                  maxY: 5.5,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.5,
                        reservedSize: 90,
                        getTitlesWidget: (value, meta) {
                          final emojis = [
                            'assets/images/emoji1.png',
                            'assets/images/emoji2.png',
                            'assets/images/emoji3.png',
                            'assets/images/emoji4.png',
                            'assets/images/emoji5.png',
                          ];
                          if (value >= 1 &&
                              value <= 5 &&
                              value == value.toInt()) {
                            return Image.asset(
                              emojis[value.toInt() - 1],
                              width: 40,
                              height: 40,
                            );
                          } else if (value == 0.7 || value == 5.3) {
                            return SizedBox(height: 20);
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                       tooltipBgColor: Colors.transparent,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          // 점수에 따라 이모지 선택
                          final emojiMap = {
                            1: '😖',
                            2: '🙁',
                            3: '😐',
                            4: '🙂',
                            5: '😊',
                          };
                          final emoji = emojiMap[spot.y.toInt()] ?? '❓';
                          return LineTooltipItem(
                            emoji,
                            const TextStyle(
                              fontSize: 30,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff23b6e6),
                          Color(0xff02d39a),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff23b6e6).withOpacity(0.3),
                            Color(0xff02d39a).withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      spots: spots,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
