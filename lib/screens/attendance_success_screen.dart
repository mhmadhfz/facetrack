import 'package:flutter/material.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  final DateTime time;

  const AttendanceSuccessScreen({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Marked")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100),
              const SizedBox(height: 20),
              const Text(
                "Attendance Successful!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text("Time: ${time.toString()}", textAlign: TextAlign.center),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back to Scan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
