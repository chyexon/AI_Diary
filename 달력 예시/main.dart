import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime today = DateTime.now();

  // 날짜 비교 함수 직접 추가
  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('다이어리 달력')),
      body: Center(
        child: TableCalendar(
          focusedDay: today,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: CalendarFormat.month,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            defaultTextStyle: TextStyle(fontSize: 16),
          ),
          selectedDayPredicate: (day) => isSameDay(day, today),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              today = selectedDay;
            });
          },
        ),
      ),
    );
  }
}