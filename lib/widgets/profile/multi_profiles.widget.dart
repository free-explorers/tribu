import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';
import 'package:tribu/widgets/tribu_avatar.dart';

const offset = 16.0;

class MultiProfiles extends HookConsumerWidget {
  const MultiProfiles(this.profileList,
      {super.key, this.radius = 40.0, this.visibleLength = 3,});
  final List<Profile> profileList;
  final double radius;
  final int visibleLength;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = min(visibleLength, profileList.length);
    final widgetList = <Widget>[];
    for (var i = 0; i < length; i++) {
      Widget widget;
      if (i == length - 1 && profileList.length > visibleLength) {
        widget = TribuAvatar(
          radius: radius,
          text: '+${profileList.length - length + 1}',
        );
      } else {
        final profile = profileList.elementAt(i);
        widget = ProfileAvatar(
          profile,
          radius: radius,
        );
      }
      widgetList.add(Positioned(left: i * (radius - offset), child: widget));
    }
    return SizedBox(
      width: radius + (radius - offset) * (length - 1),
      height: radius,
      child: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.centerStart,
        children: [...widgetList],
      ),
    );
  }
}
