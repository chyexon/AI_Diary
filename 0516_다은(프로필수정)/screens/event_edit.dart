import 'package:flutter/material.dart';
import 'event.dart';

class EventEditScreen extends StatefulWidget {
  final Event event;
  final Function(Event updatedEvent) onSave;
  final Function() onDelete;

  const EventEditScreen({
    Key? key,
    required this.event,
    required this.onSave,
    required this.onDelete,
  }) : super(key: key);

  @override
  _EventEditScreenState createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  late TextEditingController _titleController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.event.endTime);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 수정'),
        actions: [
          TextButton(
            onPressed: () {
              final updatedEvent = Event(
                title: _titleController.text,
                startTime: DateTime(
                  widget.event.startTime.year,
                  widget.event.startTime.month,
                  widget.event.startTime.day,
                  _startTime.hour,
                  _startTime.minute,
                ),
                endTime: DateTime(
                  widget.event.endTime.year,
                  widget.event.endTime.month,
                  widget.event.endTime.day,
                  _endTime.hour,
                  _endTime.minute,
                ),
              );
              widget.onSave(updatedEvent);
              Navigator.pop(context);
            },
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('시작 시간'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () => _pickTime(true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('종료 시간'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                widget.onDelete();
                Navigator.pop(context);
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}