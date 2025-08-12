import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visiting_card_app/Screens/dashboard/dashboard_screen.dart';
import 'package:visiting_card_app/Screens/sign_up_screen.dart';
import 'package:visiting_card_app/utils/stream_builder.dart';
import 'create_card_screen.dart';

SharedPreferences? pref;

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    initData();
  }

  void initData() async {
    pref = await SharedPreferences.getInstance();
    checkRoute();
  }

  checkRoute() async {
    final isLogin = await pref?.getBool('login');

    if (isLogin == true) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
      StreamUtil.dashboardBottomSubject.add(0);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB39DDB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_2_rounded, size: 90, color: Colors.white),
            SizedBox(height: 20),
            Text('Welcome to NFC / QR Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
