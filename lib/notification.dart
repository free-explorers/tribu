import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/data/tribu/message/message.model.dart' as tribu_message;
import 'package:tribu/data/tribu/message/message_map.notifier.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.model.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/storage.dart';
import 'package:tribu/utils/encryption/encryption.dart';
import 'package:tribu/utils/firebase.service.dart';

class NotificationTool {
  static Future<FlutterLocalNotificationsPlugin> initiatePlugin({
    void Function(NotificationResponse)? onSelectNotification,
  }) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable
    // resource to the Android head project
    const initializationSettingsAndroid =
        AndroidInitializationSettings('logo_pad_bottom');
    const initializationSettingsIos = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIos,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
    return flutterLocalNotificationsPlugin;
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // If you're going to use other Firebase services in the background,
    // such as Firestore, make sure you call `initializeApp`
    // before using other Firebase services.
    await Hive.initFlutter();
    final secureStorage = await Storage.getSecureStorage();

    final localeString = await secureStorage.read(key: 'locale') ?? '';

    await S.load(Locale(localeString));

    final messageAdapter = tribu_message.MessageAdapter();
    if (!Hive.isAdapterRegistered(messageAdapter.typeId)) {
      Hive.registerAdapter<tribu_message.Message>(messageAdapter);
    }

    final mediaAdapter = MediaAdapter();
    if (!Hive.isAdapterRegistered(mediaAdapter.typeId)) {
      Hive.registerAdapter<Media>(mediaAdapter);
    }

    await FirebaseService.instance.init();

    final notificationPlugin = await initiatePlugin();
    for (var i = 0; i < 20; i++) {}

    await handleNotification(notificationPlugin, message);
  }

  static Future<void> handleNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    RemoteMessage remoteMessage,
  ) async {
    switch (remoteMessage.data['type']) {
      case 'message':
        await handleMessageNotification(notificationPlugin, remoteMessage);

      case 'newMember':
        await handleNewMemberNotification(notificationPlugin, remoteMessage);
    }
  }

  static Future<void> handleMessageNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    RemoteMessage remoteMessage,
  ) async {
    final tribuId = remoteMessage.data['tribuId'] as String;
    final tribu = await getTribu(tribuId);

    final encryptionKey = await EncryptionManager.getKey(tribuId);

    final messageJson =
        (jsonDecode(remoteMessage.data['json'] as String) as Json)
          ..update(
            'sentAt',
            (value) {
              value = value as Map<String, dynamic>;
              return Timestamp(
                value['_seconds']! as int,
                value['_nanoseconds']! as int,
              );
            },
          );

    final tribuMessage = tribu_message.Message.fromJson(
      tribu_message.Message.decryptJson(
        messageJson..putIfAbsent('id', () => remoteMessage.data['id']),
        encryptionKey,
      ),
    );

    final profileManager = ProfileListNotifier(tribuId, encryptionKey);

    await profileManager.initialized;

    final backgroundMessageBox =
        await Storage.getHiveBox<tribu_message.Message>(
      '${tribuId}BackgroundMessageList',
      track: true,
    );
    await MessageMapNotifier.markMessageAsReceived(tribuId, tribuMessage.id!);

    await backgroundMessageBox.put(
      tribuMessage.id,
      tribuMessage.copyWith(
        receivedBy: Map.from(tribuMessage.receivedBy!)
          ..update(
            FirebaseAuth.instance.currentUser!.uid,
            (value) => true,
          ),
      ),
    );

    final unReadMessageList = backgroundMessageBox.values
        .where((element) => element.author != 'tribu')
        .toList()
      ..sortBy((element) => element.sentAt);

    if (unReadMessageList.isNotEmpty) {
      final pref = await SharedPreferences.getInstance();
      await pref.setInt(
        '${tribuId}UnReadCounter',
        pref.getInt('${tribuId}UnReadCounter') ?? 0 + 1,
      );
      showMessageNotification(
        notificationPlugin,
        tribu!,
        unReadMessageList,
        profileManager,
      );
    }
    await Storage.closeHiveBox(backgroundMessageBox, track: true);
    profileManager.dispose();
  }

  static void showMessageNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    Tribu tribu,
    List<tribu_message.Message> messageList,
    ProfileListNotifier profileListNotifier,
  ) {
    final lastMessageAuthor = messageList.last.author;
    final lastMessageProfile =
        profileListNotifier.getProfile(lastMessageAuthor);
    final lastAuthorName = lastMessageProfile.name;
    final lastMessagePerson =
        Person(name: lastAuthorName, key: lastMessageAuthor);

    //MessagingStyleInformation
    final messagingStyle = MessagingStyleInformation(
      lastMessagePerson,
      groupConversation: true,
      conversationTitle: tribu.name,
      htmlFormatContent: true,
      htmlFormatTitle: true,
      messages: messageList.map((message) {
        final profile = profileListNotifier.getProfile(message.author);
        return Message(
          message.text,
          message.sentAt,
          Person(
            name: profile.name,
            key: message.author,
          ),
        );
      }).toList(),
    );

    //AndroidNotificationDetails
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'msg',
      S.current.chatNotificationTitle,
      channelDescription: S.current.chatNotificationDescription,
      priority: Priority.max,
      importance: Importance.max,
      category: AndroidNotificationCategory.message,
      styleInformation: messagingStyle,
    );

    final iOSNotificationDetails = DarwinNotificationDetails(
      threadIdentifier: tribu.id,
      subtitle: lastAuthorName,
    );

    //NotificationDetails
    final notificationDetail = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSNotificationDetails,
    );

    notificationPlugin.show(
      Platform.isAndroid ? tribu.id.hashCode : Random().nextInt(10000),
      tribu.name,
      messageList.last.text,
      notificationDetail,
      payload: tribu.id,
    );
  }

  static Future<void> handleNewMemberNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    RemoteMessage remoteMessage,
  ) async {
    final tribuId = remoteMessage.data['tribuId'] as String;
    final tribu = await getTribu(tribuId);

    final encryptionKey = await EncryptionManager.getKey(tribuId);

    final profileJson =
        (jsonDecode(remoteMessage.data['json'] as String) as Json)
          ..update(
            'createdAt',
            (value) {
              value = value as Map<String, dynamic>;
              return Timestamp(
                value['_seconds']! as int,
                value['_nanoseconds']! as int,
              );
            },
          );
    final newMember = Profile.fromJson(
      EncryptionManager.decryptFields(
        profileJson..putIfAbsent('id', () => remoteMessage.data['id']),
        ['name'],
        encryptionKey,
      ),
    );

    final message = MessageMapNotifier.createNewMemberMessage(newMember);
    final backgroundMessageBox =
        await Storage.getHiveBox<tribu_message.Message>(
      '${tribuId}BackgroundMessageList',
      track: true,
    );

    await backgroundMessageBox.put(message.id, message);
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(
      '${tribuId}UnReadCounter',
      pref.getInt('${tribuId}UnReadCounter') ?? 0 + 1,
    );
    showNewMemberNotification(notificationPlugin, tribu!, newMember);
    await Storage.closeHiveBox(backgroundMessageBox, track: true);
  }

  static void showNewMemberNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    Tribu tribu,
    Profile newMember,
  ) {
    //MessagingStyleInformation

    //AndroidNotificationDetails
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'newMember',
      S.current.newMemberNotificationTitle,
      channelDescription: S.current.newMemberNotificationDescription,
    );

    const iosNotificationDetails = DarwinNotificationDetails();

    //NotificationDetails
    final notificationDetail = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails,
    );

    notificationPlugin.show(
      Platform.isAndroid ? tribu.id.hashCode : Random().nextInt(10000),
      tribu.name,
      S.current.newMemberNotificationContent(newMember.name),
      notificationDetail,
      payload: tribu.id,
    );
  }

  static Future<Tribu?> getTribu(String tribuId) async {
    return TribuListNotifier.getCollection()
        .doc(tribuId)
        .get()
        .then((value) => value.data());
  }
}
