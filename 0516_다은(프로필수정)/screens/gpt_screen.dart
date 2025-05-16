import 'package:flutter/material.dart';
import 'chatgpt.dart'; // ApiService 클래스 import

class GPTScreen extends StatefulWidget {
  @override
  _GPTScreenState createState() => _GPTScreenState();
}

class _GPTScreenState extends State<GPTScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> _getResponse() async {
    final prompt = _controller.text;
    if (prompt.isNotEmpty) {
      final apiService = ApiService();
      final response = await apiService.getGPTResponse(prompt);
      setState(() {
        _response = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPT 감정 음악 추천기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '오늘 하루 있었던 일을 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getResponse,
              child: Text('답변'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response.isNotEmpty
                      ? 'Response:\n$_response'
                      : 'No response yet',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}