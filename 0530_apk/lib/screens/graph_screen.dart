import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'emotion_storage.dart';

class GraphScreen extends StatefulWidget {
  final DateTime selectedDate;

  const GraphScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late DateTimeRange selectedDateRange;
  List<int> _scores = [];
  Map<DateTime, int> _dateScoreMap = {};

  @override
  void initState() {
    super.initState();
    final firstDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
    final lastDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + 1,
      0,
    );
    selectedDateRange = DateTimeRange(start: firstDay, end: lastDay);

    _loadScores();
  }

  Future<void> _loadScores() async {
    List<int> scores = await EmotionStorage.loadEmotionScoreList();

    // 선택한 날짜 범위의 일수 계산
    int daysCount = selectedDateRange.duration.inDays + 1;

    DateTime startDate = selectedDateRange.start;
    Map<DateTime, int> dateScoreMap = {};

    for (int i = 0; i < daysCount; i++) {
      DateTime date = startDate.add(Duration(days: i));
      // scores 리스트 길이보다 인덱스가 크면 0으로 기본 처리
      int score = (i < scores.length) ? scores[i] : 0;
      dateScoreMap[date] = score;
    }

    setState(() {
      _scores = scores;
      _dateScoreMap = dateScoreMap;
    });
  }

  void updateGraphData(DateTimeRange range) {
    setState(() {
      selectedDateRange = range;
    });
    _loadScores();
  }

  List<FlSpot> _buildSpots() {
    List<FlSpot> spots = [];
    int idx = 0;
    for (
      DateTime date = selectedDateRange.start;
      !date.isAfter(selectedDateRange.end);
      date = date.add(Duration(days: 1))
    ) {
      int score = _dateScoreMap[date] ?? 0;
      spots.add(FlSpot(idx.toDouble(), score.toDouble()));
      idx++;
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();

    return Scaffold(
      appBar: AppBar(
        title: Text('이달의 감정 점수 그래프'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            tooltip: '날짜 범위 선택',
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: selectedDateRange,
              );
              if (picked != null) {
                updateGraphData(picked);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child:
            spots.isEmpty
                ? Center(child: Text('선택한 날짜 범위 내 데이터가 없습니다.'))
                : LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: spots.length > 0 ? (spots.length - 1).toDouble() : 0,
                    minY: 0.5,
                    maxY: 5.5,
                    clipData: FlClipData.all(),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 0.5,
                          reservedSize: 50,
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
                                width: 30,
                                height: 30,
                              );
                            } else if (value == 0.7 || value == 5.3) {
                              return SizedBox(height: 20);
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 30,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final day =
                                selectedDateRange.start
                                    .add(Duration(days: value.toInt()))
                                    .day;
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '$day일',
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (LineBarSpot touchedSpot) => Colors.transparent,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
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
                              TextStyle(fontSize: 30),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Color(0xff23b6e6), Color(0xff02d39a)],
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
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
