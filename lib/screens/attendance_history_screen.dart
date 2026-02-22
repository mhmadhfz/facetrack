import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<dynamic> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final data = await ApiService.getAttendanceHistory();

      setState(() {
        records = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? const Center(
              child: Text(
                "No attendance records found.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final now = DateTime.now();

                // ✅ Format Check In Time
                final checkInTime = DateFormat(
                  "dd MMM yyyy, hh:mm a",
                ).format(DateTime.parse(record["created_at"]).toLocal());

                // ✅ Format Check Out Time (if exists)
                String checkOutTime = "Not yet";

                if (record["checked_out_at"] != null) {
                  checkOutTime = DateFormat(
                    "dd MMM yyyy, hh:mm a",
                  ).format(DateTime.parse(record["checked_out_at"]));
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Attendance Record",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ✅ Check In Display
                        Row(
                          children: [
                            const Icon(Icons.login, size: 20),
                            const SizedBox(width: 8),
                            Text("Check In: $checkInTime"),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ✅ Check Out Display
                        Row(
                          children: [
                            const Icon(Icons.logout, size: 20),
                            const SizedBox(width: 8),
                            Text("Check Out: $checkOutTime"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
