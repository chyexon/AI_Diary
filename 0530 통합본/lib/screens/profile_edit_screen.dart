import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String name = '';
  String birthDate = '';
  String mbti = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      birthDate = prefs.getString('birthDate') ?? '';
      mbti = prefs.getString('mbti') ?? '';
      password = prefs.getString('password') ?? '';
    });
  }

  Future<void> _saveProfile({
    String? newName,
    String? newBirthDate,
    String? newMbti,
    String? newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (newName != null) {
      await prefs.setString('name', newName);
      setState(() {
        name = newName;
      });
    }
    if (newBirthDate != null) {
      await prefs.setString('birthDate', newBirthDate);
      setState(() {
        birthDate = newBirthDate;
      });
    }
    if (newMbti != null) {
      await prefs.setString('mbti', newMbti);
      setState(() {
        mbti = newMbti;
      });
    }
    if (newPassword != null) {
      await prefs.setString('password', newPassword);
      setState(() {
        password = newPassword;
      });
    }
  }

  String getFormattedBirthDate(String birthDate) {
    if (birthDate.isEmpty) return '';
    final parts = birthDate.split('-');
    if (parts.length != 3) return birthDate;
    return '${parts[0]}년 ${int.parse(parts[1])}월 ${int.parse(parts[2])}일';
  }

  Future<void> _showEditDialog({
    required String title,
    required String currentValue,
    required Function(String) onSave,
    String hintText = '',
  }) async {
    final controller = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$title 변경'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: hintText),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newValue = controller.text.trim();
                  if (newValue.isEmpty) return;
                  onSave(newValue);
                  Navigator.pop(context);
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  Future<void> _showBirthDatePicker() async {
    String selectedYear = '2000';
    String selectedMonth = '1';
    String selectedDay = '1';

    if (birthDate.isNotEmpty) {
      final parts = birthDate.split('-');
      if (parts.length == 3) {
        selectedYear = parts[0];
        selectedMonth = parts[1].replaceFirst('0', '');
        selectedDay = parts[2].replaceFirst('0', '');
      }
    }

    final years = List.generate(100, (i) => (1925 + i).toString());
    final months = List.generate(12, (i) => (i + 1).toString());
    final days = List.generate(31, (i) => (i + 1).toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('생일 변경'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedYear,
                    items:
                        years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text('$year년'),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() {
                          selectedYear = val;
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedMonth,
                    items:
                        months
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text('$month월'),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() {
                          selectedMonth = val;
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedDay,
                    items:
                        days
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text('$day일'),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() {
                          selectedDay = val;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final formattedDate =
                    '$selectedYear-${selectedMonth.padLeft(2, '0')}-${selectedDay.padLeft(2, '0')}';

                if (DateTime.tryParse(formattedDate) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('유효한 날짜를 선택하세요')),
                  );
                  return;
                }

                _saveProfile(newBirthDate: formattedDate);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보 변경')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('이름: $name'),
              trailing: ElevatedButton(
                onPressed: () {
                  _showEditDialog(
                    title: '이름',
                    currentValue: name,
                    onSave: (val) => _saveProfile(newName: val),
                    hintText: '이름을 입력하세요',
                  );
                },
                child: const Text('변경'),
              ),
            ),
            ListTile(
              title: Text('생일: ${getFormattedBirthDate(birthDate)}'),
              trailing: ElevatedButton(
                onPressed: _showBirthDatePicker,
                child: const Text('변경'),
              ),
            ),
            ListTile(
              title: Text('MBTI: $mbti'),
              trailing: ElevatedButton(
                onPressed: () {
                  _showEditDialog(
                    title: 'MBTI',
                    currentValue: mbti,
                    onSave: (val) {
                      final valUpper = val.toUpperCase();
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
                      if (!validMbtiList.contains(valUpper)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('올바른 MBTI 유형을 입력하세요.')),
                        );
                        return;
                      }
                      _saveProfile(newMbti: valUpper);
                    },
                    hintText: '예: INFJ',
                  );
                },
                child: const Text('변경'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
