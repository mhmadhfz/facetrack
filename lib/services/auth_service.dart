import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      "http://192.168.0.108/facetrack_backend/public/api";
  // ⚠️ Replace with your PC IP

  // ✅ Login Function
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      debugPrint("LOGIN STATUS: ${response.statusCode}");
      debugPrint("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data["token"];
        final userId = data["user"]["id"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("user_id", userId);

        return true;
      } else {
        // ✅ Clear old token if login fails
        await logout();
        return false;
      }
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      await logout();
      return false;
    }
  }

  // ✅ Register Function
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/register");

    debugPrint("🚀 Sending Register Request to: $url");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint("✅ STATUS CODE: ${response.statusCode}");
      debugPrint("✅ BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data["token"];
        final userId = data["user"]["id"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("user_id", userId);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("❌ REGISTER ERROR: $e");
      return false;
    }
  }

  // ✅ Get Saved Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ✅ Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
