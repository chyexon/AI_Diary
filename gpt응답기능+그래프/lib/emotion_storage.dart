//emotion_storage.dart

import 'package:shared_preferences/shared_preferences.dart';

class EmotionStorage {
  static const _keyScore = 'emotion_score';
  static const _keyScoreList = 'emotion_score_list';

  // 기존 저장된 감정 점수 저장
  static Future<void> saveEmotionScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScore, score);
    
    // 감정 점수 리스트에 추가
    List<String> list = prefs.getStringList(_keyScoreList) ?? [];
    list.add(score.toString());
    await prefs.setStringList(_keyScoreList, list);
  }

  // 기존 감정 점수 불러오기
  static Future<int?> loadEmotionScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScore);
  }

  // 감정 점수 리스트 불러오기 (int 리스트로 변환)
  static Future<List<int>> loadEmotionScoreList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyScoreList) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }

  
}

Future<void> deleteEmotionScores() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('emotion_score');
  await prefs.remove('emotion_score_list');
}