import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/event_scaffold.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';
import 'package:tribu/widgets/utils/simple_column_list.dart';

class AttendeeListPage extends HookConsumerWidget {
  const AttendeeListPage({
    required this.eventId,
    super.key,
  });
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final event = ref.watch(eventProvider(eventId))!;
    final profileList = ref.watch(profileListProvider(tribuId));

    final attendeesMap = event.mapOrNull(
      punctual: (punctualEvent) => punctualEvent.attendeesMap,
      stay: (stayEvent) => stayEvent.attendeesMap,
    )!;
    return EventScaffold(
      event: event,
      pageIcon: Icon(MdiIcons.accountMultipleCheck),
      pageTitle: S.of(context).attendeesPresencePageTitle,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SimpleColumnList(
          itemBuilder: (context, index) {
            final attendeeEntry = attendeesMap.entries.elementAt(index);
            final profile = profileList.firstWhere(
              (element) => element.id == attendeeEntry.key,
            );
            return Card(
              child: SwitchListTile.adaptive(
                secondary: ProfileAvatar(profile),
                title: Text(profile.name),
                value: attendeeEntry.value ?? false,
                onChanged: (value) {
                  ref
                      .read(eventListProvider(tribuId).notifier)
                      .updateAttendeePresence(
                        eventId: event.id!,
                        profileId: profile.id,
                        isPresent: value,
                      );
                },
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            height: 8,
          ),
          itemCount: attendeesMap.length,
        ),
      ),
    );
  }
}
