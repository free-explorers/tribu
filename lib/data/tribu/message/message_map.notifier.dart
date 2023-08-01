import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/media/media.manager.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/data/tribu/message/message.providers.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/main.router.dart';
import 'package:tribu/storage.dart';
import 'package:tribu/utils/encryption/encryption.dart';
import 'package:tribu/widgets/confirm_dialog.dart';

class MessageMapNotifier extends StateNotifier<Map<String, Message>>
    with Manager, WidgetsBindingObserver {
  factory MessageMapNotifier({
    required String tribuId,
    required String encryptionKey,
    required ProfileListNotifier profileManager,
    required MediaManager mediaManager,
    required TribuListNotifier tribuListNotifier,
  }) {
    final manager = MessageMapNotifier._(
      tribuId,
      encryptionKey,
      profileManager,
      mediaManager,
      tribuListNotifier,
    );

    return manager;
  }
  MessageMapNotifier._(
    this.tribuId,
    this.encryptionKey,
    this.profileManager,
    this.mediaManager,
    this.tribuListNotifier,
  ) : super({}) {
    WidgetsBinding.instance.addObserver(this);
    onDisposeList.add(() => WidgetsBinding.instance.removeObserver(this));
    initialized = initialize();
  }
  final String tribuId;
  final String encryptionKey;
  final ProfileListNotifier profileManager;
  final MediaManager mediaManager;
  final TribuListNotifier tribuListNotifier;
  late Box<Message> messageBox;
  late Future<bool> initialized;
  late StreamSubscription<QuerySnapshot<Message>> _firestoreStreamSubscription;

  Future<bool> initialize() async {
    messageBox = await Storage.getHiveBox<Message>('${tribuId}MessageList');
    onDisposeList.add(() {
      //messageBox.close();
    });

    await checkBackgroundMessageList();
    state = (messageBox.toMap()
          ..removeWhere((key, value) {
            if (['error', 'processingMedia'].contains(value.status)) {
              messageBox.delete(key);
              return true;
            }
            return false;
          }))
        .map(
      (k, e) => MapEntry(
        k.toString(),
        e,
      ),
    );

    if (state.isEmpty) {
      await profileManager.initialized;
      final profileList = profileManager.value;
      final msg = createTribuMessage(
        profileList.length == 1
            ? S.current.welcomeMessageFirstMember
            : S.current.welcomeMessageWithExistingMembers,
        id: 'welcomeMsg',
      );
      unawaited(receiveNewMessage(msg));
    }

    Future<void> fetchLastMessages() async {
      var collection = getCollection(tribuId, encryptionKey)
          .where('author', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('sentAt');
      final storage = await Storage.getSharedPreferences();
      final lastFetchMs = storage.getInt('${tribuId}_messages_fetched_at');
      if (lastFetchMs != null) {
        collection = collection
            .startAfter([DateTime.fromMillisecondsSinceEpoch(lastFetchMs)]);
      }

      final firestoreStream = collection.snapshots();

      _firestoreStreamSubscription = firestoreStream.listen((list) {
        if (list.docs.isEmpty) return;
        for (final element in list.docs) {
          receiveNewMessage(element.data());
        }
        storage.setInt(
          '${tribuId}_messages_fetched_at',
          list.docs.last.data().sentAt.millisecondsSinceEpoch,
        );
        _firestoreStreamSubscription.cancel();
        fetchLastMessages();
      });
    }

    await fetchLastMessages();
    onDisposeList.add(_firestoreStreamSubscription.cancel);
    return true;
  }

  Future<void> checkBackgroundMessageList() async {
    final backgroundMessageBox = await Storage.getHiveBox<Message>(
      '${tribuId}BackgroundMessageList',
      track: true,
    );
    if (backgroundMessageBox.isNotEmpty) {
      for (final message in backgroundMessageBox.values) {
        // dont wait this because it's wait for initialized it self that loop
        unawaited(receiveNewMessage(message));
      }
      await backgroundMessageBox.clear();
    }
    await Storage.closeHiveBox(backgroundMessageBox, track: true);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    await initialized;
    if (state == AppLifecycleState.resumed) {
      await checkBackgroundMessageList();
      _firestoreStreamSubscription.resume();
    } else {
      if (!_firestoreStreamSubscription.isPaused) {
        _firestoreStreamSubscription.pause();
      }
    }
  }

  Future<Message> createEmptyMessage() async {
    final authorId = FirebaseAuth.instance.currentUser!.uid;
    final receivedBy = <String, bool>{};
    final tribu = await tribuListNotifier.getTribu(tribuId);
    for (final userId in tribu!.authorizedMemberList) {
      receivedBy.putIfAbsent(userId, () => userId == authorId);
    }
    return Message(
      id: getCollection(tribuId, await EncryptionManager.getKey(tribuId))
          .doc()
          .id,
      author: authorId,
      text: '',
      status: 'toSend',
      sentAt: DateTime.now(),
      receivedBy: receivedBy,
    );
  }

  Future<void> createMessage(String text) async {
    final message = (await createEmptyMessage()).copyWith(text: text);
    updateMessageLocally(message);
    await sendMessage(message);
  }

  Future<void> createMediaMessage(List<String> pathList) async {
    final message = (await createEmptyMessage()).copyWith(
      mediaList: [],
      status: 'processingMedia',
      text: pathList.length > 1 ? '📷 x${pathList.length}' : '📷',
    );
    updateMessageLocally(message);
    final processedMediaList = await Future.wait(
      pathList.map(mediaManager.processPathToMedia).toList(),
    );
    await sendMessage(message.copyWith(mediaList: processedMediaList));
  }

  Future<void> sendMessage(Message messageToSend) async {
    var message = messageToSend;
    void onError(error) {
      updateMessageLocally(message.copyWith(status: 'error'));
    }

    message = message.copyWith(status: 'inProgress');
    updateMessageLocally(message);

    if (message.mediaList != null && message.mediaList!.isNotEmpty) {
      final mediaNotSentList =
          message.mediaList!.where((media) => media.remoteUrl == null);
      final promiseList = <Future<dynamic>>[];
      for (final media in mediaNotSentList) {
        final promise = mediaManager.uploadMedia(media).then((uploadedMedia) {
          message = message.copyWith(
            mediaList: [
              ...message.mediaList!.map(
                (existingMedia) =>
                    uploadedMedia.localPath == existingMedia.localPath
                        ? uploadedMedia
                        : existingMedia,
              )
            ],
          );
        });
        promiseList.add(promise);
      }
      try {
        await Future.wait(promiseList);
      } catch (e) {
        return onError(e);
      }
    }
    final DocumentReference futureMessageRef =
        getCollection(tribuId, await EncryptionManager.getKey(tribuId)).doc();
    try {
      await futureMessageRef.set(message);
      message = message.copyWith(status: 'sent');
      updateMessageLocally(message);
    } catch (e) {
      onError(e);
      rethrow;
    }
  }

  void updateMessageLocally(Message message) {
    messageBox.put(message.id, message);
    state[message.id!] = message;
    state = Map.from(state);
  }

  void removeMessageLocally(Message message) {
    messageBox.delete(message.id);
    state.remove(message.id);
    state = Map.from(state);
  }

  static Message createTribuMessage(String text, {required String id}) {
    return Message(
      id: id,
      author: 'tribu',
      status: 'sent',
      text: text,
      sentAt: DateTime.now(),
    );
  }

  static Message createNewMemberMessage(Profile newMember) {
    return createTribuMessage(
      S.current.newMemberNotificationContent(newMember.name),
      id: 'newMember${newMember.id}',
    );
  }

  Future<void> receiveNewMessage(Message newMessage) async {
    await initialized;
    var message = newMessage;
    if (!messageBox.containsKey(message.id)) {
      await messageBox.put(message.id, message);
      state[message.id!] = message;
      state = Map.from(state);
    }
    void onError(error) {
      message = message.copyWith(status: 'error');
      updateMessageLocally(message);
    }

    if (message.author == 'tribu') return;
    if (message.receivedBy![FirebaseAuth.instance.currentUser!.uid] == false) {
      try {
        await markMessageAsReceived(tribuId, message.id!);
        updateMessageLocally(message.copyWith(status: 'received'));
      } catch (e) {
        return onError(e);
      }
    }
  }

  void downloadMediaForMessage(String messageId, Media media) {
    var message = messageBox.get(messageId);
    if (message != null &&
        message.mediaList != null &&
        message.mediaList!.contains(media)) {
      mediaManager.downloadMedia(media).then((downloadedMedia) {
        final updatedMessage = state[messageId];
        message = updatedMessage!.copyWith(
          mediaList: [
            ...updatedMessage.mediaList!.map(
              (existingMedia) =>
                  downloadedMedia.remoteUrl == existingMedia.remoteUrl
                      ? downloadedMedia
                      : existingMedia,
            )
          ],
        );

        updateMessageLocally(message!);
      });
    }
  }

  static Future<void> markMessageAsReceived(
    String tribuId,
    String messageId,
  ) async {
    await getCollection(tribuId, await EncryptionManager.getKey(tribuId))
        .doc(messageId)
        .update({'receivedBy.${FirebaseAuth.instance.currentUser!.uid}': true});
  }

  static void showSelectedMessageModal(
    BuildContext context,
    WidgetRef ref,
    Message message,
  ) {
    showTribuBottomModal<dynamic>(
      context,
      ref,
      (p0) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /* Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['👍', '❤️', '🥳', '😆', '😮', '😢']
              .map((e) => Card(
                    child: IconButton(
                      onPressed: () {},
                      icon: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(
          height: 24,
        ), */
          Card(
            child: ListTile(
              leading: Icon(MdiIcons.contentCopy),
              title: Text(S.of(context).copyAction),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: message.text));
                // ignore: use_build_context_synchronously
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Card(
            child: ListTile(
              leading: Icon(MdiIcons.delete),
              title: Text(S.of(context).removeMessageAction),
              onTap: () async {
                await showDialog<ConfirmDialog>(
                  context: context,
                  builder: (_) => ConfirmDialog(() async {
                    ref
                        .read(
                          messageMapProvider(
                            ref.read(tribuIdSelectedProvider)!,
                          ).notifier,
                        )
                        .removeMessageLocally(message);
                  }),
                );

                // ignore: use_build_context_synchronously
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          )
        ],
      ),
      title: S.of(context).messageSelectedTitle,
    );
  }

  static CollectionReference<Message> getCollection(
    String tribuId,
    String encryptionKey,
  ) {
    return FirebaseFirestore.instance
        .collection('tribuList')
        .doc(tribuId)
        .collection('messageList')
        .withConverter<Message>(
          fromFirestore: (snapshot, _) => Message.fromJson(
            Message.decryptJson(
              snapshot.data()!..putIfAbsent('id', () => snapshot.id),
              encryptionKey,
            ),
          ),
          toFirestore: (message, _) {
            final json = message.toJson()..remove('id');
            if (json.containsKey('mediaList') && json['mediaList'] != null) {
              json.update('mediaList', (mediaList) {
                for (final mediaJson
                    in mediaList as List<Map<String, dynamic>>) {
                  mediaJson.remove('localPath');
                }
                return mediaList;
              });
            }
            json.update(
              'sentAt',
              (value) => json['status'] == 'toSend'
                  ? FieldValue.serverTimestamp()
                  : value,
            );
            return EncryptionManager.encryptFields(
              json,
              ['text'],
              encryptionKey,
            );
          },
        );
  }
}
