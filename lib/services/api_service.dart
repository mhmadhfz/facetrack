import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;

  // ✅ Upload Attendance (Check-in / Check-out)
  static Future<Map<String, dynamic>> markAttendanceWithImage(File file) async {
    final token = await AuthService.getToken();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/attendance"),
    );

    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";

    request.files.add(await http.MultipartFile.fromPath("image", file.path));

    final streamedResponse = await request.send();

    final responseBody = await streamedResponse.stream.bytesToString();

    print("UPLOAD STATUS: ${streamedResponse.statusCode}");
    print("UPLOAD BODY: $responseBody");

    if (streamedResponse.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception("Upload failed: $responseBody");
    }
  }

  // ✅ Fetch Attendance History
  static Future<List<dynamic>> getAttendanceHistory() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/attendance/history"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print("HISTORY STATUS: ${response.statusCode}");
    print("HISTORY BODY: ${response.body}");
    print("TOKEN USED: $token");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load history: ${response.body}");
    }
  }

  // ✅ Get Today's Attendance Status
  static Future<String> getTodayAttendanceStatus() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/attendance/status"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"];
    } else {
      throw Exception("Failed to load status");
    }
  }

  // ✅ Simple attendance without image
  static Future<Map<String, dynamic>> markAttendance() async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/attendance"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Attendance failed: ${response.body}");
    }
  }
}
