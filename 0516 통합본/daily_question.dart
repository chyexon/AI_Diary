import 'dart:convert';
import 'package:http/http.dart' as http;

/// GPT API로 오늘의 질문을 생성합니다.
Future<String> fetchTodayQuestionFromGPT() async {
  const apiKey = '';
  const url = 'https://api.openai.com/v1/chat/completions';

  const prompt = '''
일기 사용자에게 자기 감정, 경험, 인간관계 등을 깊이 성찰할 수 있도록 돕는 질문을 한 문장으로 작성해 주세요.

조건:
1. "오늘 가장 ~했던 순간은 언제였나요?"이라는 형식은 절대로 사용하지 마세요.
2. 질문 구조, 어휘, 주제 모두에서 다양성과 창의성을 반영하세요.
3. 감정, 기억, 관계, 자존감, 회복력 등 폭넓은 심리적 주제를 다뤄 주세요.
4. 질문은 진심 어린 대화처럼 따뜻하고 개방적으로 표현해야 합니다.

예시 없이, 오늘을 위한 단 하나의 질문을 만들어 주세요.
''';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      "model": "gpt-4",
      "messages": [
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final decoded = utf8.decode(response.bodyBytes);
    final result = jsonDecode(decoded);
    final content = result['choices'][0]['message']['content'].trim();
    return content;
  } else {
    throw Exception('GPT 질문 생성 실패: ${response.body}');
  }
}
