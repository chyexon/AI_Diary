import 'package:flutter/material.dart';
import 'font_setting_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // 🔹 다크 모드 (기능 없음)
          ListTile(
            title: const Text('다크 모드'),
            trailing: ElevatedButton(
              onPressed: () {
                // 다크모드 설정 기능은 나중에
              },
              child: const Text('ON / OFF'),
            ),
          ),

          // 🔹 폰트 설정 화면으로 이동
          ListTile(
            title: const Text('폰트 설정'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FontSettingScreen()),
              );
            },
          ),

          // 🔹 비밀번호 설정 (아직 없음)
          ListTile(
            title: const Text('비밀번호 설정'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 나중에 PasswordSettingScreen으로 연결 가능
            },
          ),
          ListTile(
            title: const Text('정보 수정'),
            //trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
