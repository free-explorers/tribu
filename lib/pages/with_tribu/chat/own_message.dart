import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/pages/with_tribu/chat/message_sequence.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class OwnMessage extends HookWidget {
  const OwnMessage({required this.messageList, super.key});
  final List<Message> messageList;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MessageSequence(
        messageList: messageList,
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.onPrimary,
        linkColor: Theme.of(context).colorScheme.secondary,
        flipHorizontal: true,
      ),
    );
  }
}
