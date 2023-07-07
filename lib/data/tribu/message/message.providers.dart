import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/presence/presence.provider.dart';
import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/data/tribu/message/message_map.notifier.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/notification.dart';

final messageMapProvider = StateNotifierProvider.family
    .autoDispose<MessageMapNotifier, Map<String, Message>, String>(
        (ref, tribuId) {
  final encryptionKey = ref.watch(tribuEncryptionKeyProvider(tribuId))!;
  final profileListNotifier = ref.watch(profileListProvider(tribuId).notifier);
  final mediaManager = ref.watch(mediaManagerProvider(tribuId).notifier);
  final tribuListNotifier = ref.watch(tribuListProvider.notifier);
  final notifier = MessageMapNotifier(
      tribuId: tribuId,
      encryptionKey: encryptionKey,
      profileManager: profileListNotifier,
      mediaManager: mediaManager,
      tribuListNotifier: tribuListNotifier,);
  ref.onDispose(notifier.dispose);

  return notifier;
});

final messageListProvider = Provider.family.autoDispose<List<Message>, String>(
  (ref, tribuId) {
    final messageMap = ref.watch(messageMapProvider(tribuId));
    return messageMap.values.toList()
      ..sort((Message messageA, Message messageB) =>
          messageB.sentAt.compareTo(messageA.sentAt),);
  },
);

final messageNotificationObserver =
    Provider.family.autoDispose((ref, String tribuId) {
  ref.listen(messageListProvider(tribuId),
      (previous, List<Message> messageList) {
    final tribuIdSelected = ref.read(tribuIdSelectedProvider);
    final profileListNotifier = ref.read(profileListProvider(tribuId).notifier);
    final myPresence =
        ref.read(presenceListProvider(tribuId).notifier).myPresence;
    final currentUser = ref.read(currentUserProvider);
    final notificationPlugin = ref.read(notificationPluginProvider);
    final tribuInfoMapNotifier = ref.read(tribuInfoMapProvider.notifier);
    final tribuInfo = tribuInfoMapNotifier.get(tribuId)!;
    if (tribuIdSelected == tribuId &&
        myPresence.route == 'chat' &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      tribuInfoMapNotifier
          .updateTribuInfo(tribuInfo.copyWith(lastRead: DateTime.now()));
    } else {
      final unReadMessageList = messageList
          .where((unreadMessage) =>
              unreadMessage.author != currentUser!.uid &&
              unreadMessage.author != 'tribu' &&
              unreadMessage.sentAt.millisecondsSinceEpoch >
                  tribuInfo.lastRead.millisecondsSinceEpoch,)
          .toList()
          .reversed
          .toList();
      if (unReadMessageList.isNotEmpty) {
        tribuInfoMapNotifier.updateTribuInfo(
            tribuInfo.copyWith(unreadMessage: unReadMessageList.length),);
        NotificationTool.showMessageNotification(
            notificationPlugin,
            ref.read(tribuProvider(tribuId))!,
            unReadMessageList,
            profileListNotifier,);
      }
    }
  });

  return null;
});

final unreadMessageCounterOfTribu = Provider.family<int, String>(
  (ref, tribuId) {
    return ref.watch(tribuInfoMapProvider
        .select((value) => value[tribuId]?.unreadMessage ?? 0),);
  },
);
