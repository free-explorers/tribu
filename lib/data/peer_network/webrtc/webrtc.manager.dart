import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/peer_network/decrypted_message.model.dart';
import 'package:tribu/data/peer_network/encrypted_message.model.dart';
import 'package:tribu/data/peer_network/webrtc/connection_status.model.dart';
import 'package:tribu/data/peer_network/websocket/websocket.manager.dart';
import 'package:tribu/data/tribu/tribu.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

class WebrtcManager with WidgetsBindingObserver {
  WebrtcManager(this.webSocketManager) {
    WidgetsBinding.instance.addObserver(this);
    webSocketManager.messageStream.listen(onWebSocketMessage);
  }
  final WebSocketManager webSocketManager;
  static Map<String, ConnectionDetail> userConnectionMap = {};

  final StreamController<DecryptedMessage> _eventController =
      StreamController.broadcast();

  Stream<DecryptedMessage> get eventStream => _eventController.stream;

  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController.broadcast();

  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  Stream<DecryptedMessage> messageStreamFrom(String userId) {
    return eventStream.where((event) => event.fromUserId == userId);
  }

  Future<void> initiatePeerConnections(Tribu tribu) async {
    for (final userId in tribu.authorizedMemberList
        .where((userId) => userId != FirebaseAuth.instance.currentUser!.uid)) {
      if (!userConnectionMap.containsKey(userId)) {
        await makeOffer(userId, tribu.id!);
      }
    }
  }

  Future<void> onWebSocketMessage(EncryptedMessage message) async {
    final encryptionKey = await EncryptionManager.getKey(message.tribuId);
    final decryptedData =
        EncryptionManager.decrypt(message.encryptedContent, encryptionKey);
    final json = jsonDecode(decryptedData) as Json;
    final payload = jsonDecode(json['payload'] as String) as Json;
    switch (json['class']) {
      case 'RtcSessionDescription':
        final description = RTCSessionDescription(
          payload['sdp'] as String,
          payload['type'] as String,
        );
        if (description.type == 'offer') {
          await onOffer(message.fromUserId, message.tribuId, description);
        } else if (description.type == 'answer') {
          await onAnswer(message.fromUserId, description);
        }
      case 'RTCIceCandidate':
        final candidate = RTCIceCandidate(
          payload['candidate'] as String?,
          payload['sdpMid'] as String?,
          payload['sdpMLineIndex'] as int?,
        );
        await onCandidate(message.fromUserId, candidate);
    }
  }

  Future<void> sendWebSocketMessage(
    String userId,
    String tribuId,
    Map<String, dynamic> data,
  ) async {
    final encryptionKey = await EncryptionManager.getKey(tribuId);

    webSocketManager.send(
      EncryptedMessage(
        forUserId: userId,
        fromUserId: FirebaseAuth.instance.currentUser!.uid,
        tribuId: tribuId,
        encryptedContent:
            EncryptionManager.encrypt(jsonEncode(data), encryptionKey),
      ),
    );
  }

  Future<void> initiateNewConnection(String forUserId) async {
    if (userConnectionMap.containsKey(forUserId)) {
      await clearConnection(forUserId);
    }
    final completer = Completer<bool>();
    userConnectionMap[forUserId] =
        ConnectionDetail(userId: forUserId, ready: completer.future);

    final pc = await createPeerConnection(configuration, loopbackConstraints);

    pc.onSignalingState = (RTCSignalingState state) {};

    final dataChannel = await pc.createDataChannel(
      'data',
      RTCDataChannelInit()..negotiated = true,
    );

    final subscription = dataChannel.messageStream.listen(
      (RTCDataChannelMessage message) => onNewMessage(
        EncryptedMessage.fromJson(
          jsonDecode(message.text) as Json,
        ),
      ),
    );

    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      _connectionStatusController
          .add(ConnectionStatus(state: state, userId: forUserId));
    };

    pc.onRenegotiationNeeded =
        () => pc.onIceConnectionState = (RTCIceConnectionState state) {
              if (state ==
                      RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
                  state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
                  state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
                clearConnection(forUserId);
              }
            };
    userConnectionMap[forUserId]!.peerConnection = pc;
    userConnectionMap[forUserId]!.dataChannel = dataChannel;
    userConnectionMap[forUserId]!.subscription = subscription;
    completer.complete(true);
  }

  Future<void> onOffer(
    String userId,
    String tribuId,
    RTCSessionDescription description,
  ) async {
    await initiateNewConnection(userId);
    await makeAnswer(userId, tribuId, description);
  }

  Future<void> onAnswer(
    String userId,
    RTCSessionDescription description,
  ) async {
    final connectionDetail = userConnectionMap[userId]!;
    await connectionDetail.peerConnection!
        .setLocalDescription(connectionDetail.offerDescription!);
    await connectionDetail.peerConnection!.setRemoteDescription(description);
  }

  Future<void> onCandidate(String userId, RTCIceCandidate candidate) async {
    final connectionDetail = userConnectionMap[userId];
    if (connectionDetail != null) {
      await connectionDetail.ready;
      await connectionDetail.peerConnection!.addCandidate(candidate);
    }
  }

  Future<void> clearConnection(String userId) async {
    if (!userConnectionMap.containsKey(userId)) return;
    final connectionDetail = userConnectionMap[userId]!;
    userConnectionMap.remove(userId);
    await connectionDetail.subscription?.cancel();
    await connectionDetail.dataChannel?.close();
    await connectionDetail.peerConnection?.dispose();
  }

  bool isConnectionViable(String userId) {
    final connection = userConnectionMap[userId];
    if (connection == null) {
      return false;
    } else {
      return connection.dataChannel?.state ==
          RTCDataChannelState.RTCDataChannelOpen;
    }
  }

  Future<void> makeOffer(String userId, String tribuId) async {
    await initiateNewConnection(userId);
    final connectionDetail = userConnectionMap[userId]!;

    connectionDetail.offerDescription =
        await connectionDetail.peerConnection!.createOffer(offerSdpConstraints);

    // Gather candidates
    connectionDetail.peerConnection!.onIceCandidate = (RTCIceCandidate state) {
      if (state.candidate == null) return;
      final data = {
        'class': 'RTCIceCandidate',
        'payload': jsonEncode(state.toMap())
      };
      sendWebSocketMessage(userId, tribuId, data);
    };

    final data = {
      'class': 'RtcSessionDescription',
      'payload': jsonEncode(connectionDetail.offerDescription!.toMap())
    };

    await sendWebSocketMessage(userId, tribuId, data);
  }

  Future<void> makeAnswer(
    String userId,
    String tribuId,
    RTCSessionDescription offerDescription,
  ) async {
    final connectionDetail = userConnectionMap[userId]!;

    // Gather candidates
    connectionDetail.peerConnection!.onIceCandidate = (RTCIceCandidate state) {
      if (state.candidate == null) return;
      final data = {
        'class': 'RTCIceCandidate',
        'payload': jsonEncode(state.toMap())
      };
      sendWebSocketMessage(userId, tribuId, data);
    };

    // Fetch data, then set the offer & answer

    await connectionDetail.peerConnection!
        .setRemoteDescription(offerDescription);

    final answerDescription =
        await connectionDetail.peerConnection!.createAnswer();

    await connectionDetail.peerConnection!
        .setLocalDescription(answerDescription);

    final data = {
      'class': 'RtcSessionDescription',
      'payload': jsonEncode(answerDescription.toMap())
    };

    await sendWebSocketMessage(userId, tribuId, data);
  }

  Future<void> onNewMessage(EncryptedMessage message) async {
    // This will be needed if we want to use graph like network mesh
    /* final isNewMessage = idBuffer.handle(peerMessage.id);
    if (!isNewMessage) return;
    broadcastMessage(message, from); */
    final encryptionKey = await EncryptionManager.getKey(message.tribuId);
    _eventController.add(DecryptedMessage.decrypt(message, encryptionKey));
  }

  Future<void> send(DecryptedMessage message) async {
    if (!isConnectionViable(message.forUserId)) return;
    final encryptionKey = await EncryptionManager.getKey(message.tribuId);

    if (userConnectionMap[message.forUserId] != null) {
      await userConnectionMap[message.forUserId]!.dataChannel!.send(
            RTCDataChannelMessage(
              jsonEncode(
                EncryptedMessage.encrypt(message, encryptionKey).toJson(),
              ),
            ),
          );
    }
  }

  /* Future<void> broadcastMessage(EncryptedMessage message,
      [RTCPeerConnection? exclude]) {
    /* connectionMap.forEach((key, connection) {
      if (exclude == null || key != exclude.hashCode) {
        connection.dataChannel
            .send(RTCDataChannelMessage(jsonEncode(message.toJson())));
      }
    }); */
  } */

  static const configuration = <String, dynamic>{
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ],
      },
    ]
  };

  static const offerSdpConstraints = <String, dynamic>{
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': <dynamic>[],
  };

  static const loopbackConstraints = <String, dynamic>{
    'mandatory': <String, dynamic>{},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };
}

class ConnectionDetail {
  ConnectionDetail({
    required this.userId,
    required this.ready,
    this.peerConnection,
    this.dataChannel,
    this.subscription,
  });
  RTCPeerConnection? peerConnection;
  RTCSessionDescription? offerDescription;
  RTCDataChannel? dataChannel;
  StreamSubscription<RTCDataChannelMessage>? subscription;
  final Future<bool> ready;
  final String userId;
}
