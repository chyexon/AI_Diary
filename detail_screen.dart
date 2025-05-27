import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'event.dart';
import 'event_add_screen.dart';
import 'chatgpt.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  List<String> _gptResponses = [];
  File? _selectedImage;

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
    List<String>? savedResponses = prefs.getStringList('${key}_gpt_list');

    if (savedDiary != null) {
      _diaryController.text = savedDiary;
      setState(() {
        _isDiarySaved = true;
        _gptResponses = savedResponses ?? [];
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

    List<String> savedResponses = prefs.getStringList('${key}_gpt_list') ?? [];
    savedResponses.add(gptReply);

    await prefs.setString('${key}_diary', input);
    await prefs.setStringList('${key}_gpt_list', savedResponses);

    setState(() {
      _gptResponses = savedResponses;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일기와 GPT 답변이 저장되었습니다!')),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Column(
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

            // 일기 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
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
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: '오늘 무슨 일이 있었나요?',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            ),

            // 이미지 미리보기
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // GPT 응답 리스트
            if (_gptResponses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _gptResponses
                      .map(
                        (response) => Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SelectableText(
                            'GPT의 답변:\n$response',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            // 일정 리스트
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: _events.map((event) {
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text(
                      '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                      '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),

      // 하단 버튼 영역 (사진 추가 + 저장)
 bottomNavigationBar: SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      children: [
        // ✅ 사진 추가 버튼 (정해진 사이즈)
        SizedBox(
          width: 48,
          height: 48,
          child: InkWell(
            onTap: _isDiarySaved ? null : _pickImage,
            borderRadius: BorderRadius.circular(24),
            child: CircleAvatar(
              backgroundColor: _isDiarySaved ? Colors.grey.shade300 : Colors.grey.shade200,
              child: Icon(
                Icons.add_a_photo,
                color: _isDiarySaved ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ✅ 저장 버튼 (남은 공간 모두 차지)
                Expanded(
          child: SizedBox(
            height: 48,
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
      ],
    ),
  ),
),
    );
  }
}
