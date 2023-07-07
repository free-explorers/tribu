import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/peer_network/webrtc/webrtc.manager.dart';
import 'package:tribu/data/peer_network/websocket/websocket.provider.dart';

final webrtcManagerProvider = Provider<WebrtcManager>((ref) {
  final websocketManager = ref.watch(websocketManagerProvider);
  final manager = WebrtcManager(websocketManager);
  return manager;
});
