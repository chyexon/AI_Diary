import '../screens/chatgpt.dart';
import '../screens/emotion_storage.dart';

class EmotionLogic {
  /// ChatGPT로부터 감정 분석 결과를 받아 온 뒤,
  /// (1) 날짜(DateTime)와 점수를 함께 저장
  /// (2) 필요한 값을 리턴

  static Future<Map<String, dynamic>> getAndSaveEmotion(String prompt, DateTime selectedDate) async {
    final apiService = ApiService();
    final result = await apiService.getGPTResponse(prompt, selectedDate); // ✅ 날짜 전달

    // 1) result에서 score(double) → int로 변환 (0~100 범위 가정)
    double rawScore = result['score'] ?? 0.0;
    int intScore = (rawScore * 100).round();

    // 2) result['date']를 DateTime으로 파싱
    DateTime parsedDate;
    if (result['date'] is String) {
      parsedDate = DateTime.tryParse(result['date']) ?? selectedDate; // ✅ 실패 시 selectedDate 사용
    } else if (result['date'] is DateTime) {
      parsedDate = result['date'];
    } else {
      parsedDate = selectedDate;
    }

    // 3) 감정 점수 저장
    await EmotionStorage.saveEmotionScore(
      date: parsedDate,
      score: intScore,
    );

    // 4) 결과 리턴
    return {
      'response': result['feedback'],
      'emotionScore': intScore,
      'keywords': result['keywords'],
      'date': parsedDate, // DateTime 형태로 리턴
    };
  }

  /// 전체 “날짜 → 점수” 맵을 불러옵니다.
  static Future<Map<DateTime, int>> loadEmotionScoreMap() async {
    return await EmotionStorage.loadEmotionScoreMap();
  }

  /// 오늘 날짜(DateTime.now() 기준)의 감정 점수만 꺼내줍니다.
  static Future<int?> loadTodayEmotionScore() async {
    final Map<DateTime, int> map = await EmotionStorage.loadEmotionScoreMap();
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return map[today];
  }

  /// 특정 날짜(date)에도 감정 점수가 있는지 확인하고 꺼냅니다.
  static Future<int?> loadEmotionScoreForDate(DateTime date) async {
    final Map<DateTime, int> map = await EmotionStorage.loadEmotionScoreMap();
    final DateTime keyDate = DateTime(date.year, date.month, date.day);
    return map[keyDate];
  }

  /// 저장된 모든 감정 점수를 삭제합니다.
  static Future<void> resetScores() async {
    await EmotionStorage.deleteEmotionScores();
  }
}
