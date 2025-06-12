import 'package:http/http.dart' as http;
import 'dart:convert';

/// 1. 일기에서 키워드를 추출하는 함수
String extractQueryFromDiary(String diary) {
  // 문장 단위로 분리 (마침표, 느낌표, 물음표, 줄바꿈 기준)
  final sentences = diary
      .split(RegExp(r'[.!?。\n]'))
      .where((s) => s.trim().isNotEmpty)
      .toList();

  if (sentences.isEmpty) return diary;

  final firstSentence = sentences.first.trim();

  // 확장된 조사 리스트 기반 정규표현식
  final regex = RegExp(
    r'([가-힣a-zA-Z0-9]+)(은|는|이|가|을|를|에|에서|도|만|으로|로|와|과|하고|랑|보다|까지|부터|밖에|마저|조차|이나|나|든지|이든지|커녕|마다|께서|께|한테|한테서|에다가|에다|이고|이며)'
  );

  final matches = regex.allMatches(firstSentence);

  final keywords = <String>{};
  for (var match in matches) {
    final word = match.group(1);
    if (word != null && word.length > 1) {
      keywords.add(word);
      if (keywords.length == 2) break;
    }
  }

  // 키워드가 없다면 첫 문장 띄어쓰기 기준 첫 단어만 사용
  if (keywords.isEmpty) {
    final words = firstSentence.split(RegExp(r'\s+'));
    if (words.isNotEmpty) {
      return words.first;
    } else {
      return firstSentence;  // 빈 문장일 경우 대비
    }
  }

  return keywords.join(' ');
}

/// 2. 유튜브 API를 통해 뮤직비디오 검색
Future<List<Map<String, String>>> searchYouTube(String diary) async {
  final apiKey = ''; // 본인의 유튜브 API 키 입력
  final query = extractQueryFromDiary(diary);
  final combinedQuery = '$query 뮤직비디오'; // 'mv'보다 '뮤직비디오'가 정확도 높음

  final url = Uri.parse(
    'https://www.googleapis.com/youtube/v3/search'
    '?part=snippet'
    '&type=video'
    '&maxResults=1'
    '&q=$combinedQuery'
    '&key=$apiKey'
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final items = data['items'] as List;

    if (items.isEmpty) return [];

    return items.map<Map<String, String>>((item) {
      return {
        'id': item['id']['videoId'],
        'title': item['snippet']['title'],
        'thumbnail': item['snippet']['thumbnails']['default']['url'],
      };
    }).toList();
  } else {
    throw Exception('유튜브 검색 실패: ${response.statusCode}');
  }
}
