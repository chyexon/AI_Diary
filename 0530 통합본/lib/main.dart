import 'package:flutter/material.dart';
import 'font_notifier.dart';
import 'screens/profile_input_screen.dart';
import 'screens/chatgpt.dart';
import 'screens/chatgpt.dart';
import 'screens/emotion_storage.dart';
import 'screens/graph_screen.dart';
import 'screens/emotion_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화 위해 필요
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // 저장소 초기화 (잠시 사용 후 삭제 권장)
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
              backgroundColor: Color(0xFFE6F8D5),
              foregroundColor: Color(0xFF689F38),
              elevation: 0,
              titleTextStyle: TextStyle(
                fontFamily: font,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF689F38),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDCEFB8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDCEFB8)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF689F38)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFF689F38),
              selectionColor: Color(0xFFDCEFB8),
              selectionHandleColor: Color(0xFF689F38),
            ),
            cardTheme: CardTheme(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              margin: const EdgeInsets.all(12),
            ),
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(Colors.white),
              radius: Radius.circular(8),
              thickness: MaterialStateProperty.all<double>(6.0),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: ProfileInputScreen(),
        );
      },
    );
  }
}
