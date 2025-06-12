import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/emotion_storage.dart';
import '../models/user_profile.dart';

class ApiService {
  Future<Map<String, dynamic>> getGPTResponse(
    String prompt,
    DateTime selectedDate,
  ) async {
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';
    const String apiKey = ''; // 여기에 실제 API 키 넣기

    try {
      String userInfo = '';
      if (currentUser != null) {
        userInfo = '사용자 MBTI는 "${currentUser!.mbti}"입니다. ';
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'temperature': 0.5,  // 답변 톤 안정화
          'messages': [
            {
              'role': 'system',
              'content': '''
너는 감정 분석 어시스턴트야. 사용자의 메시지를 읽고 감정을 분석해. 사용자의 일기에 맞춰 공감해 주세요. 감정을 가볍게 넘기지 말고, 진심 어린 반응을 표현해 주세요
답변은 무조건 반말로 친근하게 작성해야 해.
절대 존댓말 쓰지 말고 MBTI 이야기도 하지 마.
응답 맨 앞에는 반드시 "감정점수: [숫자]" 형식으로 감정 점수를 적어주세요. 감정점수는 반드시 1, 2, 3, 4, 5 중 하나의 정수여야 하며, 절대 소수점이나 다른 형식의 숫자를 사용하지 마세요. 숫자가 낮을수록 부정적인 감정이고, 숫자가 높을수록 긍정적인 감정입니다..
'''
            },
            {
              'role': 'user',
              'content': '아래 메시지에 대해 무조건 반말로 답해줘.'
            },
            {
              'role': 'user',
              'content': '$userInfo$prompt',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );

        final String content = data['choices'][0]['message']['content'] as String;

        final RegExp regex = RegExp(r'감정점수:\s*([1-5])');
        final Match? match = regex.firstMatch(content);
        int? emotionScore = match != null ? int.parse(match.group(1)!) : null;

        if (emotionScore != null && emotionScore >= 1 && emotionScore <= 5) {
          await EmotionStorage.saveEmotionScore(
            date: selectedDate,
            score: emotionScore,
          );
        }

        final String cleanContent = content.replaceFirst(regex, '').trim();

        return {'response': cleanContent, 'emotionScore': emotionScore};
      } else {
        return {
          'response': 'API 오류: ${response.statusCode}\n${response.body}',
          'emotionScore': null,
        };
      }
    } catch (e) {
      return {'response': '에러 발생: $e', 'emotionScore': null};
    }
  }
}
