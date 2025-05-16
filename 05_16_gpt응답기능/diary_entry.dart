class DiaryEntry {
  final String input;
  final String response;

  DiaryEntry({required this.input, required this.response});

  Map<String, dynamic> toJson() => {
        'input': input,
        'response': response,
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      DiaryEntry(
        input: json['input'],
        response: json['response'],
      );
}