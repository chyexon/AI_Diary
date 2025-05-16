import 'package:flutter/material.dart';
import 'font_notifier.dart';
import 'screens/profile_input_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/chatgpt.dart'; 
import 'screens/gpt_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ApiService gptService = ApiService();

  @override
  Widget build(BuildContext context) {
     return ValueListenableBuilder<String>(
      valueListenable: fontNotifier,
      builder: (context, font, _) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: font,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: BorderSide(color: Colors.black),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
      ),
      debugShowCheckedModeBanner: false,
      home: ProfileInputScreen(),
        );
      },
    );
  }
}