import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnswerScreen extends StatefulWidget {
  final String question;

  const AnswerScreen({Key? key, required this.question}) : super(key: key);

  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAnswer();
  }

  Future<void> _loadSavedAnswer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10);
    String key = 'daily_answer_$today';
    String? savedAnswer = prefs.getString(key);

    if (savedAnswer != null) {
      _controller.text = savedAnswer;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 답변')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '질문',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.question, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 24),
                    Text(
                      '답변 작성',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '오늘의 답변을 작성해 보세요.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final answer = _controller.text;
                          if (answer.trim().isNotEmpty) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String today = DateTime.now()
                                .toIso8601String()
                                .substring(0, 10);
                            String key = 'daily_answer_$today';
                            await prefs.setString(key, answer);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('답변이 저장되었습니다!')),
                            );
                            Navigator.pop(context);
                          }
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
