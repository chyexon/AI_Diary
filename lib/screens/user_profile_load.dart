import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';

class UserProfile {
  final String name;
  final int age;

  UserProfile({
    required this.name,
    required this.age,
  });

  // JSON → UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      age: json['age'],
    );
  }

  // UserProfile → JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }
}

Future<void> saveUserToPrefs(String id, String password, UserProfile user) async {
  final prefs = await SharedPreferences.getInstance();
  final userKey = '$id|$password';
  prefs.setString(userKey, jsonEncode(user.toJson()));
}

Future<UserProfile?> loadUserFromPrefs(String id, String password) async {
  final prefs = await SharedPreferences.getInstance();
  final userKey = '$id|$password';
  final jsonString = prefs.getString(userKey);
  if (jsonString == null) return null;

  return UserProfile.fromJson(jsonDecode(jsonString));
}
