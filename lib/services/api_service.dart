import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator or web
  static const String baseUrl = 'http://192.168.1.13:3000';
  //10.0.2.2
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'user': data['user'],
          'token': data['access_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la connexion',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> loginGoogle(Map<String, dynamic> googleData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-mobile'), // Nouvel endpoint pour le mobile
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(googleData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'user': data['user'],
          'token': data['access_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la connexion Google',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'user': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur: $e',
      };
    }
  }
}
