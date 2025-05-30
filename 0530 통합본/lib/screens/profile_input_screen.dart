import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../widgets/custom_dropdown_button.dart';

class ProfileInputScreen extends StatefulWidget {
  @override
  _ProfileInputScreenState createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final TextEditingController nameController = TextEditingController();

  String? selectedYear = '2000';
  String? selectedMonth = '1';
  String? selectedDay = '1';
  String? selectedMbti;

  List<String> years = List.generate(100, (index) => (1925 + index).toString());
  List<String> months = List.generate(12, (index) => (index + 1).toString());
  List<String> days = List.generate(31, (index) => (index + 1).toString());

  final validMbtiList = [
    'INTJ',
    'INTP',
    'INFJ',
    'INFP',
    'ISTJ',
    'ISFJ',
    'ISTP',
    'ISFP',
    'ENTJ',
    'ENTP',
    'ENFJ',
    'ENFP',
    'ESTJ',
    'ESFJ',
    'ESTP',
    'ESFP',
  ];

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('생일'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: CustomDropdownButton(
                      items: years,
                      selectedValue: selectedYear,
                      label: '연도 선택',
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: CustomDropdownButton(
                      items: months,
                      selectedValue: selectedMonth,
                      label: '월 선택',
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: CustomDropdownButton(
                      items: days,
                      selectedValue: selectedDay,
                      label: '일 선택',
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('이름'),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text('MBTI'),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                ),
                itemCount: validMbtiList.length,
                itemBuilder: (context, index) {
                  final mbti = validMbtiList[index];
                  final isSelected = mbti == selectedMbti;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMbti = mbti;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFDCEFB8) : Colors.white,
                        border: Border.all(
                          color:
                              isSelected
                                  ? Color(0xFF33691E)
                                  : Color(0xFFDCEFB8),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mbti,
                        style: TextStyle(
                          color:
                              isSelected ? Color(0xFF33691E) : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty ||
                        selectedMbti == null ||
                        selectedYear == null ||
                        selectedMonth == null ||
                        selectedDay == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('모든 항목을 입력하세요!')),
                      );
                      return;
                    }

                    final birthDate =
                        '$selectedYear-${selectedMonth!.padLeft(2, '0')}-${selectedDay!.padLeft(2, '0')}';

                    await saveProfile(name, selectedMbti!, birthDate);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDCEFB8),
                    foregroundColor: const Color(0xFF33691E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
