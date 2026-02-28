import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Android Emulator
  static const String baseUrl = "https://my-app-backend-flutter.onrender.com/auth";

  // Use this instead if testing on physical device:
  // static const String baseUrl = "http://YOUR_PC_IP:3000/auth";

  // LOGIN
  static Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final String? token = data["accessToken"];

        if (token == null) return false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // REGISTER
  static Future<bool> register(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // CHECK LOGIN — validates token is not expired
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) return false;

      if (JwtDecoder.isExpired(token)) {
        await prefs.remove("token");
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('isLoggedIn error: $e');
      return false;
    }
  }
}