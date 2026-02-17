import 'dart:io';
import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ApiService {
  static const String baseUrl =
      "http://192.168.0.108/facetrack_backend/public/api";

  // ✅ Mark Attendance API (Token Protected)
  static Future<void> markAttendanceWithImage(File imageFile) async {
    final token = await AuthService.getToken();

    final url = Uri.parse("$baseUrl/attendance");

    var request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";

    request.files.add(
      await http.MultipartFile.fromPath("image", imageFile.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      print("✅ Attendance + Image Uploaded Successfully");
    } else {
      throw Exception("Upload failed: ${response.statusCode}");
    }
  }

  // ✅ Fetch Attendance History API (Token Protected)
  static Future<List<dynamic>> getAttendanceHistory() async {
    final token = await AuthService.getToken();

    // Laravel will return history for logged-in user
    final url = Uri.parse("$baseUrl/attendance");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load history: ${response.body}");
    }
  }
}
