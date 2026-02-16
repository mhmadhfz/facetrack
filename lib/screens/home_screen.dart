import 'package:flutter/material.dart';
import 'face_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FaceTrack Dashboard"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face, size: 80),
            const SizedBox(height: 20),
            const Text("Welcome to FaceTrack!", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaceScanScreen(),
                  ),
                );
              },
              child: const Text("Start Face Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
