// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart'
    show VoidCallback, debugPrint, setEquals;
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../services/api_service.dart';

/// WebRTC audio links to every other participant in a live class:
/// offers/answers, batched ICE candidates and the "speaking" level poll.
class SessionPeers {
  SessionPeers({
    required this.send,
    required this.localStream,
    required this.ownParticipantId,
    required this.isMuted,
    required this.isActive,
    required this.onChanged,
  });

  final Future<ApiResult<Map<String, dynamic>>> Function(Map<String, dynamic>)
  send;
  final MediaStream? Function() localStream;
  final int? Function() ownParticipantId;
  final bool Function(int participantId) isMuted;
  final bool Function() isActive;

  /// Runs [update] inside the owner's setState.
  final void Function(VoidCallback update) onChanged;

  final Map<int, RTCPeerConnection> _connections = {};
  // Connections still being created natively, so a second request (for
  // example an offer arriving meanwhile) waits instead of creating another.
  final Map<int, Future<void>> _creating = {};
  final Map<int, RTCVideoRenderer> _renderers = {};
  // ICE candidate batching — collect candidates for 150 ms then send as one POST
  final Map<int, List<Map<String, dynamic>>> _pendingIce = {};
  final Map<int, Timer> _iceTimers = {};

  /// Participant ids whose incoming audio is above the speaking threshold.
  /// Exposed in labels instead of announced (too chatty).
  final Set<int> speaking = {};
  Timer? _speakingTimer;
  bool _pollBusy = false;

  static const Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  Iterable<int> get ids => _connections.keys;
  bool contains(int participantId) =>
      _connections.containsKey(participantId) ||
      _creating.containsKey(participantId);

  Future<void> create(int participantId, bool createOffer) async {
    if (_connections.containsKey(participantId)) return;
    final pending = _creating[participantId];
    if (pending != null) return pending;
    final future = _create(participantId, createOffer);
    _creating[participantId] = future;
    try {
      await future;
    } catch (error) {
      // One failed audio link must not break the class; it is retried when
      // that participant reconnects or sends a new offer.
      debugPrint('[WebRTC] Connection to pid=$participantId failed: $error');
      close(participantId);
    } finally {
      _creating.remove(participantId);
    }
  }

  Future<void> _create(int participantId, bool createOffer) async {
    print('[WebRTC] Creating connection pid=$participantId offer=$createOffer');

    final pc = await createPeerConnection(_iceServers);
    _connections[participantId] = pc;
    _ensureSpeakingPoll();

    final stream = localStream();
    stream?.getTracks().forEach((track) => pc.addTrack(track, stream));

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _handleRemoteStream(participantId, event.streams[0]);
      }
    };

    // Batch ICE candidates: collect for 150 ms then send as a single POST
    pc.onIceCandidate = (candidate) {
      _pendingIce.putIfAbsent(participantId, () => []).add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
      _iceTimers[participantId]?.cancel();
      _iceTimers[participantId] = Timer(const Duration(milliseconds: 150), () {
        _flushIce(participantId);
      });
    };

    pc.onConnectionState = (state) {
      print('[WebRTC] State with pid=$participantId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        close(participantId);
      }
    };

    if (createOffer) {
      await Future.delayed(const Duration(milliseconds: 100));
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await send({
        'type': 'webrtc_signal',
        'target_participant_id': participantId,
        'payload': {'type': 'offer', 'sdp': offer.sdp},
      });
    }
  }

  /// Sends all buffered ICE candidates for a peer in a single POST.
  Future<void> _flushIce(int participantId) async {
    final candidates = _pendingIce.remove(participantId);
    _iceTimers.remove(participantId);
    if (candidates == null || candidates.isEmpty) return;
    print(
      '[WebRTC] Flushing ${candidates.length} ICE candidates to pid=$participantId',
    );
    await send({
      'type': 'webrtc_signal',
      'target_participant_id': participantId,
      'payload': {'type': 'ice_candidates_batch', 'candidates': candidates},
    });
  }

  void _handleRemoteStream(int participantId, MediaStream stream) {
    if (!_renderers.containsKey(participantId)) {
      final renderer = RTCVideoRenderer();
      renderer.initialize().then((_) {
        renderer.srcObject = stream;
        if (isActive()) onChanged(() => _renderers[participantId] = renderer);
      });
    } else {
      _renderers[participantId]!.srcObject = stream;
    }
  }

  Future<void> handleSignal(Map<String, dynamic> data) async {
    final fromPid = data['from'] as int?;
    final toPid = data['to'] as int?;
    final payload = data['payload'] as Map<String, dynamic>?;
    if (fromPid == null || payload == null) return;
    // Ignore signals not addressed to us
    if (toPid != null && toPid != ownParticipantId()) return;

    final signalType = payload['type'] as String?;
    print('[WebRTC] Signal from=$fromPid type=$signalType');
    switch (signalType) {
      case 'offer':
        await _handleOffer(fromPid, payload);
      case 'answer':
        await _handleAnswer(fromPid, payload);
      case 'ice_candidate':
        await _handleIceSingle(fromPid, payload);
      case 'ice_candidates_batch':
        await _handleIceBatch(fromPid, payload);
    }
  }

  Future<void> _handleOffer(int fromPid, Map<String, dynamic> payload) async {
    final sdp = payload['sdp'] as String?;
    if (sdp == null) return;
    await create(fromPid, false);
    final pc = _connections[fromPid];
    if (pc == null) return;
    await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    await send({
      'type': 'webrtc_signal',
      'target_participant_id': fromPid,
      'payload': {'type': 'answer', 'sdp': answer.sdp},
    });
  }

  Future<void> _handleAnswer(int fromPid, Map<String, dynamic> payload) async {
    final sdp = payload['sdp'] as String?;
    if (sdp == null) return;
    await _connections[fromPid]?.setRemoteDescription(
      RTCSessionDescription(sdp, 'answer'),
    );
  }

  Future<void> _handleIceSingle(
    int fromPid,
    Map<String, dynamic> payload,
  ) async {
    final c = payload['candidate'] as Map<String, dynamic>?;
    if (c == null) return;
    await _connections[fromPid]?.addCandidate(
      RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
    );
  }

  Future<void> _handleIceBatch(
    int fromPid,
    Map<String, dynamic> payload,
  ) async {
    final list = payload['candidates'] as List<dynamic>?;
    if (list == null) return;
    final pc = _connections[fromPid];
    if (pc == null) return;
    for (final c in list) {
      final cm = c as Map<String, dynamic>;
      try {
        await pc.addCandidate(
          RTCIceCandidate(cm['candidate'], cm['sdpMid'], cm['sdpMLineIndex']),
        );
      } catch (e) {
        print('[WebRTC] ICE add error: $e');
      }
    }
    print('[WebRTC] Applied ${list.length} ICE candidates from pid=$fromPid');
  }

  void close(int participantId) {
    _iceTimers.remove(participantId)?.cancel();
    _pendingIce.remove(participantId);
    _connections.remove(participantId)?.close();
    _renderers.remove(participantId)?.dispose();
    speaking.remove(participantId);
    if (_connections.isEmpty) {
      _speakingTimer?.cancel();
      _speakingTimer = null;
    }
  }

  /// Closes every connection, waiting for the native side.
  Future<void> closeAll() =>
      Future.wait(_connections.values.map((peer) => peer.close()));

  void _ensureSpeakingPoll() {
    if (_speakingTimer != null || _connections.isEmpty) return;
    _speakingTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => unawaited(_pollSpeaking()),
    );
  }

  /// Reads incoming audio levels so participant labels can say "speaking".
  Future<void> _pollSpeaking() async {
    if (_pollBusy || !isActive()) return;
    _pollBusy = true;
    final now = <int>{};
    try {
      for (final entry in _connections.entries.toList()) {
        if (isMuted(entry.key)) continue;
        try {
          final reports = await entry.value.getStats();
          for (final report in reports) {
            if (report.type != 'inbound-rtp') continue;
            final values = report.values;
            final kind = values['kind'] ?? values['mediaType'];
            if (kind != null && kind != 'audio') continue;
            final raw = values['audioLevel'];
            final level = raw is num
                ? raw.toDouble()
                : double.tryParse('${raw ?? ''}');
            if (level != null && level > 0.05) {
              now.add(entry.key);
              break;
            }
          }
        } catch (error) {
          debugPrint('[WebRTC] Audio level unavailable: $error');
        }
      }
    } finally {
      _pollBusy = false;
    }
    if (!isActive() || setEquals(now, speaking)) return;
    onChanged(() {
      speaking
        ..clear()
        ..addAll(now);
    });
  }

  void dispose() {
    for (final pc in _connections.values) {
      pc.close();
    }
    for (final r in _renderers.values) {
      r.dispose();
    }
    for (final t in _iceTimers.values) {
      t.cancel();
    }
    _speakingTimer?.cancel();
  }
}
