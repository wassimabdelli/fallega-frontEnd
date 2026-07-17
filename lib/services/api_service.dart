import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator or web
  // 192.168.1.11
 static const String baseUrl = 'http://192.168.1.11:3000';
  //static const String baseUrl = 'http://10.0.2.2:3000';
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
        Uri.parse('$baseUrl/auth/google-mobile'),
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

  static Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-verification-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Erreur lors de l\'envoi du code',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Erreur lors de la vérification',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // --- Friendship & Invitations ---

  static Future<bool> isFriend(String userId1, String userId2, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/friendships/check/$userId1/$userId2'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return response.body == 'true';
      }
      return false;
    } catch (e) {
      debugPrint('Error checking friendship: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getFriends(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/friendships/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('ApiService.getFriends status: ${response.statusCode}');
      debugPrint('ApiService.getFriends body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching friends: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> sendInvitation(String receiverId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invitations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'receiver': receiverId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getReceivedInvitations(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invitations/received/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching received invitations: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> acceptInvitation(String invitationId, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/invitations/$invitationId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> rejectInvitation(String invitationId, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/invitations/$invitationId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createNotification(Map<String, dynamic> notifData, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(notifData),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getNotifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  // --- Messages ---

  static Future<Map<String, dynamic>> getConversation(String userId1, String userId2, String token, {int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversation/$userId1/$userId2?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'messages': [], 'total': 0};
    } catch (e) {
      debugPrint('Error fetching conversation: $e');
      return {'messages': [], 'total': 0};
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
    String receiverId,
    String content,
    String token,
  ) async {
    return sendMessageAdvanced(
      receiverId,
      content,
      token,
      messageType: 'text',
    );
  }

  static Future<Map<String, dynamic>> sendMessageAdvanced(
    String receiverId,
    String content,
    String token, {
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiver': receiverId,
          'content': content,
          'messageType': messageType,
          if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        }),
      );
      debugPrint('ApiService.sendMessage status: ${response.statusCode}');
      debugPrint('ApiService.sendMessage body: ${response.body}');
      
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        data['statusCode'] = response.statusCode;
      }
      return data;
    } catch (e) {
      debugPrint('ApiService.sendMessage error: $e');
      return {'success': false, 'message': e.toString(), 'statusCode': 500};
    }
  }

  // --- Events ---

  static Future<List<dynamic>> getEvents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  }

  // --- Marketplace / Equipment Rentals ---

  static Future<List<dynamic>> getMarketplaceProducts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipement-stock/rentals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching marketplace products: $e');
      return [];
    }
  }
}
