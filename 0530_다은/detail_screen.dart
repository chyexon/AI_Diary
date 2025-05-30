import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

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

  List<Uint8List> _selectedImageList = [];

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
    List<String>? base64List = prefs.getStringList('${key}_image_list');

    if (savedDiary != null) {
      _diaryController.text = savedDiary;
      setState(() {
        _isDiarySaved = true;
        _gptResponse = savedResponse ?? '';
      });
    }

    if (base64List != null) {
      setState(() {
        _selectedImageList = base64List.map((b64) => base64Decode(b64)).toList();
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

    if (_selectedImageList.isNotEmpty) {
      List<String> base64List =
          _selectedImageList.map((bytes) => base64Encode(bytes)).toList();
      await prefs.setStringList('${key}_image_list', base64List);
    }

    setState(() {
      _gptResponse = gptReply;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일기와 답변이 저장되었어요!')),
    );
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedImageList.addAll(
          result.files
              .where((file) => file.bytes != null)
              .map((file) => file.bytes!)
              .toList(),
        );
      });
    }
  }

  void _showFullImage(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.memory(imageBytes),
          ),
        ),
      ),
    );
  }

  void _addEvent(Event newEvent) {
    bool isDuplicate = _events.any((event) =>
        event.title == newEvent.title &&
        event.startTime == newEvent.startTime &&
        event.endTime == newEvent.endTime);

    if (!isDuplicate) {
      widget.onEventAdded(newEvent);
      setState(() {
        _events.add(newEvent);
      });
    }
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
        child: Column(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _diaryController,
                      maxLines: 6,
                      readOnly: _isDiarySaved,
                      decoration: const InputDecoration.collapsed(
                        hintText: '오늘 무슨 일이 있었나요?',
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedImageList.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _selectedImageList.asMap().entries.map((entry) {
                            int index = entry.key;
                            Uint8List imageBytes = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () => _showFullImage(imageBytes),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.memory(
                                        imageBytes,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImageList.removeAt(index);
                                          });
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.black54,
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  ElevatedButton(
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
                ],
              ),
            ),
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
                    '답변:\n$_gptResponse',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}



