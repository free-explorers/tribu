import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/pages/with_tribu/chat/message_sequence.dart';

class TribuMessage extends HookWidget {

  const TribuMessage({required this.messageList, super.key});
  final List<Message> messageList;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/logo_pad_bottom.png'),
          ),
        ),
        const SizedBox(width: 16),
        MessageSequence(
          messageList: messageList,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          linkColor: Theme.of(context).colorScheme.primary,
        ),
      ],),
    );
  }
}
