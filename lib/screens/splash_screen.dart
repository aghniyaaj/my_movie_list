import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import 'auth/login_screen.dart';
import 'main_nav.dart'; 

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Sekarang MainNav sudah dikenali karena sudah di-import di atas
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', 
              width: 300, 
              height: 300, 
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, size: 100, color: AppColors.primaryRed)
            ),
          ],
        ),
      ),
    );
  }
}