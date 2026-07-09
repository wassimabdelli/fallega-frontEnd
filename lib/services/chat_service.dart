import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  ChatService._();
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;

  IO.Socket? _socket;
  String? _connectedUserId;
  late IO.Socket socket;
  final String _baseUrl = ApiService.baseUrl;
  
  // Streams pour le temps réel
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  bool get isConnected => _socket?.connected ?? false;

  void connect(String userId) {
    if (_socket != null && _connectedUserId == userId && _socket!.connected) {
      return;
    }

    _socket?.dispose();
    _connectedUserId = userId;
    _socket = IO.io(
      '$_baseUrl/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .build(),
    );

    socket = _socket!;
    socket.onConnect((_) {
      debugPrint('Connecté au WebSocket Chat');
    });

    socket.on('newMessage', (data) {
      _messageController.add(data);
    });

    socket.on('userTyping', (data) {
      _typingController.add(data);
    });

    socket.onDisconnect((_) => debugPrint('Déconnecté du WebSocket Chat'));
  }

  void sendMessage(Map<String, dynamic> messageData) {
    _socket?.emit('sendMessage', messageData);
  }

  void sendTyping(String receiverId, String senderId) {
    _socket?.emit('typing', {'receiverId': receiverId, 'senderId': senderId});
  }

  void markAsRead(String messageId, String senderId) {
    _socket?.emit('markAsRead', {'messageId': messageId, 'senderId': senderId});
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connectedUserId = null;
  }

  // Appels API REST pour l'historique
  static Future<List<dynamic>> getConversation(String userId1, String userId2) async {
    // Note: Utilise ApiService pour les headers/auth
    // Pour l'instant on simule ou on appelle un futur endpoint ApiService
    return []; 
  }
}
