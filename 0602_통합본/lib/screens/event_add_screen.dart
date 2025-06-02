import 'package:flutter/material.dart';
import 'event.dart';

class EventAddScreen extends StatefulWidget {
  final DateTime selectedDate;

  EventAddScreen({required this.selectedDate});

  @override
  _EventAddScreenState createState() => _EventAddScreenState();
}

class _EventAddScreenState extends State<EventAddScreen> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<TimeOfDay?> _pickTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF689F38), // 연두 포인트 색
              onPrimary: Colors.white, // 버튼 텍스트 (확인 등)
              surface: Color(0xFFE6F8D5), // 다이얼로그 배경
              onSurface: Colors.black87, // 일반 텍스트
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일정 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('제목', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            const Text('시작 시간', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await _pickTime(context);
                if (pickedTime != null) {
                  setState(() {
                    _startTime = pickedTime;
                  });
                }
              },
              child: Text(
                _startTime != null ? _startTime!.format(context) : '시작 시간 입력',
              ),
            ),
            const SizedBox(height: 20),

            const Text('종료 시간', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await _pickTime(context);
                if (pickedTime != null) {
                  setState(() {
                    _endTime = pickedTime;
                  });
                }
              },
              child: Text(
                _endTime != null ? _endTime!.format(context) : '종료 시간 입력',
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  String title = _titleController.text;

                  if (title.isEmpty || _startTime == null || _endTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('모든 항목을 입력하세요!')),
                    );
                    return;
                  }

                  Event newEvent = Event(
                    title: title,
                    startTime: DateTime(
                      widget.selectedDate.year,
                      widget.selectedDate.month,
                      widget.selectedDate.day,
                      _startTime!.hour,
                      _startTime!.minute,
                    ),
                    endTime: DateTime(
                      widget.selectedDate.year,
                      widget.selectedDate.month,
                      widget.selectedDate.day,
                      _endTime!.hour,
                      _endTime!.minute,
                    ),
                  );

                  Navigator.pop(context, newEvent);
                },
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
