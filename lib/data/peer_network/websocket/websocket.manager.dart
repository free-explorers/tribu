import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/peer_network/encrypted_message.model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  factory WebSocketManager() {
    final channel = WebSocketChannel.connect(
      Uri.parse(
        'wss://signaling.trbu.app?id=${FirebaseAuth.instance.currentUser!.uid}',
      ),
    );

    return WebSocketManager._(channel);
  }

  WebSocketManager._(this.channel) {
    channel.stream.listen((json) {
      _messageStreamController.add(
        EncryptedMessage.fromJson(
          jsonDecode(json as String) as Json,
        ),
      );
    });
  }
  final WebSocketChannel channel;
  final StreamController<EncryptedMessage> _messageStreamController =
      StreamController.broadcast();

  Stream<EncryptedMessage> get messageStream {
    return _messageStreamController.stream;
  }

  void send(EncryptedMessage message) {
    channel.sink.add(jsonEncode(message.toJson()));
  }
}
