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
  Map<DateTime, int> _dateScoreMap = {};

  @override
  void initState() {
    super.initState();

    // 기본 날짜 범위: 전달의 첫날 ~ 마지막날
    final firstDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    final lastDay = DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0);
    selectedDateRange = DateTimeRange(start: firstDay, end: lastDay);

    _loadScores();

    // 화면 렌더링 후 날짜 범위 선택창 자동 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDateRangePicker();
    });
  }

  Future<void> _loadScores() async {
    final Map<DateTime, int> storedMap = await EmotionStorage.loadEmotionScoreMap();
    final int daysCount = selectedDateRange.duration.inDays + 1;
    final DateTime startDate = selectedDateRange.start;

    Map<DateTime, int> dateScoreMap = {};

    for (int i = 0; i < daysCount; i++) {
      final DateTime date = startDate.add(Duration(days: i));
      final int score = storedMap[date] ?? 0;
      dateScoreMap[date] = score;
    }

    setState(() {
      _dateScoreMap = dateScoreMap;
    });
  }

  void updateGraphData(DateTimeRange range) {
    selectedDateRange = range;
    _loadScores();
  }

  Future<void> _showDateRangePicker() async {
    final baseTheme = Theme.of(context);
    final customTheme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Color(0xFF8BC34A),
        onPrimary: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      datePickerTheme: DatePickerThemeData(
        rangeSelectionBackgroundColor: Color(0xFFE6F8D5),
      ),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: selectedDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: customTheme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      updateGraphData(picked);
    }
  }

  List<FlSpot> _buildSpots() {
    final List<FlSpot> spots = [];
    int idx = 0;

    for (DateTime date = selectedDateRange.start;
        !date.isAfter(selectedDateRange.end);
        date = date.add(Duration(days: 1))) {
      final int score = _dateScoreMap[date] ?? 0;
      spots.add(FlSpot(idx.toDouble(), score.toDouble()));
      idx++;
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();

    final baseTheme = Theme.of(context);
    final customTheme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Color(0xFF8BC34A),
        onPrimary: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      datePickerTheme: DatePickerThemeData(
        rangeSelectionBackgroundColor: Color(0xFFE6F8D5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('감정 점수 그래프'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            tooltip: '날짜 범위 선택',
            onPressed: _showDateRangePicker,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: spots.every((spot) => spot.y == 0)
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
                          interval: 1,
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
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
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
                            if (spot.y == 0) return null;
                            final emojiMap = {
                              1: '😖',
                              2: '🙁',
                              3: '😐',
                              4: '🙂',
                              5: '😊',
                            };
                            final emoji = emojiMap[spot.y.toInt()] ?? '❓';

                            final date = selectedDateRange.start.add(Duration(days: spot.x.toInt()));
                            final dateStr = '${date.month}/${date.day}';

                            return LineTooltipItem(
                              '$emoji\n$dateStr',
                              TextStyle(fontSize: 16, color: Colors.black),
                            );
                          }).whereType<LineTooltipItem>().toList();
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
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) => spot.y > 0,
                        ),
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
      ),
    );
  }
}
