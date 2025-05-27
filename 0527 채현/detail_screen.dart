import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'event.dart';
import 'event_add_screen.dart';
import 'chatgpt.dart';

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
  String _gptResponse = '';

  @override
  void initState() {
    super.initState();
    _events = widget.events;
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    final prefs = await SharedPreferences.getInstance();
    String key = widget.selectedDate.toIso8601String();

    String? savedDiary = prefs.getString('${key}_diary');
    String? savedResponse = prefs.getString('${key}_gpt');

    if (savedDiary != null) {
      _diaryController.text = savedDiary;
      setState(() {
        _isDiarySaved = true;
        _gptResponse = savedResponse ?? '';
      });
    }
  }

  Future<void> _saveDiary() async {
    if (_diaryController.text.trim().isEmpty) return;

    final input = _diaryController.text.trim();

    setState(() {
      _isDiarySaved = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String key = widget.selectedDate.toIso8601String();

    final apiService = ApiService();
    final gptReply = await apiService.getGPTResponse(input);

    await prefs.setString('${key}_diary', input);
    await prefs.setString('${key}_gpt', gptReply);

    setState(() {
      _gptResponse = gptReply;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('일기와 답변이 저장되었어요!')));
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

  // 🔍 YouTube 링크 추출
  String? extractYouTubeLink(String text) {
    final regex = RegExp(r'https:\/\/www\.youtube\.com\/watch\?v=[\w-]+');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final youTubeUrl = extractYouTubeLink(_gptResponse);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.selectedDate.month}월 ${widget.selectedDate.day}일 일정',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                readOnly: _isDiarySaved,
                decoration: const InputDecoration.collapsed(
                  hintText: '오늘 무슨 일이 있었나요?',
                ),
              ),
            ),
          ),
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
                child: const Text('저장'),
              ),
            ),
          ),
          if (_gptResponse.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '답변:\n' +
                          _gptResponse
                              .replaceAll(
                                RegExp(
                                  r'https:\/\/www\.youtube\.com\/watch\?v=[\w-]+',
                                ),
                                '',
                              )
                              .replaceAllMapped(
                                RegExp(r'\[\s*([^\]]+?)\s*\]\(\s*\)'),
                                (match) => match.group(1) ?? '',
                              ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (youTubeUrl != null)
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(youTubeUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: const Text(
                          '[추천 음악 듣기]',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
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
