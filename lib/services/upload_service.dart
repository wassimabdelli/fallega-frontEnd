import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'api_service.dart';

class UploadService {
  UploadService._();
  static final UploadService _instance = UploadService._();
  factory UploadService() => _instance;

  Future<String> uploadChatFile(File file, String token) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/cloudinary/upload'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Echec upload fichier: ${response.statusCode} $responseBody');
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final url = data['url']?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('URL du fichier manquante dans la reponse');
    }
    return url;
  }

  Future<String> uploadFile(File file, String token) async {
    return uploadChatFile(file, token);
  }

  String getFileType(String filePath) {
    final extension = p.extension(filePath).toLowerCase().replaceFirst('.', '');
    const imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp'};
    const audioExtensions = {'mp3', 'wav', 'aac', 'm4a', 'ogg'};
    if (imageExtensions.contains(extension)) {
      return 'image';
    }
    if (audioExtensions.contains(extension)) {
      return 'audio';
    }
    return 'file';
  }
}
