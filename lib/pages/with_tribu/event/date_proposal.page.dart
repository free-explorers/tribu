import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/event_scaffold.dart';
import 'package:tribu/widgets/date_proposal_button.dart';
import 'package:tribu/widgets/profile/profile_list_viewer.widget.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/utils/simple_column_list.dart';

class DateProposalListPage extends HookConsumerWidget {
  const DateProposalListPage(this.eventId, {super.key});
  final String eventId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final event = ref
        .watch(eventListProvider(tribuId))
        .firstWhere((element) => element.id == eventId);

    final dateProposalList = event.mapOrNull(
      punctual: (punctualEvent) => punctualEvent.dateProposalList,
      stay: (stayEvent) => stayEvent.dateProposalList,
    )!;

    final eventListNotifier = ref.watch(eventListProvider(tribuId).notifier);
    final myProfile = ref.watch(ownProfileProvider(tribuId));
    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);

    return EventScaffold(
      event: event,
      pageIcon: Icon(MdiIcons.calendar),
      pageTitle: S.of(context).dateProposalsPageTitle,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TribuSubHeader(
              S.of(context).dateProposalPageDescription,
            ),
            const SizedBox(
              height: 16,
            ),
            SimpleColumnList(
              separatorBuilder: (context, index) => const SizedBox(
                height: 8,
              ),
              itemCount: dateProposalList.length,
              itemBuilder: (context, index) {
                final dateProposal = dateProposalList[index];
                final voted =
                    dateProposal.attendeeVoteList.contains(myProfile.id);
                return Row(
                  children: [
                    Expanded(
                      child: DateProposalButton(
                        dateProposal,
                        onTap: () {
                          eventListNotifier.updateEventDateProposalList(
                            event,
                            dateProposalList.map(
                              (e) {
                                final selection = !dateProposal.selected;
                                if (selection) {
                                  return e.copyWith(
                                    selected: e == dateProposal,
                                  );
                                } else {
                                  return e == dateProposal
                                      ? dateProposal.copyWith(
                                          selected: selection,
                                        )
                                      : e;
                                }
                              },
                            ).toList(),
                          );
                        },
                        selected: dateProposal.selected,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: voted
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.tertiaryContainer,
                        foregroundColor: voted
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      onPressed: () {
                        final newAttendeeVoteList = voted
                            ? dateProposal.attendeeVoteList.whereNot(
                                (profileId) =>
                                    profileListNotifier.getProfile(profileId) ==
                                    myProfile,
                              )
                            : [...dateProposal.attendeeVoteList, myProfile.id];
                        eventListNotifier.updateEventDateProposalList(
                          event,
                          dateProposalList
                              .map(
                                (e) => e == dateProposal
                                    ? dateProposal.copyWith(
                                        attendeeVoteList:
                                            newAttendeeVoteList.toList(),
                                      )
                                    : e,
                              )
                              .toList(),
                        );
                      },
                      icon: Icon(MdiIcons.thumbUp),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      onPressed: dateProposal.attendeeVoteList.isEmpty
                          ? null
                          : () {
                              showDialog<void>(
                                context: context,
                                builder: (context) {
                                  final profileList =
                                      ref.read(profileListProvider(tribuId));
                                  return AlertDialog(
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: ProfileListViewer(
                                        profileList: profileList
                                            .where(
                                              (element) => dateProposal
                                                  .attendeeVoteList
                                                  .contains(element.id),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                      icon: Text(
                        dateProposal.attendeeVoteList.length.toString(),
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
