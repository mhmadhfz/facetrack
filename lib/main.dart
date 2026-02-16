import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FaceTrackApp());
}

class FaceTrackApp extends StatelessWidget {
  const FaceTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FaceTrack',
      home: const LoginScreen(),
    );
  }
}
