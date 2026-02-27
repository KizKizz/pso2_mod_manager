import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'dart:io';

class MeshManager {
  final String roomId;
  final String myPeerId = const Uuid().v4();

  WebSocketChannel? _wsChannel;
  Timer? _reconnectTimer;

  Map<String, RTCPeerConnection> peerConnections = {};
  Map<String, RTCDataChannel> dataChannels = {};

  // CHANGE THIS to your real Vercel URL
  final String _tokenEndpoint = 'https://ably-token-server-chi.vercel.app/ably-token-request';

  final String _ablyWsBase = 'wss://realtime.ably.io?accessToken=';
  final String _channelPrefix = 'room:';

  // Receiving multiple files at once
  final Map<String, FileReceiver> _incomingTransfers = {};

  MeshManager(this.roomId) {
    _connectWithToken();
  }

  Future<void> _connectWithToken() async {
    try {
      debugPrint('Requesting Ably TokenRequest...');

      final uri = Uri.parse('$_tokenEndpoint?clientId=$myPeerId');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        debugPrint('Token request failed: ${response.statusCode} → ${response.body}');
        _scheduleReconnect();
        return;
      }

      final tokenRequest = jsonDecode(response.body);
      debugPrint('TokenRequest JSON: ${jsonEncode(tokenRequest)}');

      // debugPrint(await _getAblyTokenString(tokenRequest));

      // Convert to string, then properly encode for query param
      // final tokenJsonString = jsonEncode(tokenRequest);
      // final encodedToken = Uri.encodeQueryComponent(tokenJsonString);

      final token = await _getAblyTokenString(tokenRequest);

      final wsUrlString = '$_ablyWsBase$token';
      debugPrint('Connecting to Ably WS: $wsUrlString');

      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrlString));

      _wsChannel!.stream.listen(
        (msg) {
          try {
            final data = jsonDecode(msg as String) as Map<String, dynamic>?;
            if (data == null) return;
            _handleAblyMessage(data);
          } catch (e) {
            debugPrint('Error parsing Ably message: $e');
          }
        },
        onError: (err) {
          debugPrint('WebSocket error: $err');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _scheduleReconnect();
        },
      );

      _send({'action': 'subscribe', 'channel': '$_channelPrefix$roomId'});

      _send({
        'action': 'presence',
        'channel': '$_channelPrefix$roomId',
        'clientId': myPeerId,
        'presence': {'action': 'enter'},
      });

      debugPrint('Subscribed & entered presence in room $roomId');
    } catch (e) {
      debugPrint('Connection setup error: $e');
      _scheduleReconnect();
    }
  }

  void _send(Map<String, dynamic> msg) {
    if (_wsChannel == null) return;
    try {
      _wsChannel!.sink.add(jsonEncode(msg));
      debugPrint('→ Sent: ${msg['action']}');
    } catch (e) {
      debugPrint('Failed to send Ably message: $e');
    }
  }

  Future<String> _getAblyTokenString(Map<String, dynamic> tokenRequest) async {
    // 2. POST to Ably's REST endpoint
    String keyName = tokenRequest.entries.firstWhere((e) => e.key == 'keyName').value;
    final String url = 'https://main.realtime.ably.net/keys/$keyName/requestToken';
    final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(tokenRequest));
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to exchange token: ${response.body}');
    }
  }

  void _handleAblyMessage(Map<String, dynamic> msg) {
    // Get action safely (handle both int and string)
    dynamic rawAction = msg['action'];
    final actionStr = rawAction is int ? _connectionActionFromCode(rawAction) : (rawAction as dynamic)?.toString();

    debugPrint('Received Ably action: $actionStr (raw: $rawAction)');

    if (actionStr == 'connected') {
      debugPrint('Ably connection successfully established (action 4)');
      // Optional: you can trigger UI update, load peers, etc. here
      return;
    }

    if (actionStr == 'disconnected' || actionStr == 'error' || actionStr == 'suspended') {
      debugPrint('Connection issue: $actionStr - reconnecting...');
      _scheduleReconnect();
      return;
    }

    // Presence events (0,1,2)
    if (actionStr == 'presence') {
      final presence = msg['presence'] as List<dynamic>? ?? [];
      for (final p in presence) {
        final clientId = (p['clientId'] as dynamic)?.toString() ?? '';
        dynamic rawPAction = p['action'];
        final pActionStr = rawPAction is int ? _presenceActionFromCode(rawPAction) : (rawPAction as dynamic)?.toString() ?? '';

        if (clientId.isEmpty || clientId == myPeerId) continue;

        debugPrint('Presence: $clientId → $pActionStr (raw action: $rawPAction)');

        if (pActionStr == 'enter' || pActionStr == 'update') {
          _initiateConnectionToPeer(clientId);
        } else if (pActionStr == 'leave') {
          _cleanupPeer(clientId);
        }
      }
      return;
    }

    // Message events
    if (actionStr == 'message') {
      final messages = msg['messages'] as List<dynamic>? ?? [];
      for (final m in messages) {
        final data = m['data'] as Map<String, dynamic>?;
        if (data == null) continue;

        final from = (data['from'] as dynamic)?.toString() ?? '';
        final to = (data['to'] as dynamic)?.toString() ?? '';
        final type = (data['type'] as dynamic)?.toString() ?? '';

        if (from.isEmpty || from == myPeerId) continue;
        if (to.isNotEmpty && to != myPeerId && to != '*') continue;

        switch (type) {
          case 'offer':
            final sdp = (data['sdp'] as dynamic)?.toString() ?? '';
            final offerType = (data['type'] as dynamic)?.toString() ?? 'offer';
            final offer = RTCSessionDescription(sdp, offerType);
            _handleIncomingOffer(from, offer);
            break;
          case 'answer':
            final sdp = (data['sdp'] as dynamic)?.toString() ?? '';
            final answerType = (data['type'] as dynamic)?.toString() ?? 'answer';
            final answer = RTCSessionDescription(sdp, answerType);
            peerConnections[from]?.setRemoteDescription(answer);
            break;
          case 'candidate':
            final candidateStr = (data['candidate'] as dynamic)?.toString() ?? '';
            final sdpMid = (data['sdpMid'] as dynamic)?.toString() ?? '';
            final sdpMLineIndex = (data['sdpMLineIndex'] as int?) ?? 0;
            final candidate = RTCIceCandidate(candidateStr, sdpMid, sdpMLineIndex);
            peerConnections[from]?.addCandidate(candidate);
            break;
          case 'leave':
            _cleanupPeer(from);
            break;
        }
      }
    }
  }

  // Helper for connection-level actions
  String _connectionActionFromCode(int code) {
    switch (code) {
      case 4:
        return 'connected';
      case 5:
        return 'disconnected';
      case 6:
        return 'closing';
      case 7:
        return 'closed';
      case 8:
        return 'error';
      case 9:
        return 'suspended';
      default:
        return 'unknown-connection-$code';
    }
  }

  // Helper for presence actions
  String _presenceActionFromCode(int code) {
    switch (code) {
      case 0:
        return 'enter';
      case 1:
        return 'leave';
      case 2:
        return 'update';
      default:
        return 'unknown-presence-$code';
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), _connectWithToken);
  }

  Future<void> _initiateConnectionToPeer(String remotePeerId) async {
    if (peerConnections.containsKey(remotePeerId)) return;
    debugPrint('New peer detected: $remotePeerId → initiating connection');
    await _createPeerConnection(remotePeerId, isInitiator: true);
  }

  Future<RTCPeerConnection> _createPeerConnection(String remotePeerId, {required bool isInitiator}) async {
    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    pc.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null && candidate.candidate != null) {
        _publish('candidate', {'to': remotePeerId, 'from': myPeerId, 'candidate': candidate.candidate, 'sdpMid': candidate.sdpMid, 'sdpMLineIndex': candidate.sdpMLineIndex});
      }
    };

    pc.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        _cleanupPeer(remotePeerId);
      }
    };

    final dcInit = RTCDataChannelInit()
      ..ordered = true
      ..maxRetransmits = -1;

    RTCDataChannel? channel;
    if (isInitiator) {
      channel = await pc.createDataChannel('fileTransfer', dcInit);
      _setupDataChannel(channel, remotePeerId);
    }

    pc.onDataChannel = (incoming) {
      if (incoming.label == 'fileTransfer') {
        channel = incoming;
        _setupDataChannel(channel!, remotePeerId);
      }
    };

    peerConnections[remotePeerId] = pc;
    if (channel != null) dataChannels[remotePeerId] = channel!;

    if (isInitiator) {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      _publish('offer', {'to': remotePeerId, 'from': myPeerId, 'sdp': offer.sdp, 'type': offer.type});
    }

    return pc;
  }

  Future<void> _handleIncomingOffer(String from, RTCSessionDescription offer) async {
    var pc = peerConnections[from];
    pc ??= await _createPeerConnection(from, isInitiator: false);

    await pc.setRemoteDescription(offer);
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    _publish('answer', {'to': from, 'from': myPeerId, 'sdp': answer.sdp, 'type': answer.type});
  }

  void _publish(String type, Map<String, dynamic> data) {
    _send({
      'action': 'publish',
      'channel': '$_channelPrefix$roomId',
      'messages': [
        {'name': type, 'data': data},
      ],
    });
  }

  void _cleanupPeer(String remotePeerId) {
    dataChannels[remotePeerId]?.close();
    peerConnections[remotePeerId]?.close();
    dataChannels.remove(remotePeerId);
    peerConnections.remove(remotePeerId);
    debugPrint('Cleaned up peer: $remotePeerId');
  }

  Future<void> dispose() async {
    _reconnectTimer?.cancel();

    // Fixed: no duplicate 'action' key
    _send({
      'action': 'presence',
      'channel': '$_channelPrefix$roomId',
      'clientId': myPeerId,
      'presence': {'action': 'leave'},
    });

    await _wsChannel?.sink.close();
    _wsChannel = null;

    peerConnections.forEach((_, pc) => pc.close());
    dataChannels.forEach((_, dc) => dc.close());
    peerConnections.clear();
    dataChannels.clear();

    _incomingTransfers.clear();

    debugPrint('MeshManager disposed');
  }

  List<String> get connectedPeers => peerConnections.keys.toList();

  // ────────────────────────────────────────────────────────────────
  // File sending & receiving methods (from previous messages)
  // ────────────────────────────────────────────────────────────────

  Future<void> sendFileToAll(File file) async {
    if (connectedPeers.isEmpty) {
      debugPrint('No connected peers to send file to');
      return;
    }

    debugPrint('Sending file to ${connectedPeers.length} peers...');

    final futures = connectedPeers.map((peerId) => sendFileToPeer(peerId, file));
    await Future.wait(futures);
  }

  Future<void> sendFileToPeer(String remotePeerId, File file) async {
    final channel = dataChannels[remotePeerId];
    if (channel == null || channel.state != RTCDataChannelState.RTCDataChannelOpen) {
      debugPrint('Cannot send to $remotePeerId: channel not open or missing');
      return;
    }

    try {
      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('File is empty');
        return;
      }

      final filename = file.path.split(Platform.pathSeparator).last;
      const chunkSize = 16384;
      final totalChunks = (fileSize / chunkSize).ceil();

      final transferId = const Uuid().v4();

      debugPrint('→ Sending "$filename" ($fileSize bytes, $totalChunks chunks) to $remotePeerId [ID: $transferId]');

      final metadata = {'type': 'file-metadata', 'transferId': transferId, 'filename': filename, 'size': fileSize, 'totalChunks': totalChunks, 'chunkSize': chunkSize, 'sender': myPeerId};
      channel.send(RTCDataChannelMessage(jsonEncode(metadata)));

      final bytes = await file.readAsBytes();

      int chunkIndex = 0;
      for (int offset = 0; offset < fileSize; offset += chunkSize) {
        while (channel.bufferedAmount! > 256 * 1024) {
          await Future.delayed(const Duration(milliseconds: 30));
        }

        final end = (offset + chunkSize).clamp(0, fileSize);
        final chunk = bytes.sublist(offset, end);

        channel.send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(chunk)));

        chunkIndex++;
        if (chunkIndex % 20 == 0 || chunkIndex == totalChunks) {
          debugPrint('  Chunk $chunkIndex/$totalChunks sent to $remotePeerId');
        }
      }

      debugPrint('✓ File "$filename" fully sent to $remotePeerId');
    } catch (e) {
      debugPrint('Error sending file to $remotePeerId: $e');
    }
  }

  void _setupDataChannel(RTCDataChannel channel, String remotePeerId) {
    if (channel.state == RTCDataChannelState.RTCDataChannelOpen) debugPrint('Data channel opened to $remotePeerId');
    if (channel.state == RTCDataChannelState.RTCDataChannelClosed) debugPrint('Data channel closed to $remotePeerId');

    channel.onMessage = (message) {
      if (message.isBinary) {
        _handleReceivedChunk(message.binary, remotePeerId);
      } else {
        _handleReceivedText(message.text, remotePeerId);
      }
    };
  }

  void _handleReceivedText(String text, String remotePeerId) {
    try {
      final json = jsonDecode(text);
      if (json['type'] == 'file-metadata') {
        final transferId = json['transferId'] as String?;
        if (transferId == null) return;

        final filename = json['filename'] as String? ?? 'unnamed_file';
        final size = json['size'] as int? ?? 0;
        final totalChunks = json['totalChunks'] as int? ?? 0;
        final chunkSize = json['chunkSize'] as int? ?? 16384;

        debugPrint('← New incoming file from $remotePeerId: $filename ($size bytes, $totalChunks chunks) [ID: $transferId]');

        _incomingTransfers[transferId] = FileReceiver(
          sender: remotePeerId,
          transferId: transferId,
          filename: filename,
          totalChunks: totalChunks,
          expectedSize: size,
          chunkSize: chunkSize,
          onComplete: () {
            _incomingTransfers.remove(transferId);
            debugPrint('Transfer $transferId cleaned up from incomingTransfers');
          },
        );
      }
    } catch (e) {
      debugPrint('Failed to parse text message from $remotePeerId: $e');
    }
  }

  void _handleReceivedChunk(Uint8List chunk, String remotePeerId) {
    FileReceiver? target;
    for (final receiver in _incomingTransfers.values) {
      if (receiver.sender == remotePeerId) {
        target = receiver;
        break;
      }
    }

    if (target == null) {
      debugPrint('Received chunk from $remotePeerId but no active transfer');
      return;
    }

    target.addChunk(chunk);
  }
}

// ────────────────────────────────────────────────────────────────
class FileReceiver {
  final String sender;
  final String transferId;
  final String filename;
  final int totalChunks;
  final int expectedSize;
  final int chunkSize;
  final VoidCallback onComplete; // ← callback to clean up

  final List<Uint8List> chunks = [];
  int receivedChunks = 0;

  FileReceiver({required this.sender, required this.transferId, required this.filename, required this.totalChunks, required this.expectedSize, required this.chunkSize, required this.onComplete});

  void addChunk(Uint8List data) {
    chunks.add(data);
    receivedChunks++;

    debugPrint('Chunk $receivedChunks/$totalChunks received from $sender [transfer: $transferId]');

    if (receivedChunks == totalChunks) {
      _saveFile();
    }
  }

  Future<void> _saveFile() async {
    try {
      final bytes = Uint8List.fromList(chunks.expand((list) => list).toList());

      if (bytes.length != expectedSize) {
        debugPrint('Size mismatch for $filename (expected $expectedSize, got ${bytes.length})');
        onComplete(); // still clean up even on error
        return;
      }

      final dir = Directory(''); // replace
      final path = '${dir.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);

      debugPrint('File saved: $path (from $sender, transfer $transferId)');

      onComplete(); // Clean up the map entry
    } catch (e) {
      debugPrint('Failed to save file $filename: $e');
      onComplete(); // Clean up anyway
    }
  }
}
