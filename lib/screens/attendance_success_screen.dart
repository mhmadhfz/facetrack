import 'package:facetrack/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  final DateTime time;

  const AttendanceSuccessScreen({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    // ✅ Format time nicely with AM/PM
    final formattedTime = DateFormat("dd MMM yyyy, h:mm a").format(time);

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Marked")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),

              const SizedBox(height: 20),

              const Text(
                "Attendance Successful!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // ✅ Display formatted time
              Text(
                "Time: $formattedTime",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
