import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileInputScreen extends StatefulWidget {
  @override
  _ProfileInputScreenState createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mbtiController = TextEditingController();

  String? selectedYear = '2000';
  String? selectedMonth = '1';
  String? selectedDay = '1';

  List<String> years = List.generate(100, (index) => (1925 + index).toString());
  List<String> months = List.generate(12, (index) => (index + 1).toString());
  List<String> days = List.generate(31, (index) => (index + 1).toString());

  Future<void> saveProfile(String name, String mbti, String birthDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('mbti', mbti);
    await prefs.setString('birthDate', birthDate);

    currentUser = UserProfile(
      name: name,
      mbti: mbti,
      birthDate: DateTime.parse(birthDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프로필 입력',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('생일'),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedYear,
                  items:
                      years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text('$year년'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value;
                    });
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedMonth,
                  items:
                      months.map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text('$month월'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value;
                    });
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedDay,
                  items:
                      days.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text('$day일'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('이름'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text('MBTI'),
            TextField(
              controller: mbtiController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final mbti = mbtiController.text.trim().toUpperCase();

                  final validMbtiList = [
                    'INTJ',
                    'INTP',
                    'ENTJ',
                    'ENTP',
                    'INFJ',
                    'INFP',
                    'ENFJ',
                    'ENFP',
                    'ISTJ',
                    'ISFJ',
                    'ESTJ',
                    'ESFJ',
                    'ISTP',
                    'ISFP',
                    'ESTP',
                    'ESFP',
                  ];

                  if (nameController.text.isEmpty ||
                      mbtiController.text.isEmpty ||
                      selectedYear == null ||
                      selectedMonth == null ||
                      selectedDay == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('모든 항목을 입력하세요!')),
                    );
                    return;
                  }

                  if (!validMbtiList.contains(mbti)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('올바른 MBTI 유형을 입력하세요.')),
                    );
                    return;
                  }

                  final birthDate =
                      '$selectedYear-${selectedMonth!.padLeft(2, '0')}-${selectedDay!.padLeft(2, '0')}';

                  await saveProfile(name, mbti, birthDate);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarScreen()),
                  );
                },
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
