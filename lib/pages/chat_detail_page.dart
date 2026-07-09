import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../services/call_service.dart';
import '../services/chat_service.dart';
import '../services/upload_service.dart';
import 'call_screen.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String friendId;
  final String name;
  final String avatar;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.friendId,
    required this.name,
    required this.avatar,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final UploadService _uploadService = UploadService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingAudioUrl;
  PlayerState _audioPlayerState = PlayerState.stopped;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isTyping = false;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  String? _currentRecordingPath;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _callSubscription;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectRealtime();
    });
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _audioPlayerState = state);
        // When playback completes, reset the playing URL
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          setState(() => _playingAudioUrl = null);
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.user;
    final token = appProvider.token;

    if (currentUser == null || token == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getConversation(currentUser['_id'], widget.friendId, token);
      if (mounted) {
        setState(() {
          _messages = (response['messages'] as List).reversed.toList();
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _connectRealtime() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.user;
    final currentUserId = currentUser?['_id']?.toString();
    if (currentUserId == null || currentUserId.isEmpty) {
      return;
    }

    _chatService.connect(currentUserId);

    _messageSubscription ??= _chatService.messageStream.listen((data) {
      if (!_isConversationMessage(data, currentUserId)) {
        return;
      }
      if (_containsMessage(data['_id']?.toString())) {
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add(data);
      });
      _scrollToBottom();
    });

    _typingSubscription ??= _chatService.typingStream.listen((data) {
      if (data['senderId']?.toString() != widget.friendId || !mounted) {
        return;
      }
      setState(() => _isTyping = true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _isTyping = false);
        }
      });
    });

    _callSubscription ??= CallService().onIncomingCall.listen((data) {
      if (data['callerId']?.toString() != widget.friendId || !mounted) {
        return;
      }
      _addLocalCallTrace(isVideo: data['type'] == 'video', incoming: true);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.token;
    final currentUser = appProvider.user;

    if (token == null || currentUser == null) return;

    final optimisticMessage = {
      '_id': DateTime.now().toString(),
      'sender': currentUser,
      'content': text,
      'createdAt': DateTime.now().toIso8601String(),
      'isMe': true,
    };

    setState(() {
      _messages.add(optimisticMessage);
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final result = await ApiService.sendMessage(widget.friendId, text, token);
      debugPrint('SendMessage result: $result');
      if (result['_id'] == null && result['id'] == null) {
        // Handle error
        if (mounted) {
          final errorMessage = result['message'] ?? result['error'] ?? 'Erreur lors de l\'envoi';
          final statusCode = result['statusCode'] ?? 'Unknown';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('[$statusCode] ${errorMessage is List ? errorMessage.join(', ') : errorMessage.toString()}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> _pickAndSendFile() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.token;
    if (token == null) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final file = File(path);
      final messageType = _uploadService.getFileType(path);
      final fileUrl = await _uploadService.uploadChatFile(file, token);
      final fileName = result!.files.single.name;

      final response = await ApiService.sendMessageAdvanced(
        widget.friendId,
        fileName,
        token,
        messageType: messageType,
        attachmentUrl: fileUrl,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add({
          '_id': response['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'sender': appProvider.user,
          'receiver': widget.friendId,
          'content': fileName,
          'messageType': messageType,
          'attachmentUrl': fileUrl,
          'createdAt': DateTime.now().toIso8601String(),
          'isMe': true,
        });
        _isUploading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur upload fichier: $e')),
      );
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecordingAndSend();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      return;
    }

    final directory = await getTemporaryDirectory();
    final filePath = p.join(directory.path, 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a');
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _currentRecordingPath = filePath;
    });

    await _audioRecorder.start(
      const RecordConfig(),
      path: filePath,
    );

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });
  }

  Future<void> _stopRecordingAndSend() async {
    _recordingTimer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });

    if (path == null) {
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.token;
    if (token == null) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final file = File(path);
      final fileUrl = await _uploadService.uploadChatFile(file, token);

      final response = await ApiService.sendMessageAdvanced(
        widget.friendId,
        'Message vocal',
        token,
        messageType: 'audio',
        attachmentUrl: fileUrl,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add({
          '_id': response['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'sender': appProvider.user,
          'receiver': widget.friendId,
          'content': 'Message vocal',
          'messageType': 'audio',
          'attachmentUrl': fileUrl,
          'createdAt': DateTime.now().toIso8601String(),
          'isMe': true,
        });
        _isUploading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur upload vocal: $e')),
      );
    }
  }

  Future<void> _toggleAudio(String url) async {
    try {
      // Tap on a different message → stop current and play new
      if (_playingAudioUrl != url) {
        await _audioPlayer.stop();
        setState(() {
          _playingAudioUrl = url;
          _audioPlayerState = PlayerState.playing;
        });
        await _audioPlayer.play(UrlSource(url));
        return;
      }

      // Tap on the same message → toggle pause / resume
      if (_audioPlayerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else if (_audioPlayerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        // stopped / completed → replay
        setState(() => _playingAudioUrl = url);
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      debugPrint('Error toggling audio: $e');
    }
  }

  void _startCall({required bool isVideo}) {
    _addLocalCallTrace(isVideo: isVideo, incoming: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          remoteUserId: widget.friendId,
          remoteUserName: widget.name,
          isIncoming: false,
          isVideo: isVideo,
        ),
      ),
    );
  }

  void _addLocalCallTrace({required bool isVideo, required bool incoming}) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.user;
    final sender = incoming ? widget.friendId : currentUser;
    final receiverId = incoming ? _extractUserId(currentUser) : widget.friendId;

    setState(() {
      _messages.add({
        '_id': 'call-${DateTime.now().millisecondsSinceEpoch}',
        'sender': sender,
        'receiver': receiverId,
        'content': isVideo ? 'Appel video' : 'Appel audio',
        'messageType': isVideo ? 'call_video' : 'call_audio',
        'createdAt': DateTime.now().toIso8601String(),
        'isMe': !incoming,
      });
    });
    _scrollToBottom();
  }

  bool _containsMessage(String? id) {
    if (id == null || id.isEmpty) {
      return false;
    }
    return _messages.any((message) => message['_id']?.toString() == id);
  }

  bool _isConversationMessage(Map<String, dynamic> message, String currentUserId) {
    final senderId = _extractUserId(message['sender']);
    final receiverId = _extractUserId(message['receiver']);
    return (senderId == currentUserId && receiverId == widget.friendId) ||
        (senderId == widget.friendId && receiverId == currentUserId);
  }

  String? _extractUserId(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString();
    }
    return value.toString();
  }

  String? _attachmentUrl(dynamic message) => message['attachmentUrl']?.toString();

  String _messageType(dynamic message) => message['messageType']?.toString() ?? 'text';

  String _messageContent(dynamic message) => message['content']?.toString() ?? '';

  String _senderId(dynamic message) => _extractUserId(message['sender']) ?? '';

  DateTime _createdAt(dynamic message) {
    final raw = message['createdAt']?.toString();
    return raw == null ? DateTime.now() : DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _recordingTimer?.cancel();
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _callSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = appProvider.user;

    return Scaffold(
      backgroundColor: isDark ? kDarkBg : kLight,
      appBar: AppBar(
        backgroundColor: isDark ? kDarkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: isDark ? kDarkText : kDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimary, kPrimaryDark],
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.avatar,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isTyping ? 'En train d\'ecrire...' : 'En ligne',
                    style: TextStyle(color: Colors.green[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.phone, color: isDark ? kDarkText : kDark),
            onPressed: () => _startCall(isVideo: false),
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: isDark ? kDarkText : kDark),
            onPressed: () => _startCall(isVideo: true),
          ),
          IconButton(
            icon: Icon(LucideIcons.ellipsis_vertical, color: isDark ? kDarkText : kDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(color: kPrimary),
          // Messages
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['isMe'] == true || _senderId(msg) == currentUser?['_id'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isMe ? kPrimary : (isDark ? kDarkSurface : Colors.white),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 20),
                                    ),
                                    boxShadow: isMe 
                                      ? [] 
                                      : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildMessageBody(msg, isMe, isDark),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTime(_createdAt(msg)),
                                        style: TextStyle(
                                          color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            decoration: BoxDecoration(
              color: isDark ? kDarkSurface : Colors.white,
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _pickAndSendFile,
                  icon: const Icon(LucideIcons.paperclip),
                  color: kPrimary,
                ),
                IconButton(
                  onPressed: _toggleRecording,
                  icon: Icon(
                    _isRecording ? LucideIcons.square : LucideIcons.mic,
                    color: _isRecording ? Colors.red : kPrimary,
                  ),
                ),
                Expanded(
                  child: _isRecording
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.mic, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                '${_recordingSeconds ~/ 60}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? kDarkBg : Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _messageController,
                            onChanged: (_) {
                              final currentUserId = currentUser?['_id']?.toString();
                              if (currentUserId != null && currentUserId.isNotEmpty) {
                                _chatService.sendTyping(widget.friendId, currentUserId);
                              }
                              setState(() {});
                            },
                            style: TextStyle(color: isDark ? kDarkText : kDark),
                            decoration: InputDecoration(
                              hintText: 'Votre message...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                if (!_isRecording)
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBody(Map<String, dynamic> message, bool isMe, bool isDark) {
    final messageType = _messageType(message);
    final attachmentUrl = _attachmentUrl(message);
    final textColor = isMe ? Colors.white : (isDark ? kDarkText : kDark);

    switch (messageType) {
      case 'image':
        return GestureDetector(
          onTap: attachmentUrl == null ? null : () => _openAttachment(attachmentUrl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (attachmentUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    attachmentUrl,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 180,
                      height: 180,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              if (_messageContent(message).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _messageContent(message),
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              ],
            ],
          ),
        );
      case 'audio':
        final isThisPlaying = _playingAudioUrl == attachmentUrl &&
            _audioPlayerState == PlayerState.playing;
        final isThisPaused = _playingAudioUrl == attachmentUrl &&
            _audioPlayerState == PlayerState.paused;
        final isThisLoading = _playingAudioUrl == attachmentUrl &&
            _audioPlayerState == PlayerState.playing &&
            false; // audioplayers fires playing immediately, no loading state needed

        return GestureDetector(
          onTap: attachmentUrl == null ? null : () => _toggleAudio(attachmentUrl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withOpacity(0.25)
                      : kPrimary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isThisPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: isMe ? Colors.white : kPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message vocal',
                      style: TextStyle(color: textColor, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Simple waveform decoration
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(12, (i) {
                        final heights = [6.0, 10.0, 14.0, 8.0, 12.0, 16.0, 8.0, 12.0, 10.0, 6.0, 14.0, 8.0];
                        final active = isThisPlaying || isThisPaused;
                        return Container(
                          width: 3,
                          height: heights[i],
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: active
                                ? (isMe ? Colors.white : kPrimary)
                                : (isMe
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.grey[400]),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'file':
        final fileName = attachmentUrl?.split('/').last ?? _messageContent(message);
        return InkWell(
          onTap: attachmentUrl == null ? null : () => _openAttachment(attachmentUrl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file, color: textColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  fileName,
                  style: TextStyle(color: textColor, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      case 'call_audio':
      case 'call_video':
        final isVideo = messageType == 'call_video';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVideo ? Icons.videocam_outlined : Icons.call_outlined,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isVideo ? 'Appel video' : 'Appel audio',
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ],
        );
      case 'text':
      default:
        return Text(
          _messageContent(message),
          style: TextStyle(
            color: textColor,
            fontSize: 15,
          ),
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
