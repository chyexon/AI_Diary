import 'package:flutter/material.dart';
import 'screens/page1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileInputScreen(), // 처음 실행 화면을 ProfileInputScreen으로 설정
    );
  }
}
