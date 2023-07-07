import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/widgets/profile/multi_profiles.widget.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class MessageInProgress extends HookWidget {
  const MessageInProgress({required this.memberList, super.key});
  final List<Profile> memberList;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MultiProfiles(memberList),
          const SizedBox(width: 16),
          Material(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: CollectionSlideTransition(
                  children: List.filled(
                    3,
                    Icon(
                      MdiIcons.circle,
                      size: 10,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
