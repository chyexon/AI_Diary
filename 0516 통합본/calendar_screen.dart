import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.dart';
import 'detail_screen.dart';
import 'graph_screen.dart';
import 'setting_screen.dart';
import 'event_edit.dart';
import 'daily_question.dart';
import 'daily_answer.dart';
//import 'gpt_question.dart'; // <- GPT 함수 정의 파일 import

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  String? todayQuestion;
  bool isLoadingQuestion = true;
  Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    loadTodayQuestion();
  }

  void loadTodayQuestion() async {
    setState(() {
      isLoadingQuestion = true;
    });

    try {
      final question = await fetchTodayQuestionFromGPT();
      setState(() {
        todayQuestion = question;
        isLoadingQuestion = false;
      });
    } catch (e) {
      setState(() {
        todayQuestion = '질문을 불러오는 데 실패했습니다.';
        isLoadingQuestion = false;
      });
    }
  }

  DateTime getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[getDateOnly(day)] ?? [];
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        leading: null,
        title: const Text('다이어리 달력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '그래프 보기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraphScreen(selectedDate: selectedDay),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
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
            rowHeight: 80,
            focusedDay: selectedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: const CalendarStyle(
              defaultTextStyle: TextStyle(fontSize: 12),
              weekendTextStyle: TextStyle(fontSize: 12),
              todayTextStyle: TextStyle(fontSize: 12, color: Colors.white),
              selectedTextStyle: TextStyle(fontSize: 12, color: Colors.white),
            ),
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, date, _) {
                return Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 91, 151, 255),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, _) {
                return Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 187, 187, 187),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
              markerBuilder: (context, date, eventsList) {
                if (eventsList.isNotEmpty) {
                  final eventList =
                      eventsList.take(2).map((e) => e as Event).toList();

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          eventList.map((event) {
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => EventEditScreen(
                                          event: event,
                                          onSave: (updatedEvent) {
                                            setState(() {
                                              final dateKey = getDateOnly(date);
                                              final index = events[dateKey]!
                                                  .indexOf(event);
                                              events[dateKey]![index] =
                                                  updatedEvent;
                                            });
                                          },
                                          onDelete: () {
                                            setState(() {
                                              final dateKey = getDateOnly(date);
                                              events[dateKey]!.remove(event);
                                              if (events[dateKey]!.isEmpty) {
                                                events.remove(dateKey);
                                              }
                                            });
                                          },
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    238,
                                    169,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
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
                  builder:
                      (context) => EventDetailScreen(
                        selectedDate: getDateOnly(selectedDay),
                        events: _getEventsForDay(selectedDay),
                        onEventAdded: (newEvent) {
                          setState(() {
                            final eventDate = getDateOnly(selectedDay);
                            events
                                .putIfAbsent(eventDate, () => [])
                                .add(newEvent);
                          });
                        },
                      ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AnswerScreen(question: todayQuestion ?? '질문 없음'),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 질문',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    isLoadingQuestion
                        ? const CircularProgressIndicator()
                        : Text(
                          todayQuestion ?? '질문 없음',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.left,
                        ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children:
                  _getEventsForDay(selectedDay).map((event) {
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(
                        '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                        '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
