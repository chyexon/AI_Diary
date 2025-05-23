import 'package:flutter/material.dart';
import 'chatgpt.dart';
import 'emotion_storage.dart';
import 'line_chart_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '감정 점수 저장 앱',
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      home: EmotionApp(),
    );
  }
}

class EmotionApp extends StatefulWidget {
  @override
  _EmotionAppState createState() => _EmotionAppState();
}

class _EmotionAppState extends State<EmotionApp> {
  final TextEditingController _controller = TextEditingController();
  String _aiResponse = '';
  int? _emotionScore;
  bool _isLoading = false;
  int _scoreCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedEmotion();
  }

  Future<void> _loadSavedEmotion() async {
    int? score = await EmotionStorage.loadEmotionScore();
    List<int> list = await EmotionStorage.loadEmotionScoreList();
    setState(() {
      _emotionScore = score;
      _scoreCount = list.length;
    });
  }

  Future<void> _getAndSaveEmotion() async {
    final prompt = _controller.text;
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    final apiService = ApiService();
    var result = await apiService.getGPTResponse(prompt);

    String responseText = result['response'] ?? '';
    int? emotionScore = result['emotionScore'];

    setState(() {
      _aiResponse = responseText;
      _emotionScore = emotionScore;
      _isLoading = false;
    });

    if (emotionScore != null) {
      await EmotionStorage.saveEmotionScore(emotionScore);
      List<int> list = await EmotionStorage.loadEmotionScoreList();
      setState(() {
        _scoreCount = list.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('감정 점수 저장 앱'),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            tooltip: '그래프 보기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LineChartPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '오늘 하루 있었던 일을 입력하세요',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _getAndSaveEmotion,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('감정 점수 분석 및 저장'),
            ),
            SizedBox(height: 16),
            if (_aiResponse.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI 응답:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(_aiResponse),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),
            Text(
              _emotionScore != null
                  ? '저장된 감정 점수: $_emotionScore'
                  : '저장된 감정 점수 없음',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('저장된 감정 점수 개수: $_scoreCount'),
          ],
        ),
      ),
    );
  }
}
