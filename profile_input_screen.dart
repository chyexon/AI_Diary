import 'package:flutter/material.dart';
import 'calendar_screen.dart'; // 캘린더 화면 import

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 입력')),
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
                onPressed: () {
                  // 모든 필드가 채워졌는지 확인
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

                  // 캘린더 화면으로 이동
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
