import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/presence/presence.provider.dart';
import 'package:tribu/data/tribu/message/message.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/pages/with_tribu/chat/message_list_viewer.dart';
import 'package:tribu/widgets/chat_text_input.dart';

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.watch(tribuIdSelectedProvider)!;
    final messageMapNotifier = ref.watch(messageMapProvider(tribuId).notifier);
    final presenceNotifier = ref.read(presenceListProvider(tribuId).notifier);
    ref.watch(notificationPluginProvider).cancel(tribuId.hashCode);
    final tribuInfoMapNotifier = ref.watch(tribuInfoMapProvider.notifier);
    final tribuInfo =
        ref.watch(tribuInfoMapProvider.select((value) => value[tribuId]!));
    if (tribuInfo.unreadMessage > 0) {
      tribuInfoMapNotifier
          .updateTribuInfo(tribuInfo.copyWith(unreadMessage: 0));
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: const ChatMessageListViewer(),
        ),
        ChatTextInput(
          onNewText: messageMapNotifier.createMessage,
          onPlusButtonTapped: () async {
            final pathList =
                await messageMapNotifier.mediaManager.pickMediaList(context);

            if (pathList.isNotEmpty) {
              await messageMapNotifier.createMediaMessage(pathList);
            }
          },
          onFocusChanged: ({required hasFocus}) {
            if (hasFocus) {
              presenceNotifier.setFocus('chatInput');
            } else {
              presenceNotifier.setFocus(null);
            }
          },
        )
      ],
    );
  }
}
