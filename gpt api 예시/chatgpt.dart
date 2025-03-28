import 'package:http/http.dart' as http;  // http 패키지 임포트
import 'dart:convert';

class ApiService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';  // GPT API 엔드포인트
  final String apiKey = 'sk-proj-0292kTnvMY9ocnyYEtnuT3BlbkFJ8RCQX2Ax6ASjCebJRNnr';  // 사용자 제공 API Key

  Future<String> getGPTResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',  // GPT 모델 버전 설정
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        // 응답 본문을 UTF-8로 디코딩
        var data = json.decode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];  // OpenAI 응답에서 텍스트 추출
      } else {
        return 'Failed to load response from API';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
