import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api_service.dart';

enum CallStatus { idle, calling, incoming, active }

enum CallType { audio, video }

class CallService {
  CallService._();
  static final CallService _instance = CallService._();
  factory CallService() => _instance;

  io.Socket? _socket;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentCallId;
  String? _remoteUserId;
  String? _remoteUserName;
  CallStatus _status = CallStatus.idle;
  CallType _type = CallType.audio;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  Map<String, dynamic>? _pendingOffer;
  final List<RTCIceCandidate> _pendingIceCandidates = [];
  Completer<void>? _callAcceptedCompleter;
  final AudioPlayer _ringtonePlayer = AudioPlayer();

  final _statusController = StreamController<CallStatus>.broadcast();
  final _incomingCallController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _localStreamController = StreamController<MediaStream?>.broadcast();
  final _remoteStreamController = StreamController<MediaStream?>.broadcast();

  Stream<CallStatus> get onStatusChanged => _statusController.stream;
  Stream<Map<String, dynamic>> get onIncomingCall => _incomingCallController.stream;
  Stream<MediaStream?> get onLocalStream => _localStreamController.stream;
  Stream<MediaStream?> get onRemoteStream => _remoteStreamController.stream;

  CallStatus get status => _status;
  CallType get type => _type;
  String? get remoteUserName => _remoteUserName;
  String? get remoteUserId => _remoteUserId;
  String? get currentCallId => _currentCallId;

  void connect({
    required String userId,
    required String userName,
  }) {
    if (_socket != null && _socket!.connected && _currentUserId == userId) {
      return;
    }

    _currentUserId = userId;
    _currentUserName = userName;
    _socket?.dispose();

    _socket = io.io(
      '${ApiService.baseUrl}/call',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('CallService connecte');
    });

    _socket!.on('incomingCall', (data) async {
      _currentCallId = data['callId']?.toString();
      _remoteUserId = data['callerId']?.toString();
      _remoteUserName = data['callerName']?.toString() ?? 'Appel entrant';
      _type = (data['callType'] ?? data['type']) == 'video'
          ? CallType.video
          : CallType.audio;
      _status = CallStatus.incoming;
      _statusController.add(_status);
      _incomingCallController.add({
        'callId': _currentCallId,
        'callerId': _remoteUserId,
        'callerName': _remoteUserName,
        'type': _type == CallType.video ? 'video' : 'audio',
      });
      await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
      await _ringtonePlayer.play(AssetSource('bellaciao.mp3'));
    });

    _socket!.on('callAnswered', (data) {
      _ringtonePlayer.stop();
      _currentCallId = data['callId']?.toString() ?? _currentCallId;
      if (_callAcceptedCompleter != null &&
          !_callAcceptedCompleter!.isCompleted) {
        _callAcceptedCompleter!.complete();
      }
    });

    _socket!.on('callRejected', (data) {
      _ringtonePlayer.stop();
      if (_callAcceptedCompleter != null &&
          !_callAcceptedCompleter!.isCompleted) {
        _callAcceptedCompleter!
            .completeError(Exception('Appel refuse par le correspondant'));
      }
      _cleanUp();
    });

    _socket!.on('offer', (data) {
      _currentCallId = data['callId']?.toString() ?? _currentCallId;
      _pendingOffer = Map<String, dynamic>.from(data['offer'] as Map);
    });

    _socket!.on('answer', (data) async {
      final answer = Map<String, dynamic>.from(data['answer'] as Map);
      await _handleAnswer(answer);
    });

    _socket!.on('iceCandidate', (data) async {
      final candidateMap = Map<String, dynamic>.from(data['candidate'] as Map);
      final candidate = RTCIceCandidate(
        candidateMap['candidate']?.toString(),
        candidateMap['sdpMid']?.toString(),
        candidateMap['sdpMLineIndex'] as int?,
      );

      if (_peerConnection != null) {
        await _peerConnection!.addCandidate(candidate);
      } else {
        _pendingIceCandidates.add(candidate);
      }
    });

    _socket!.on('callEnded', (_) {
      _cleanUp();
    });
  }

  void disconnect() {
    _cleanUp(resetSocketOnly: true);
    _socket?.dispose();
    _socket = null;
  }

  Future<void> initiateCall(
    String receiverId,
    String receiverName, {
    CallType type = CallType.audio,
  }) async {
    await _ensurePermissions(type);
    if (_socket == null) {
      throw Exception('Service d\'appel non connecte');
    }

    _remoteUserId = receiverId;
    _remoteUserName = receiverName;
    _type = type;
    _status = CallStatus.calling;
    _statusController.add(_status);
    _callAcceptedCompleter = Completer<void>();

    // Add a completer to wait for the callId from the backend
    final callIdCompleter = Completer<String>();

    // Listen for callCreated event from backend
    void onCallCreatedHandler(dynamic data) {
      if (data != null && data['callId'] != null) {
        _currentCallId = data['callId'].toString();
        debugPrint('Caller got callId from backend: $_currentCallId');
        if (!callIdCompleter.isCompleted) {
          callIdCompleter.complete(_currentCallId!);
        }
      }
    }

    _socket!.on('callCreated', onCallCreatedHandler);

    _socket!.emit('initiateCall', {
      'receiverId': receiverId,
      'callType': type == CallType.video ? 'video' : 'audio',
      'callerName': _currentUserName,
    });

    // Wait a short time for callId, then continue if we don't get it (for backwards compatibility)
    try {
      await callIdCompleter.future.timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Did not get callId from backend, continuing anyway: $e');
    } finally {
      // Remove all listeners for 'callCreated' to avoid leaks
      _socket!.off('callCreated');
    }

    await _callAcceptedCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Aucune reponse a l\'appel'),
    );

    await _createPeerConnection();
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    if (_currentCallId == null) {
      debugPrint('Warning: _currentCallId is still null when sending offer!');
    }

    _socket!.emit('offer', {
      'callId': _currentCallId,
      'targetUserId': receiverId,
      'offer': offer.toMap(),
    });
  }

  Future<void> acceptCall() async {
    if (_currentCallId == null || _remoteUserId == null) {
      throw Exception('Informations d\'appel manquantes');
    }

    await _ensurePermissions(_type);

    _socket!.emit('answerCall', {
      'callId': _currentCallId,
      'callerId': _remoteUserId,
      'accepted': true,
    });

    await _createPeerConnection();

    final offer = await _waitForOffer();
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(
        offer['sdp']?.toString(),
        offer['type']?.toString(),
      ),
    );

    for (final candidate in _pendingIceCandidates) {
      await _peerConnection!.addCandidate(candidate);
    }
    _pendingIceCandidates.clear();

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    _socket!.emit('answer', {
      'callId': _currentCallId,
      'targetUserId': _remoteUserId,
      'answer': answer.toMap(),
    });

    _pendingOffer = null;
    _status = CallStatus.active;
    _statusController.add(_status);
  }

  void rejectCall() {
    if (_currentCallId != null && _remoteUserId != null) {
      _socket?.emit('answerCall', {
        'callId': _currentCallId,
        'callerId': _remoteUserId,
        'accepted': false,
      });
    }
    _cleanUp();
  }

  void endCall({int duration = 0}) {
    if (_currentCallId != null && _currentUserId != null) {
      _socket?.emit('endCall', {
        'callId': _currentCallId,
        'userId': _currentUserId,
        'duration': duration,
      });
    }
    _cleanUp();
  }

  void setMute(bool mute) {
    for (final track in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !mute;
    }
  }

  void setCamera(bool enabled) {
    for (final track in _localStream?.getVideoTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = enabled;
    }
  }

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) {
      return;
    }

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate == null || _remoteUserId == null) {
        return;
      }
      _socket?.emit('iceCandidate', {
        'callId': _currentCallId,
        'targetUserId': _remoteUserId,
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStreamController.add(event.streams.first);
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': _type == CallType.video,
    });
    _localStreamController.add(_localStream);

    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }
  }

  Future<Map<String, dynamic>> _waitForOffer() async {
    for (var i = 0; i < 75; i++) {
      if (_pendingOffer != null) {
        return _pendingOffer!;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    throw Exception('Offre WebRTC non recue');
  }

  Future<void> _handleAnswer(Map<String, dynamic> answer) async {
    if (_peerConnection == null) {
      return;
    }

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(
        answer['sdp']?.toString(),
        answer['type']?.toString(),
      ),
    );
    _status = CallStatus.active;
    _statusController.add(_status);
  }

  Future<void> _ensurePermissions(CallType type) async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      throw Exception('Permission microphone refusee');
    }

    if (type == CallType.video) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        throw Exception('Permission camera refusee');
      }
    }
  }

  void _cleanUp({bool resetSocketOnly = false}) {
    _ringtonePlayer.stop();
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    _pendingOffer = null;
    _pendingIceCandidates.clear();
    _callAcceptedCompleter = null;
    _currentCallId = null;
    _remoteUserId = null;
    _remoteUserName = null;
    _type = CallType.audio;
    _status = CallStatus.idle;
    _statusController.add(_status);
    _localStreamController.add(null);
    _remoteStreamController.add(null);
  }
}
