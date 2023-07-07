import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/pages/with_tribu/chat/message_sequence.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class OtherMessage extends HookWidget {
  const OtherMessage(
      {required this.messageList, required this.member, super.key,});
  final List<Message> messageList;

  final Profile member;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        ProfileAvatar(member),
        const SizedBox(width: 16),
        MessageSequence(
          messageList: messageList,
          backgroundColor: Theme.of(context).cardTheme.color!,
          color: Colors.grey.shade700,
          linkColor: Theme.of(context).colorScheme.secondary,
          header:
              Text(member.name, style: Theme.of(context).textTheme.bodyLarge),
        )

        /* Material(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
                topRight: Radius.circular(16.0)),
            child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 100),
                padding: const EdgeInsetsDirectional.only(
                    start: 16.0, end: 16.0, top: 8.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(member.name,
                        style: Theme.of(context).textTheme.bodyText1),
                    const SizedBox(height: 8),
                    ...messageList.map((message) => Text(message.text,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6))))
                  ],
                ))) */
      ],),
    );
  }
}
