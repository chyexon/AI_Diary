import 'package:flutter/material.dart';
import 'event.dart';
import 'event_add_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Event> events; 
  final Function(Event) onEventAdded; // 🔹 캘린더에 일정 추가하는 콜백 함수

  EventDetailScreen({required this.selectedDate, required this.events, required this.onEventAdded});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.selectedDate.month}월 ${widget.selectedDate.day}일 일정')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text('${event.startTime.hour}:${event.startTime.minute} - ${event.endTime.hour}:${event.endTime.minute}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEvent = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventAddScreen(selectedDate: widget.selectedDate),
                ),
              );

              if (newEvent != null) {
                _addEvent(newEvent);
              }
            },
            child: const Text('일정 추가'),
          ),
        ],
      ),
    );
  }
}
