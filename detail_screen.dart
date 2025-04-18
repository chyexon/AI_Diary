import 'package:flutter/material.dart';
import 'event.dart';
import 'event_add_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Event> events;
  final Function(Event) onEventAdded; // 🔹 캘린더에 일정 추가하는 콜백 함수

  EventDetailScreen({
    required this.selectedDate,
    required this.events,
    required this.onEventAdded,
  });

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _events = widget.events; // 🔹 기존 일정 불러오기
  }

  // 🔹 일정 추가 함수
  void _addEvent(Event newEvent) {
    setState(() {
      _events.add(newEvent);
    });

    // 🔹 부모 페이지(CalendarScreen)에 일정 추가 반영
    widget.onEventAdded(newEvent);
  }

  Future<void> _navigateToAddEvent() async {
    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventAddScreen(selectedDate: widget.selectedDate),
      ),
    );

    if (newEvent != null) {
      _addEvent(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.selectedDate.month}월 ${widget.selectedDate.day}일 일정',
        ),
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16.0)),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                    '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                    '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _navigateToAddEvent,
              child: const Text('일정 추가'),
            ),
          ),
        ],
      ),
    );
  }
}
