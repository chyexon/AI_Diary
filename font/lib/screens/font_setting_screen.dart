import 'package:flutter/material.dart';
import '../font_notifier.dart';

class FontSettingScreen extends StatefulWidget {
  @override
  _FontSettingScreenState createState() => _FontSettingScreenState();
}

class _FontSettingScreenState extends State<FontSettingScreen> {
  String selectedFont = fontNotifier.value;
  double fontSize = fontSizeNotifier.value;

  final Map<String, String> fontExamples = {
    'Gothic': '고딕체',
    'Myungjo': '명조체',
    'CookieRun': '쿠키런',
    'Bazzi': '배찌체',
    'Maplestory_Light': '메이플스토리',
    'Highschool': '고딩체',
    'BMYEONSUNG': '배민 연성체',
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
                style: TextStyle(fontFamily: fontName, fontSize: 18),
              ),
              value: fontName,
              groupValue: selectedFont,
              onChanged: (value) {
                setState(() {
                  selectedFont = value!;
                  fontSize = fontSizeDefaults[selectedFont] ?? 14.0;
                });
              },
            );
          }),
          const SizedBox(height: 20),
          const Text('폰트 크기 조절:'),
          Slider(
            value: fontSize,
            min: 10,
            max: 30,
            divisions: 20,
            label: fontSize.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                fontSize = value;
              });
            },
          ),
          const SizedBox(height: 20),
          const Text('미리보기:', style: TextStyle(fontSize: 16)),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '이것은 미리보기 문장입니다.',
              style: TextStyle(fontFamily: selectedFont, fontSize: fontSize),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              fontNotifier.changeFont(selectedFont);
              fontSizeNotifier.value = fontSize;
              Navigator.pop(context);
            },
            child: const Text('폰트 적용'),
          ),
        ],
      ),
    );
  }
}