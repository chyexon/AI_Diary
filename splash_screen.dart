import 'package:flutter/material.dart';
import '../screens/profile_input_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileInputScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6F8D5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              "고슴도치",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF689F38),
              ),
            ),
            SizedBox(height: 10),
            Image.asset(
              'assets/images/dochi.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Color(0xFF689F38),
            ),
          ],
        ),
      ),
    );
  }
}