import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  static Future<String?> uploadProfilePhoto(File file) async {
    final token = await AuthService.getToken();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/profile/photo"),
    );

    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";

    request.files.add(await http.MultipartFile.fromPath("photo", file.path));

    final response = await request.send();

    final respStr = await response.stream.bytesToString();

    print("UPLOAD STATUS: ${response.statusCode}");
    print("UPLOAD BODY: $respStr");

    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);
      return data["photo_url"];
    }

    return null;
  }

  static Future<Map<String, dynamic>> fetchStats() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/profile/stats"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch stats: ${response.body}");
    }
  }
}
