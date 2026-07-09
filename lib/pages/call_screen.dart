import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../main.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String remoteUserId;
  final String remoteUserName;
  final bool isIncoming;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.remoteUserId,
    required this.remoteUserName,
    required this.isIncoming,
    required this.isVideo,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final List<StreamSubscription> _subscriptions = [];

  bool _renderersReady = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  int _durationSeconds = 0;
  Timer? _timer;
  CallStatus _status = CallStatus.idle;

  @override
  void initState() {
    super.initState();
    _status = _callService.status;
    _bindStreams();
    _startFlow();
  }

  void _bindStreams() {
    _subscriptions.add(
      _callService.onStatusChanged.listen((status) {
        if (!mounted) {
          return;
        }
        setState(() => _status = status);
        if (status == CallStatus.active) {
          _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) {
              setState(() => _durationSeconds++);
            }
          });
        } else if (status == CallStatus.idle) {
          _timer?.cancel();
          _timer = null;
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            Navigator.of(context).pop();
          }
        }
      }),
    );

    _subscriptions.add(
      _callService.onLocalStream.listen((stream) {
        if (!mounted || !_renderersReady) {
          return;
        }
        _localRenderer.srcObject = stream;
        setState(() {});
      }),
    );

    _subscriptions.add(
      _callService.onRemoteStream.listen((stream) {
        if (!mounted || !_renderersReady) {
          return;
        }
        _remoteRenderer.srcObject = stream;
        setState(() {});
      }),
    );
  }

  Future<void> _startFlow() async {
    if (widget.isVideo) {
      await _initRenderers();
    }

    if (!widget.isIncoming) {
      try {
        await _callService.initiateCall(
          widget.remoteUserId,
          widget.remoteUserName,
          type: widget.isVideo ? CallType.video : CallType.audio,
        );
      } catch (e) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _renderersReady = true;
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _timer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideoCall = widget.isVideo || _callService.type == CallType.video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: isVideoCall && _status == CallStatus.active
                  ? _buildVideoLayout()
                  : _buildAudioLayout(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: _buildActions(isVideoCall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayout() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        ),
        Positioned(
          top: 24,
          left: 24,
          child: _buildInfo(),
        ),
        Positioned(
          top: 24,
          right: 24,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: RTCVideoView(
              _localRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: kPrimary.withOpacity(0.2),
            child: Text(
              widget.remoteUserName.isEmpty
                  ? '?'
                  : widget.remoteUserName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 42,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfo(centered: true),
        ],
      ),
    );
  }

  Widget _buildInfo({bool centered = false}) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          widget.remoteUserName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _statusLabel(),
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        if (_status == CallStatus.active) ...[
          const SizedBox(height: 8),
          Text(
            _formatDuration(_durationSeconds),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(bool isVideoCall) {
    if (widget.isIncoming && _status == CallStatus.incoming) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: () {
              _callService.rejectCall();
              Navigator.of(context).pop();
            },
          ),
          _ActionButton(
            icon: Icons.call,
            color: Colors.green,
            onPressed: () async {
              try {
                if (isVideoCall && !_renderersReady) {
                  await _initRenderers();
                }
                await _callService.acceptCall();
              } catch (e) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          color: Colors.white24,
          onPressed: () {
            setState(() => _isMuted = !_isMuted);
            _callService.setMute(_isMuted);
          },
        ),
        if (isVideoCall)
          _ActionButton(
            icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
            color: Colors.white24,
            onPressed: () {
              setState(() => _isCameraOff = !_isCameraOff);
              _callService.setCamera(!_isCameraOff);
            },
          ),
        _ActionButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: () {
            _callService.endCall(duration: _durationSeconds);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  String _statusLabel() {
    switch (_status) {
      case CallStatus.calling:
        return 'Appel en cours...';
      case CallStatus.incoming:
        return 'Appel entrant...';
      case CallStatus.active:
        return 'En ligne';
      case CallStatus.idle:
        return 'Appel termine';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
