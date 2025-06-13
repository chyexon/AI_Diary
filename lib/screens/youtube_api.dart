import 'package:http/http.dart' as http;
import 'dart:convert';

/// 불용어 집합
final stopwords = {
  '나', '내', '그', '저', '오늘', '있다', '했다', '이다',
  '너', '우리', '너희', '자기', '그녀', '그들', '누구', '뭐',
  '은', '는', '이', '가', '을', '를', '에', '에서', '에게', '보다',
  '의', '와', '과', '도', '만', '까지', '부터', '하고', '처럼', '보다',
  '지만', '해서', '하고', '하며', '으로', '니까', '려고', '니까요',
  '있다', '없다', '하다', '되다', '됐다', '아니다', '같다',
  '된다', '싶다', '보이다', '느끼다', '생각하다', '말하다',
  '오늘', '어제', '내일', '이번', '지난', '다음', '항상', '매일', '가끔',
  '정말', '진짜', '그냥', '너무', '좀', '많이', '조금', '항상', '계속',
};

/// 1단계~3단계에서 쓰는 문장 분석 함수 (상위 2개 키워드 추출)
List<String> analyzeSentences(String diary, Set<String> stopwords) {
  final sentences = diary
      .split(RegExp(r'[.!?。\n]'))
      .where((s) => s.trim().isNotEmpty)
      .toList();

  final regex = RegExp(
    r'([가-힣a-zA-Z0-9]+)(은|는|이|가|을|를|에|에서|도|만|으로|로|와|과|하고|랑|보다|까지|부터|밖에|마저|조차|이나|나|든지|이든지|커녕|마다|께서|께|한테|한테서|에다가|에다|이고|이며)'
  );

  final keywords = <String, int>{};

  for (var sentence in sentences) {
    final matches = regex.allMatches(sentence.trim());
    for (var match in matches) {
      final word = match.group(1);
      if (word != null && word.length > 1 && !stopwords.contains(word)) {
        keywords[word] = (keywords[word] ?? 0) + 1;
      }
    }
  }

  final sorted = keywords.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(2).map((e) => e.key).toList();
}

/// 4단계에서 사용할 첫 문장 첫 목적어 추출 함수
String extractFirstObjectFromFirstSentence(String diary) {
  final sentences = diary
      .split(RegExp(r'[.!?。\n]'))
      .where((s) => s.trim().isNotEmpty)
      .toList();

  if (sentences.isEmpty) return 'playlist';

  final firstSentence = sentences.first.trim();

  final regex = RegExp(
    r'([가-힣a-zA-Z0-9]+)(을|를)'
  );

  final match = regex.firstMatch(firstSentence);
  if (match != null) {
    final obj = match.group(1);
    if (obj != null && obj.length > 1 && !stopwords.contains(obj)) {
      return '$obj playlist';
    }
  }

  // 목적어가 없으면 그냥 첫 문장에 playlist 붙임
  return '$firstSentence playlist';
}

/// 단계별로 검색어 추출 함수
String extractQueryFromDiary(String diary, int step) {
  if (step == 4) {
    return extractFirstObjectFromFirstSentence(diary);
  } else {
    final keywords = analyzeSentences(diary, stopwords);
    if (keywords.isEmpty) {
      final sentences = diary
          .split(RegExp(r'[.!?。\n]'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      if (sentences.isEmpty) return 'playlist';

      final firstSentence = sentences.first.trim();

      final words = firstSentence.split(RegExp(r'\s+'));
      for (var word in words) {
        if (word.trim().isNotEmpty && !stopwords.contains(word)) {
          return '$word playlist';
        }
      }
      return '$firstSentence playlist';
    }
    return '${keywords.join(' ')} playlist';
  }
}

/// ISO 8601 duration 문자열을 초 단위로 변환하는 함수
int parseDurationToSeconds(String duration) {
  final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(duration);
  if (match == null) return 0;

  final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
  final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
  final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

  return hours * 3600 + minutes * 60 + seconds;
}

/// 3단계 조건 이후 4단계까지 자동으로 넘어가는 유튜브 검색 함수
Future<List<Map<String, String>>> searchYouTube(String diary, {int step = 1}) async {
  final apiKey = 'AIzaSyB3wZzIzxCoFqhQjWw8pEo8xR6H3bjhqXc'; // 본인 유튜브 API 키 입력
  final query = extractQueryFromDiary(diary, step);

  final searchUrl = Uri.parse(
    'https://www.googleapis.com/youtube/v3/search'
    '?part=snippet'
    '&type=video'
    '&maxResults=10'
    '&q=${Uri.encodeComponent(query)}'
    '&key=$apiKey',
  );

  final searchResponse = await http.get(searchUrl);
  if (searchResponse.statusCode != 200) {
    throw Exception('검색 API 실패: ${searchResponse.statusCode}');
  }

  final searchData = json.decode(searchResponse.body);
  final items = searchData['items'] as List;

  if (items.isEmpty) {
    // 검색 결과 없으면 다음 단계로 자동 이동
    if (step < 4) {
      return await searchYouTube(diary, step: step + 1);
    } else {
      return [];
    }
  }

  final videoIds = items.map((item) => item['id']['videoId']).join(',');

  final videoUrl = Uri.parse(
    'https://www.googleapis.com/youtube/v3/videos'
    '?part=snippet,statistics,contentDetails'
    '&id=$videoIds'
    '&key=$apiKey',
  );

  final videoResponse = await http.get(videoUrl);
  if (videoResponse.statusCode != 200) {
    throw Exception('비디오 정보 요청 실패: ${videoResponse.statusCode}');
  }

  final videoData = json.decode(videoResponse.body);
  final videoItems = videoData['items'] as List;

  var results = <Map<String, String>>[];

  // 단계별 조건에 따라 필터링
  if (step == 1) {
    // 조회수 >= 500000, 카테고리 10(음악), 영상 길이 3분 이상
    for (var video in videoItems) {
      final categoryId = video['snippet']['categoryId'];
      final viewCount = int.tryParse(video['statistics']['viewCount'] ?? '0') ?? 0;
      final duration = video['contentDetails']['duration'];
      final durationSeconds = parseDurationToSeconds(duration);

      if (categoryId == '10' && viewCount >= 500000 && durationSeconds >= 180) {
        results.add({
          'id': video['id'],
          'title': video['snippet']['title'],
          'thumbnail': video['snippet']['thumbnails']['default']['url'],
          'views': viewCount.toString(),
          'duration': duration,
        });
      }
    }
  } else if (step == 2) {
    // 조회수 >= 500000, 카테고리 10, 영상 길이 조건 제거
    for (var video in videoItems) {
      final categoryId = video['snippet']['categoryId'];
      final viewCount = int.tryParse(video['statistics']['viewCount'] ?? '0') ?? 0;

      if (categoryId == '10' && viewCount >= 500000) {
        results.add({
          'id': video['id'],
          'title': video['snippet']['title'],
          'thumbnail': video['snippet']['thumbnails']['default']['url'],
          'views': viewCount.toString(),
          'duration': video['contentDetails']['duration'],
        });
      }
    }
  } else if (step == 3) {
    // 조회수 조건 제거, 카테고리 10 유지, 영상 길이 조건 제거
    for (var video in videoItems) {
      final categoryId = video['snippet']['categoryId'];

      if (categoryId == '10') {
        final viewCount = int.tryParse(video['statistics']['viewCount'] ?? '0') ?? 0;
        results.add({
          'id': video['id'],
          'title': video['snippet']['title'],
          'thumbnail': video['snippet']['thumbnails']['default']['url'],
          'views': viewCount.toString(),
          'duration': video['contentDetails']['duration'],
        });
      }
    }
  } else if (step == 4) {
  // 4단계는 조회수 10,000 이상 필터 적용
  for (var video in videoItems) {
    final viewCount = int.tryParse(video['statistics']['viewCount'] ?? '0') ?? 0;
    if (viewCount >= 10000) {
      results.add({
        'id': video['id'],
        'title': video['snippet']['title'],
        'thumbnail': video['snippet']['thumbnails']['default']['url'],
        'views': viewCount.toString(),
        'duration': video['contentDetails']['duration'],
      });
    }
  }
}

  if (results.isNotEmpty) {
    return results;
  } else {
    // 4단계가 아니면 다음 단계로 재귀 호출
    if (step < 4) {
      return await searchYouTube(diary, step: step + 1);
    } else {
      // 4단계에서도 없으면 빈 리스트 반환
      return [];
    }
  }
}
