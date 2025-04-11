import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.dart';
import 'detail_screen.dart';
import 'graph_screen.dart';    // 🔹 그래프 화면 import
import 'setting_screen.dart'; // 🔧 설정 화면 import

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  Map<DateTime, List<Event>> events = {};

  List<Event> _getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다이어리 달력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart), // 📊 그래프 버튼
            tooltip: '그래프 보기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GraphScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings), // ⚙️ 설정 버튼
            tooltip: '설정',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              defaultTextStyle: TextStyle(fontSize: 16),
            ),
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, eventsList) {
                if (eventsList.isNotEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ...eventsList.take(2).map((e) {
                        Event event = e as Event;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            '${event.title} (${event.startTime.hour}:${event.startTime.minute}~${event.endTime.hour}:${event.endTime.minute})',
                            style: const TextStyle(fontSize: 10, color: Colors.red),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                  );
                } else {
                  return null;
                }
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(
                    selectedDate: selectedDay,
                    events: _getEventsForDay(selectedDay),
                    onEventAdded: (newEvent) {
                      setState(() {
                        DateTime eventDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                        if (events[eventDate] == null) {
                          events[eventDate] = [];
                        }
                        events[eventDate]!.add(newEvent);
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: _getEventsForDay(selectedDay).map((event) {
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text('${event.startTime.hour}:${event.startTime.minute} - ${event.endTime.hour}:${event.endTime.minute}'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day;
  }
}
