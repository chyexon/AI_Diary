import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionStorage {
  // 날짜 → 점수 맵을 저장할 SharedPreferences 키
  static const _keyDateScoreMap = 'emotion_date_score_map';

  /// 특정 날짜(date)에 대한 감정 점수(score)를 저장합니다.
  /// 내부적으로는 전체 맵을 불러와서 해당 날짜 키를 덮어쓴 뒤, 다시 저장합니다.
  static Future<void> saveEmotionScore({
    required DateTime date,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // 1) 기존에 저장된 JSON 문자열을 불러와 Map<String, dynamic>으로 디코딩
    final String? raw = prefs.getString(_keyDateScoreMap);
    Map<String, dynamic> map = {};
    if (raw != null) {
      try {
        map = json.decode(raw) as Map<String, dynamic>;
      } catch (e) {
        // 디코딩에 실패하면 빈 맵으로 시작
        map = {};
      }
    }

    // 2) DateTime을 “yyyy-MM-dd” 포맷 문자열로 변환하여, 맵에 덮어쓰기
    final String dateKey = _formatDate(date); // 예: “2025-05-04”
    map[dateKey] = score;

    // 3) 다시 JSON 문자열로 인코딩하여 SharedPreferences에 저장
    final String encoded = json.encode(map);
    await prefs.setString(_keyDateScoreMap, encoded);
  }

  /// SharedPreferences에서 전체 “날짜 → 점수” 맵을 불러와서
  /// Map<DateTime, int> 형태로 반환합니다.
  /// 저장된 값이 없으면 빈 맵을 반환합니다.
  static Future<Map<DateTime, int>> loadEmotionScoreMap() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_keyDateScoreMap);
    if (raw == null) {
      return {};
    }

    Map<DateTime, int> result = {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        // key: “2025-05-04” 형식의 문자열
        // value: int (점수) 혹은 숫자 타입
        final DateTime? dt = _parseDate(key);
        if (dt != null && value is num) {
          result[dt] = value.toInt();
        }
      });
    } catch (e) {
      // 파싱에 실패하면 빈 맵 반환
      result = {};
    }
    return result;
  }

  /// 저장된 모든 감정 점수 정보를 삭제합니다.
  static Future<void> deleteEmotionScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDateScoreMap);
  }

  /// DateTime을 “yyyy-MM-dd” 문자열로 바꿔주는 헬퍼 메서드
  static String _formatDate(DateTime date) {
    final String y = date.year.toString();
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// “yyyy-MM-dd” 형태의 문자열을 DateTime으로 파싱합니다.
  /// 파싱에 실패하면 null을 반환합니다.
  static DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return null;
      final int year = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
}