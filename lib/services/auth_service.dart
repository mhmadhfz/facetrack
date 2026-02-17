import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://192.168.1.105:8000/api";
  // ⚠️ Replace with your PC IP

  // ✅ Login Function
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["token"];
      final userId = data["user"]["id"];

      // ✅ Save token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setInt("user_id", userId);

      return true;
    }

    return false;
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
