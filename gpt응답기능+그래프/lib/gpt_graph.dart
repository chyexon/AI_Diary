//chatgpt.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String apiKey = '앱키';

  Future<Map<String, dynamic>> getGPTResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 사용자의 메시지를 읽고, 텍스트에 반응한 후 감정을 분석하여 감정에 맞는 음악을 추천하는 어시스턴트입니다. '
                  '사용자가 직접 요청하지 않아도 매번 마지막 감정에 어울리는 음악을 추천하세요. '
                  '그리고 사용자의 감정을 1부터 5 범위의 정수로 분석하세요. 숫자가 낮을수록 부정의 감정입니다 '
                  '응답 맨 앞에 다음 형식으로 감정 점수를 명시하세요: 감정점수: [정수]'
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        String content = data['choices'][0]['message']['content'];

        // 감정점수 파싱
        RegExp regex = RegExp(r'감정점수:\s*(-?\d+)');
        Match? match = regex.firstMatch(content);
        int? emotionScore;
        if (match != null) {
          emotionScore = int.parse(match.group(1)!);
        }

        return {
          'response': content,
          'emotionScore': emotionScore,
        };
      } else {
        return {
          'response': 'API 응답 오류: ${response.statusCode}',
          'emotionScore': null,
        };
      }
    } catch (e) {
      return {
        'response': '에러 발생: $e',
        'emotionScore': null,
      };
    }
  }
}
