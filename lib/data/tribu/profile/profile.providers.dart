import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/presence/presence.provider.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/message/message.providers.dart';
import 'package:tribu/data/tribu/message/message_map.notifier.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/notification.dart';

final profileListProvider = StateNotifierProvider.family
    .autoDispose<ProfileListNotifier, List<Profile>, String>((ref, tribuId) {
  final encryptionKey = ref.watch(tribuEncryptionKeyProvider(tribuId))!;
  final notifier = ProfileListNotifier(tribuId, encryptionKey);

  ref.onDispose(notifier.dispose);
  return notifier;
});

final eventAttendeesProfileListProvider =
    Provider.family.autoDispose<List<Profile>, Event>((ref, event) {
  final currentTribuId = ref.watch(tribuIdSelectedProvider)!;
  final profileList = ref.watch(profileListProvider(currentTribuId));
  final confirmedAttendees = event
      .map(
        permanent: (event) =>
            <String, bool?>{for (var profile in profileList) profile.id: true},
        punctual: (event) => event.attendeesMap,
        stay: (event) => event.attendeesMap,
      )
      .entries
      .where((element) => element.value ?? false)
      .map((e) => e.key)
      .toList();
  return profileList
      .where((profile) => confirmedAttendees.contains(profile.id))
      .toList();
});

final profileNotificationObserver =
    Provider.family.autoDispose((ref, String tribuId) {
  final profileNotifier = ref.read(profileListProvider(tribuId).notifier);
  var prevProfileList = ref.read(profileListProvider(tribuId));
  if (prevProfileList.isEmpty) return;
  final me = profileNotifier.getProfile(FirebaseAuth.instance.currentUser!.uid);
  ref
      .watch(profileListProvider(tribuId).notifier)
      .profileListStream
      .listen((profileList) {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      final diffList = profileList
          .where(
            (element) =>
                !prevProfileList.contains(element) &&
                element.external == null &&
                element.createdAt.compareTo(me.createdAt) > 0,
          )
          .toList();
      final tribuIdSelected = ref.read(tribuIdSelectedProvider);
      final myPresence =
          ref.read(presenceListProvider(tribuId).notifier).myPresence;
      final notificationPlugin = ref.read(notificationPluginProvider);
      final messageMapNotifier = ref.read(messageMapProvider(tribuId).notifier);

      for (final profile in diffList) {
        final message = MessageMapNotifier.createNewMemberMessage(profile);
        messageMapNotifier.receiveNewMessage(message);
        if (tribuIdSelected != tribuId || myPresence.route != 'chat') {
          NotificationTool.showNewMemberNotification(
            notificationPlugin,
            ref.read(tribuProvider(tribuId))!,
            profile,
          );
        }
      }
    }

    prevProfileList = profileList;
  });

  return null;
});

final ownProfileProvider =
    Provider.family.autoDispose<Profile, String>((ref, String tribuId) {
  return ref.watch(profileListProvider(tribuId)).firstWhere(
        (profile) => profile.id == ref.watch(currentUserProvider)!.uid,
      );
});
