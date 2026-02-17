import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = AttendanceService.getRecords();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        centerTitle: true,
      ),
      body: records.isEmpty
          ? const Center(
              child: Text(
                "No attendance records yet.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final attendance = records[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: const Text("Attendance Marked"),
                    subtitle: Text(attendance.time.toString()),
                  ),
                );
              },
            ),
    );
  }
}
