import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'screens/splash_screen.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  // Wajib dipanggil jika main() menggunakan async
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase yang BENAR & WAJIB UNTUK WEB
  try {
    await Firebase.initializeApp(
      // Baris di bawah ini adalah KUNCI agar Web Chrome tidak White Screen!
      options: DefaultFirebaseOptions.currentPlatform, 
    );
  } catch (e) {
    debugPrint("Error saat inisialisasi Firebase: $e");
  }

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
Widget build(BuildContext context) {
  return MaterialApp(
    useInheritedMediaQuery: true,
    builder: DevicePreview.appBuilder,
    locale: DevicePreview.locale(context),

    title: 'My Movie List',
    debugShowCheckedModeBanner: false,

    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F141E),
      primaryColor: const Color(0xFFD32F2F),
      fontFamily: 'Inter',
    ),

    home: SplashScreen(),
  );
}
}