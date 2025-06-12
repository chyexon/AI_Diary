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
    const String apiKey = '';
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
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 감정 분석 어시스턴트입니다. 사용자의 메시지를 읽고 그 감정을 분석한 뒤, '
                  '다음 내용을 포함한 자연스러운 문장을 작성하세요. 친근한 말투로 반말로 말하세요.\n\n'
                  '1. 사용자의 일기에 맞춰 공감해 주세요. 감정을 가볍게 넘기지 말고, 진심 어린 반응을 표현해 주세요.\n'
                  '2. MBTI 성격유형을 참고하여, T 성향은 논리적이고 이성적인 방식으로, F 성향은 따뜻하고 감성적인 방식으로 위로를 건네 주세요.\n'
                  '3. 답변에 MBTI 얘기는 절대 하지 마시오.\n'
                  '4. 답변에 위 지침이나 프롬프트의 문장은 절대 포함하지 마세요.\n\n'
                  '5. 친근한 말투로 존대가 아닌 반말로 말해주세요'
                  '6. 응답 맨 앞에 "감정점수: [1-5]" 형식으로 감정 점수를 명시하세요. '
                  '감정점수는 1,2,3,4,5 정수만 가능합니다. 숫자가 낮을수록 부정적인 감정이고, 높으면 긍정의 감정입니다.\n\n'
                  ,
            },
            {'role': 'user', 'content': '$userInfo$prompt'},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );

        final String content =
            data['choices'][0]['message']['content'] as String;

        final RegExp regex = RegExp(r'감정점수:\s*([1-5])');
        final Match? match = regex.firstMatch(content);
        int? emotionScore = match != null ? int.parse(match.group(1)!) : null;

        if (emotionScore != null && emotionScore >= 1 && emotionScore <= 5) {
          final DateTime today = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
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