import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;



import 'event.dart';
import 'event_add_screen.dart';
import 'chatgpt.dart';
import 'youtube_api.dart';

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

  String? _youtubeVideoId; //유튜브 변수 추가

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
  String? savedVideoId = prefs.getString('${key}_youtubeVideoId');  // 추가

  if (savedDiary != null) {
    _diaryController.text = savedDiary;
    setState(() {
      _isDiarySaved = true;
      _gptResponse = savedResponse ?? '';
      _youtubeVideoId = savedVideoId;  // 추가
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
  final Map<String, dynamic> result = await apiService.getGPTResponse(input, widget.selectedDate);
  final gptReply = result['response'] ?? '';

  await prefs.setString('${key}_diary', input);
  await prefs.setString('${key}_gpt', gptReply);

  if (_selectedImageList.isNotEmpty) {
    List<String> base64List = _selectedImageList.map((bytes) => base64Encode(bytes)).toList();
    await prefs.setStringList('${key}_image_list', base64List);
  }

  // 유튜브 검색 결과 받아오기
  try {
    final results = await searchYouTube(input);
    if (results.isNotEmpty && results[0]['id'] != null) {
      setState(() {
        _youtubeVideoId = results[0]['id'];
      });
      await prefs.setString('${key}_youtubeVideoId', _youtubeVideoId!);  // 저장 추가
    }
  } catch (e) {
    print('유튜브 검색 에러: $e');
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
          result.files.where((file) => file.bytes != null).map((file) => file.bytes!).toList(),
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
          child: InteractiveViewer(child: Image.memory(imageBytes)),
        ),
      ),
    );
  }

  void _addEvent(Event newEvent) {
    bool isDuplicate = _events.any(
      (event) =>
          event.title == newEvent.title &&
          event.startTime == newEvent.startTime &&
          event.endTime == newEvent.endTime,
    );

    if (!isDuplicate) {
      setState(() {
        _events.add(newEvent);
      });
      widget.onEventAdded(newEvent);
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
        title: Text('${widget.selectedDate.month}월 ${widget.selectedDate.day}일'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: ElevatedButton(
                onPressed: _navigateToAddEvent,
                style: ElevatedButton.styleFrom(foregroundColor: const Color(0xFF689F38)),
                child: const Text('일정 추가'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                    Positioned(
                    top: 125,
                    right: -20,
                    child: CustomPaint(
                      size: const Size(30, 20),
                      painter: BubbleTailPainter(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8D5),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: Color(0xFFB2DF8A)),
                    ),
                    child: Column(
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
                                              child: const Icon(Icons.close, color: Colors.white, size: 16),
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
                ],
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
                        child: Icon(Icons.add_a_photo, color: _isDiarySaved ? Colors.grey : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isDiarySaved ? null : _saveDiary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDCEFB8),
                      foregroundColor: const Color(0xFF33691E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                    child: const Text('저장'),
                  ),
                ],
              ),
            ),
            if (_gptResponse.isNotEmpty)
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 12.0, top: 4.0),
        child: Image.asset(
          'assets/images/hachi.png',
          width: 48,
          height: 48,
        ),
      ),
      Expanded(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 꼬리 먼저
            Positioned(
              top: 18,   // 필요에 따라 조정
              left: -15, // 말풍선 바깥으로 튀어나가게
              child: CustomPaint(
                size: const Size(30, 20),
                painter: LeftSideTailPainter(),
              ),
            ),
            // 말풍선 본체
            Padding(
              padding: const EdgeInsets.only(left: 10), // 꼬리와 글자 겹침 방지
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 230),
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
      '하치의 답장:\n' +
          _gptResponse
              .replaceAll(RegExp(r'https:\/\/www\.youtube\.com\/watch\?v=[\w-]+'), '')
              .replaceAllMapped(
                RegExp(r'\[\s*([^\]]+?)\s*\]\(\s*\)'),
                (match) => match.group(1) ?? '',
              ),
      style: const TextStyle(fontSize: 16),
    ),
    const SizedBox(height: 12),
    if (_youtubeVideoId != null) // null 체크
      GestureDetector(
        onTap: () async {
          final url = 'https://www.youtube.com/watch?v=$_youtubeVideoId';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('유튜브 링크를 열 수 없습니다.')),
            );
          }
        },
        child: Text(
          '추천 영상 보기 ▶',
          style: const TextStyle(
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
          ],
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE6F8D5);
      final outlinePaint = Paint()
      ..color = const Color.fromARGB(255, 178, 223, 138)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LeftSideTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4); // 그림자 효과

    final borderPaint = Paint()
      ..color = Color.fromARGB(255, 255, 255, 230) // 말풍선 배경색과 동일
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height);
    path.close();

    // 그림자 먼저 그리기 (약간 이동해서 효과처럼 보이게)
    canvas.save();
    canvas.translate(1, 2); // 그림자 위치 조정
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 꼬리 본체
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}