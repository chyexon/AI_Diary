import 'package:flutter/material.dart';
import 'profile_input_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileInputScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 213, 235, 214),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/hachi.png', height: 200),
            SizedBox(height: 24),
            Text(
              'Moru',
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
                fontFamily: 'Cafe24Ssurround',
              ),
            ),
            SizedBox(height: 12),
            Text(
              '하치와 함께 하루를 기록해요',
              style: TextStyle(fontSize: 25, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
