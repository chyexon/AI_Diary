final List<String> dailyQuestions = [
  "오늘 나를 미소 짓게 한 일은 무엇인가요?",
  "잠깐 스친 친절로 하루가 부드러워진 순간이 있나요?",
  "오늘 나 자신에게 해주고 싶은 칭찬은 무엇인가요?",
  "오늘 가장 감사했던 일은 무엇인가요?",
  "오늘 하루 중 가장 편안했던 순간은 언제였나요?",
  "오늘 느낀 감정을 한 단어로 표현한다면 무엇인가요?",
  "내일은 오늘보다 더 나은 하루가 되기 위해 무엇을 할 수 있을까요?",
  "오늘 만난 사람 중 가장 인상 깊었던 사람은 누구였나요?",
  "오늘 나를 힘들게 했던 일은 무엇이고, 어떻게 극복했나요?",
  "오늘 스스로에게 해주고 싶은 한마디는 무엇인가요?",
  // 필요에 따라 질문을 더 추가할 수 있습니다.
];

/// 오늘의 질문을 반환합니다.
/// 기본적으로 날짜를 기준으로 순환하면서 질문을 제공합니다.
String getTodayQuestion(DateTime selectedDate) {
  //final today = DateTime.now();
  final startDate = DateTime(2025, 1, 1); // 기준일 (시작일)
  final differenceInDays = selectedDate.difference(startDate).inDays;
  final index = differenceInDays % dailyQuestions.length;
  return dailyQuestions[index];
}
