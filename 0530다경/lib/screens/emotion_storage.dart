import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionStorage {
  static const _keyScore = 'emotion_score';
  static const _keyScoreList = 'emotion_score_list';
  static const _keyMapList = 'emotion_map_list';

  /// 최신 감정 점수 저장
  static Future<void> saveEmotionScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScore, score);

    List<String> list = prefs.getStringList(_keyScoreList) ?? [];
    list.add(score.toString());
    await prefs.setStringList(_keyScoreList, list);
  }

  /// 감정 분석 Map 데이터 저장 (JSON 문자열로 저장)
  static Future<void> saveEmotionMap(Map<String, dynamic> emotionData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyMapList) ?? [];

    String jsonString = jsonEncode(emotionData);
    list.add(jsonString);

    await prefs.setStringList(_keyMapList, list);
  }

  /// 최신 감정 점수 불러오기
  static Future<int?> loadEmotionScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScore);
  }

  /// 감정 점수 리스트 불러오기
  static Future<List<int>> loadEmotionScoreList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyScoreList) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// 감정 분석 Map 리스트 불러오기
  static Future<List<Map<String, dynamic>>> loadEmotionMapList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList(_keyMapList) ?? [];
    return jsonList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  /// 감정 데이터 전체 초기화
  static Future<void> deleteEmotionScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScore);
    await prefs.remove(_keyScoreList);
    await prefs.remove(_keyMapList);
  }
}
