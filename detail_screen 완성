import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 임포트
import 'event.dart';
import 'event_add_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Event> events;
  final Function(Event) onEventAdded;

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
  TextEditingController _diaryController = TextEditingController();
  bool _isDiarySaved = false;

  @override
  void initState() {
    super.initState();
    _events = widget.events; // 기존 일정 불러오기
    _loadDiary(); // 일기 내용 불러오기
  }

  // SharedPreferences에서 일기 내용 불러오기
  Future<void> _loadDiary() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedDiary = prefs.getString('${widget.selectedDate.toIso8601String()}_diary');
    if (savedDiary != null) {
      _diaryController.text = savedDiary;
      setState(() {
        _isDiarySaved = true; // 불러온 일기가 있으면 저장된 상태로 표시
      });
    }
  }

  // 일기 저장 함수
  Future<void> _saveDiary() async {
    if (_diaryController.text.trim().isEmpty) return;

    setState(() {
      _isDiarySaved = true;
    });

    // SharedPreferences에 일기 내용 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.selectedDate.toIso8601String()}_diary', _diaryController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일기가 저장되었습니다!')),
    );
  }

  // 일정 추가 함수
  void _addEvent(Event newEvent) {
    setState(() {
      _events.add(newEvent);
    });

    // 부모 화면에 일정 추가 반영
    widget.onEventAdded(newEvent);
  }

  // 일정 추가 화면으로 이동
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
        title: Text('${widget.selectedDate.month}월 ${widget.selectedDate.day}일 일정'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 일정 추가 버튼
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: ElevatedButton(
              onPressed: _navigateToAddEvent,
              child: const Text('일정 추가'),
            ),
          ),

          // 일기 입력 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FD),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                controller: _diaryController,
                maxLines: 6,
                readOnly: _isDiarySaved, // 저장 후 읽기 전용
                decoration: const InputDecoration.collapsed(
                  hintText: '오늘 무슨 일이 있었나요?',
                ),
              ),
            ),
          ),

          // 답변 버튼
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isDiarySaved ? null : _saveDiary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F6FD),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text('답변'),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 일정 리스트
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
        ],
      ),
    );
  }
}

