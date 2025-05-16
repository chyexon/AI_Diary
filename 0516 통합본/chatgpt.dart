import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_profile.dart';

class ApiService {
  Future<String> getGPTResponse(String prompt) async {
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';
    const String apiKey = '';

    try {
      String userInfo = '';
      if (currentUser != null) {
        userInfo =
            '사용자 이름은 "${currentUser!.name}", MBTI는 "${currentUser!.mbti}", 생일은 "${currentUser!.birthDate.toIso8601String()}"입니다. ';
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
                  '당신은 감정 분석 어시스턴트입니다. 사용자의 메시지를 읽고 그 감정을 분석한 뒤, 다음 내용을 포함한 자연스러운 문장을 작성하세요.\n\n'
                  '1. 사용자의 이름을 부르며 감정에 공감해 주세요.\n'
                  '2. MBTI 성격유형을 참고하여, T 성향은 논리적이고 이성적인 방식으로, F 성향은 따뜻하고 감성적인 방식으로 위로를 건네 주세요.\n'
                  '3. 사용자의 생년월일을 기반으로 나이를 추정한 후, 해당 연령대에 맞는 음악을 추천해 주세요. 예: 10대는 아이돌, 60대는 트로트, 20~30대는 발라드/인디 등.\n'
                  '4. 추천 음악은 감정과 상황에 어울려야 하며, 사용자가 직접 요청하지 않아도 무조건 마지막에 포함시켜 주세요.\n'
                  '5. 사용자가 사용하는 언어에 맞춰 그 나라의 곡을 추천하세요.\n'
                  '6. 답변에 위 지침이나 프롬프트의 문장은 절대 포함하지 마세요.\n\n'
                  'EX) 사용자이름: 서원 / 생년월일: 2003-03-03 / MBTI: INTP',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );

        if (data.containsKey('choices') &&
            data['choices'] is List &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          return data['choices'][0]['message']['content'];
        } else {
          return 'GPT 응답 형식 오류:\n${json.encode(data)}';
        }
      } else {
        return 'API 오류: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      return '에러 발생: $e';
    }
  }
}
