import 'package:flutter/material.dart';
import 'font_notifier.dart';
import 'screens/profile_input_screen.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
  valueListenable: fontNotifier,
  builder: (context, font, _) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: font, // 폰트 적용!
      ),
      home: CalendarScreen(), // 네 첫 화면
    );
  },
);
  }
}
