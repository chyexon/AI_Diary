import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String apiKey = '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';  // 실제 API 키로 교체하세요

  Future<String> getGPTResponse(String prompt) async {
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
                  '당신은 사용자의 메시지를 읽고, 텍스트에 반응한 후 감정을을 분석하여 감정에 맞는 음악을 추천하는 어시스턴트입니다. '
                  '사용자가 직접 요청하지 않아도 매번 마지막 감정에 어울리는 음악을 추천하세요.'
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        return 'API 응답 오류: ${response.statusCode}';
      }
    } catch (e) {
      return '에러 발생: $e';
    }
  }
}
