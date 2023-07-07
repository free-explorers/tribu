import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/presence/presence.provider.dart';
import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/data/tribu/message/message.providers.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/pages/with_tribu/chat/message_in_progress.dart';
import 'package:tribu/pages/with_tribu/chat/other_message.dart';
import 'package:tribu/pages/with_tribu/chat/own_message.dart';
import 'package:tribu/pages/with_tribu/chat/tribu_message.dart';

class ChatMessageListViewer extends HookConsumerWidget {
  const ChatMessageListViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final tribuId = ref.watch(tribuIdSelectedProvider)!;

    final widgetListNotifier =
        ref.watch(chatWidgetDataListFamily(tribuId).notifier);

    ref.listen<List<Message>>(messageListProvider(tribuId), (previous, next) {
      if (previous != null && next.length > previous.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        });
      }
    });

    return ListView.separated(
      controller: scrollController,
      reverse: true,
      shrinkWrap: true,
      itemCount: widgetListNotifier.state.length,
      padding: const EdgeInsets.only(top: 16, bottom: 88),
      separatorBuilder: (context, index) => const SizedBox(
        height: 16,
      ),
      itemBuilder: (context, index) {
        final widgetData = widgetListNotifier.state.elementAt(index) as Json;
        if (widgetData['type'] == 'tribuMessage') {
          return TribuMessage(
            messageList: widgetData['messageList'] as List<Message>,
          );
        } else if (widgetData['type'] == 'ownMessage') {
          return OwnMessage(
            messageList: widgetData['messageList'] as List<Message>,
          );
        } else if (widgetData['type'] == 'chatDate') {
          return Center(
            child: Text(
              DateFormat('d MMMM').add_jm().format(
                    DateTime.fromMillisecondsSinceEpoch(
                      widgetData['timestamp'] as int,
                    ),
                  ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        } else if (widgetData['type'] == 'otherMessage') {
          return OtherMessage(
            messageList: widgetData['messageList'] as List<Message>,
            member: widgetData['profile'] as Profile,
          );
        } else if (widgetData['type'] == 'messageInProgress') {
          return MessageInProgress(
            memberList: widgetData['memberList'] as List<Profile>,
          );
        } else {
          return Text(widgetData['type'] as String);
        }
      },
    );
  }

/*   getWidget(List<Message> messageList, index) {
    final message = messageList.elementAt(index);
    final isFirstMessage = index == 0;
    final isLastMessage = index == messageList.length - 1;

    final isFirstMessageOfSession = isFirstMessage ||
        determineIsFirstMessageOfSession(
            message, messageList.elementAt(index - 1));

    final isFirstMessageOfSequence = isFirstMessage ||
        determineIsFirstMessageOfSequence(
            message, messageList.elementAt(index - 1));
  }

  determineIsFirstMessageOfSession(Message message, Message prevMessage) {
    return prevMessage.sentAt.millisecondsSinceEpoch -
            message.sentAt.millisecondsSinceEpoch >
        60000 * 30;
  }

  determineIsFirstMessageOfSequence(Message message, Message prevMessage) {
    if (message.author != prevMessage.author) return true;
    return prevMessage.sentAt.millisecondsSinceEpoch -
            message.sentAt.millisecondsSinceEpoch >
        30000;
  } */
}

final chatWidgetDataListFamily = StateProvider.family
    .autoDispose<List<dynamic>, String>((ref, String tribuId) {
  final profileListNotifier = ref.watch(profileListProvider(tribuId).notifier);
  final messageList = ref.watch(messageListProvider(tribuId));
  final presenceList = ref
      .watch(presenceListProvider(tribuId))
      .where((presence) => presence.focus?.indexOf('chatInput') == 0)
      .toList();
  final chatWidgetDataList = <Map<String, dynamic>>[];
  if (presenceList.isNotEmpty) {
    chatWidgetDataList.add({
      'type': 'messageInProgress',
      'memberList': presenceList
          .map((e) => profileListNotifier.getProfile(e.userId))
          .toList(),
    });
  }
  for (var i = 0; i < messageList.length; i++) {
    final author = messageList[i].author;
    final sameAuthorMessageList = [messageList[i]];
    while (i + 1 < messageList.length &&
        messageList[i + 1].author == author &&
        messageList[i].sentAt.millisecondsSinceEpoch -
                messageList[i + 1].sentAt.millisecondsSinceEpoch <
            30000) {
      i++;
      sameAuthorMessageList.insert(0, messageList[i]);
    }
    if (author == 'tribu') {
      chatWidgetDataList
          .add({'type': 'tribuMessage', 'messageList': sameAuthorMessageList});
    } else if (author == FirebaseAuth.instance.currentUser!.uid) {
      chatWidgetDataList
          .add({'type': 'ownMessage', 'messageList': sameAuthorMessageList});
    } else {
      chatWidgetDataList.add({
        'type': 'otherMessage',
        'messageList': sameAuthorMessageList,
        'profile': profileListNotifier.getProfile(messageList[i].author)
      });
    }
    if (i + 1 == messageList.length ||
        messageList[i].sentAt.millisecondsSinceEpoch -
                messageList[i + 1].sentAt.millisecondsSinceEpoch >
            60000 * 30) {
      chatWidgetDataList.add({
        'type': 'chatDate',
        'timestamp': messageList[i].sentAt.millisecondsSinceEpoch
      });
    }
  }

  return chatWidgetDataList;
});
