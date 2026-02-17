import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://192.168.0.108:8000/api";

  // ✅ Mark Attendance API (Token Protected)
  static Future<void> markAttendance() async {
    final token = await AuthService.getToken();

    final url = Uri.parse("$baseUrl/attendance");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      print("✅ Attendance saved successfully (Authenticated)");
    } else {
      throw Exception("Failed to mark attendance: ${response.body}");
    }
  }

  // ✅ Fetch Attendance History API (Token Protected)
  static Future<List<dynamic>> getAttendanceHistory() async {
    final token = await AuthService.getToken();

    // Laravel will return history for logged-in user
    final url = Uri.parse("$baseUrl/attendance");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load history: ${response.body}");
    }
  }
}
