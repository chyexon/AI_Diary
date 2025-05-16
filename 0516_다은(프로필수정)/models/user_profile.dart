class UserProfile {
  final String name;
  final String mbti;
  final DateTime birthDate;

  UserProfile({
    required this.name,
    required this.mbti,
    required this.birthDate,
  });
}

UserProfile? currentUser;
String detectedEmotion = '';
String mbtiDescriptionFromGPT = '';