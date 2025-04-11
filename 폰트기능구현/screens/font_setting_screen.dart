import 'package:flutter/material.dart';
import '../font_notifier.dart';

class FontSettingScreen extends StatefulWidget {
  @override
  _FontSettingScreenState createState() => _FontSettingScreenState();
}

class _FontSettingScreenState extends State<FontSettingScreen> {
  String selectedFont = fontNotifier.value;

  // 🔹 pubspec.yaml에 등록된 폰트 이름과 맞추기
  final Map<String, String> fontExamples = {
    'CookieRun': '쿠키런',
    'Bazzi': '배찌체',
    'Maplestory_Light': '메이플스토리',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('폰트 설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('아래에서 원하는 폰트를 선택하세요:'),
          const SizedBox(height: 16),
          ...fontExamples.entries.map((entry) {
            final fontName = entry.key;
            final exampleText = entry.value;
            return RadioListTile<String>(
              title: Text(
                exampleText,
                style: TextStyle(fontFamily: fontName),
              ),
              value: fontName,
              groupValue: selectedFont,
              onChanged: (value) {
                setState(() {
                  selectedFont = value!;
                });
              },
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              fontNotifier.changeFont(selectedFont);
              Navigator.pop(context); // 설정 후 이전 화면으로
            },
            child: const Text('폰트 적용'),
          ),
        ],
      ),
    );
  }
}


