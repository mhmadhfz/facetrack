import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProfileService {
  static const String baseUrl =
      "http://192.168.0.108/facetrack_backend/public/api";

  // ✅ Get Profile
  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["user"];
    } else {
      throw Exception("Failed to fetch profile: ${response.body}");
    }
  }

  // ✅ Update Profile
  static Future<bool> updateProfile(
    String name,
    String password,
    String confirmPassword,
  ) async {
    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "password": password.isEmpty ? null : password,
        "password_confirmation": confirmPassword.isEmpty
            ? null
            : confirmPassword,
      }),
    );

    return response.statusCode == 200;
  }
}
