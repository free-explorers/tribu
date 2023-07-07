import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tribu/data/peer_network/websocket/websocket.manager.dart';

final websocketManagerProvider = Provider<WebSocketManager>((ref) {
  return WebSocketManager();
});
