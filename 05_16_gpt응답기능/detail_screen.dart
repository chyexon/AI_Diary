import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'event.dart';
import 'event_add_screen.dart';
import 'chatgpt.dart';
import 'diary_entry.dart';

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
  String _gptResponse = '';
  List<DiaryEntry> _diaryHistory = [];

  @override
  void initState() {
    super.initState();
    _events = widget.events;
    _loadDiaryHistory();
  }

  Future<void> _loadDiaryHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final diaryListString = prefs.getStringList('diary_list') ?? [];
    setState(() {
      _diaryHistory = diaryListString
          .map((item) => DiaryEntry.fromJson(json.decode(item)))
          .toList()
          .reversed
          .toList(); // 최신 항목이 위로 오도록
    });
  }

  Future<void> _saveDiary() async {
  if (_diaryController.text.trim().isEmpty) return;

  final inputText = _diaryController.text.trim();
  final prefs = await SharedPreferences.getInstance();

  // 이미 동일한 입력이 저장된 경우 응답하지 않음
  final diaryListString = prefs.getStringList('diary_list') ?? [];
  final isDuplicate = diaryListString.any((item) {
    final decoded = DiaryEntry.fromJson(json.decode(item));
    return decoded.input == inputText;
  });

  if (isDuplicate) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이미 답변을 받은 일기입니다.')),
    );
    return;
  }

  final apiService = ApiService();
  final gptReply = await apiService.getGPTResponse(inputText);

  diaryListString.add(
    json.encode(DiaryEntry(input: inputText, response: gptReply).toJson()),
  );
  await prefs.setStringList('diary_list', diaryListString);

  setState(() {
    _gptResponse = gptReply;
    _diaryController.clear();
  });

  await _loadDiaryHistory();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('답변이 추가되었습니다!')),
  );
}

  void _addEvent(Event newEvent) {
    setState(() {
      _events.add(newEvent);
    });
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
      decoration: const InputDecoration.collapsed(
        hintText: '오늘 무슨 일이 있었나요?',
      ),
    ),
  ),
),

// GPT 최신 답변 (입력 아래에 표시)
if (_gptResponse.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'GPT 답변:\n$_gptResponse',
        style: TextStyle(fontSize: 16),
      ),
    ),
  ),

          // 답변 버튼
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saveDiary,
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

          // 이전 일기 표시
          if (_diaryHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text('이전 일기:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

          // 일정 리스트 + 이전 일기
          Expanded(
            child: ListView.builder(
              itemCount: _diaryHistory.length,
              itemBuilder: (context, index) {
                final entry = _diaryHistory[index];
                return ExpansionTile(
                  title: Text(
                    entry.input.length > 20
                        ? '${entry.input.substring(0, 20)}...'
                        : entry.input,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('GPT 응답:\n${entry.response}'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

