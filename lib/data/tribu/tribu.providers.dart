import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/media/media.manager.dart';
import 'package:tribu/data/media/media_in_transition.model.dart';
import 'package:tribu/data/peer_network/webrtc/webrtc.providers.dart';
import 'package:tribu/data/presence/presence.provider.dart';
import 'package:tribu/data/storage.providers.dart';
import 'package:tribu/data/tribu/message/message.providers.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.model.dart';
import 'package:tribu/data/tribu/tribu_info.model.dart';
import 'package:tribu/data/tribu/tribu_info_list.notifier.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';
import 'package:tribu/utils/encryption/encryption.dart';
import 'package:tribu/utils/transfer_task.notifier.dart';

const tribuBoxName = 'tribuList';

class TribuIdSelectedNotifier extends StateNotifier<String?> {
  factory TribuIdSelectedNotifier(
    TribuInfoMapNotifier tribuInfoMapNotifier,
    Box<String> box,
  ) {
    return TribuIdSelectedNotifier._(
      hiveBox: box,
      tribuId: box.get('tribuIdSelected'),
      tribuInfoMapNotifier: tribuInfoMapNotifier,
    );
  }
  TribuIdSelectedNotifier._({
    required this.tribuId,
    required this.hiveBox,
    required this.tribuInfoMapNotifier,
  }) : super(tribuId);
  String? get value => state;

  final String? tribuId;
  final TribuInfoMapNotifier tribuInfoMapNotifier;
  final Box<String> hiveBox;
  Future<void> setTribuId(String? tribuId) async {
    if (tribuId == null) {
      await hiveBox.delete('tribuIdSelected');
    } else {
      await hiveBox.put('tribuIdSelected', tribuId);
    }
    state = tribuId;
  }

  Future<void> setLastActiveTribu() async {
    final tribuInfoList = tribuInfoMapNotifier.getList()
      ..sortBy((element) => element.lastRead);
    if (tribuInfoList.length == 1) {
      return setTribuId(null);
    }
    final lastActiveTribuId = tribuInfoList
        .firstWhere((tribuInfo) => tribuInfo.tribuId != state)
        .tribuId;

    await setTribuId(lastActiveTribuId);
    /* if (tribuIdSelectedNotifier.value == tribuId) {
      if (tribuListNotifier.state.length > 1) {
        final currentIndex = state.indexOf(tribu);
        final nextIndex = currentIndex < state.length - 1
            ? currentIndex + 1
            : currentIndex - 1;
        tribuIdSelectedNotifier.setTribuId(state.elementAt(nextIndex).id);
      } else {
        tribuIdSelectedNotifier.setTribuId(null);
      }
    } */
  }
}

final tribuIdSelectedProvider =
    StateNotifierProvider<TribuIdSelectedNotifier, String?>(
  (ref) => throw Exception('Provider was not initialized'),
);

final tribuSelectedProvider = Provider((ref) {
  final tribuIdSelected = ref.watch(tribuIdSelectedProvider);
  if (tribuIdSelected == null) return null;
  return ref.watch(tribuProvider(tribuIdSelected));
});

final tribuListProvider = StateNotifierProvider<TribuListNotifier, List<Tribu>>(
  (ref) => throw Exception('Provider was not initialized'),
);
final tribuInfoMapProvider =
    StateNotifierProvider<TribuInfoMapNotifier, Map<String, TribuInfo>>(
  (ref) => throw Exception('Provider was not initialized'),
);

final keepAliveTribuProvider = StateProvider.family<KeepAliveLink?, String>(
  (ref, tribuId) => null,
);
final initializeTribuProvider =
    FutureProvider.family.autoDispose((ref, String tribuId) async {
  ref.read(tribuEncryptionKeyProvider(tribuId).notifier).state =
      await EncryptionManager.getKey(tribuId);
  ref.read(keepAliveTribuProvider(tribuId).notifier).state = ref.keepAlive();
  final profileListNotifier = ref.watch(profileListProvider(tribuId).notifier);
  final messageMapNotifier = ref.watch(messageMapProvider(tribuId).notifier);
  // ignore: unused_local_variable
  final toolsPageNotifier = ref.watch(toolPageListProvider(tribuId).notifier);
  // ignore: unused_local_variable
  final webrtcManagerManager = ref.watch(webrtcManagerProvider);
  await webrtcManagerManager
      .initiatePeerConnections(ref.read(tribuProvider(tribuId))!);
  // ignore: unused_local_variable
  final presenceListNotifier =
      ref.watch(presenceListProvider(tribuId).notifier);
  final notificationPlugin = ref.watch(notificationPluginProvider);
  if (Platform.isIOS) {
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  await Future.wait(
    [profileListNotifier.initialized, messageMapNotifier.initialized],
  );

  ref
    ..watch(messageNotificationObserver(tribuId))
    ..watch(profileNotificationObserver(tribuId));

  ref.watch(tribuIdLoadedMapProvider)[tribuId] = true;
  return true;
});

final tribuProvider = Provider.family<Tribu?, String>((ref, tribuId) {
  final tribuList = ref.watch(tribuListProvider);
  return tribuList.firstWhereOrNull((element) => element.id == tribuId);
});

final tribuEncryptionKeyProvider =
    StateProvider.family<String?, String>((ref, tribuId) => null);

final mediaManagerProvider = StateNotifierProvider.family<MediaManager,
    Map<String, MediaInTransition>, String>((ref, String tribuId) {
  return MediaManager(
    tribuId,
    ref.watch(tribuEncryptionKeyProvider(tribuId))!,
    ref.watch(transferTaskManagerProvider.notifier),
    ref.watch(temporaryDirectoryProvider),
    ref.watch(permanentDirectoryProvider),
  );
});
