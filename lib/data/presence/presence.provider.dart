import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/peer_network/webrtc/webrtc.providers.dart';
import 'package:tribu/data/presence/presence.model.dart';
import 'package:tribu/data/presence/presence_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';

final presenceListProvider =
    StateNotifierProvider.family<PresenceListNotifier, List<Presence>, String>(
        (ref, tribuId) {
  final webRtcManager = ref.watch(webrtcManagerProvider);
  final tribuListNotifier = ref.watch(tribuListProvider.notifier);
  final tribuIdSelectedNotifier = ref.watch(tribuIdSelectedProvider.notifier);
  final notifier = PresenceListNotifier(
      tribuId, webRtcManager, tribuListNotifier, tribuIdSelectedNotifier,);

  ref.onDispose(notifier.dispose);
  return notifier;
});
