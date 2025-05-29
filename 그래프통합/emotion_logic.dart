import '../screens/chatgpt.dart';
import '../screens/emotion_storage.dart';
import '../screens/chatgpt.dart';

class EmotionLogic {
  /// GPT로 감정 분석 후 Map 저장
  static Future<Map<String, dynamic>> getAndSaveEmotion(String prompt) async {
    final apiService = ApiService();

    Map<String, dynamic> result = await apiService.getGPTResponse(prompt);

    double score = result['score'] ?? 0.0;
    int intScore = (score * 100).round();

    await EmotionStorage.saveEmotionScore(intScore);
    await EmotionStorage.saveEmotionMap(result); // 수정: jsonEncode 제거

    return {
      'response': result['feedback'],
      'emotionScore': intScore,
      'keywords': result['keywords'],
      'timestamp': result['timestamp'],
    };
  }

  static Future<List<int>> loadEmotionScores() async {
    return await EmotionStorage.loadEmotionScoreList();
  }

  static Future<int?> loadLatestEmotionScore() async {
    return await EmotionStorage.loadEmotionScore();
  }

  static Future<List<Map<String, dynamic>>> loadEmotionMaps() async {
    return await EmotionStorage.loadEmotionMapList(); // 수정: jsonDecode 제거
  }

  static Future<void> resetScores() async {
    await EmotionStorage.deleteEmotionScores();
  }
}
