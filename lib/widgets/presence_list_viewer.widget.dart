import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/presence/presence.provider.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/widgets/profile/multi_profiles.widget.dart';

class PresenceListViewer extends HookConsumerWidget {
  const PresenceListViewer({required this.match, super.key});
  final String match;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.watch(tribuIdSelectedProvider)!;
    final profileList = ref.watch(profileListProvider(tribuId));
    final presenceList = ref.watch(presenceListProvider(tribuId));
    final activeProfileList = presenceList
        .where(
          (presence) => presence.here && presence.route.indexOf(match) == 0,
        )
        .map((e) => e.userId)
        .toList();

    return MultiProfiles(
      profileList
          .where((element) => activeProfileList.contains(element.id))
          .toList(),
      radius: 30,
    );
  }
}
