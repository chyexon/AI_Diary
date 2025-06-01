import 'package:flutter/material.dart';
import '../font_notifier.dart';

class FontSettingScreen extends StatefulWidget {
  @override
  _FontSettingScreenState createState() => _FontSettingScreenState();
}

class _FontSettingScreenState extends State<FontSettingScreen> {
  String selectedFont = fontNotifier.value;

  final Map<String, String> fontExamples = {
    'Gothic' : '고딕체',
    'Myungjo' : '명조체',
    'CookieRun': '쿠키런',
    'Bazzi': '배찌체',
    'Maplestory_Light': '메이플스토리',
    'Highschool': '고딕아니고고딩체',
    'BMYEONSUNG': '배민 연성체',
    'Highlight_pen': '형광펜',
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
              title: Text(exampleText, style: TextStyle(fontFamily: fontName)),
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
              Navigator.pop(context);
            },
            child: const Text('폰트 적용'),
          ),
        ],
      ),
    );
  }
}
