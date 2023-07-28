import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/event/event_date_proposal/event_date_proposal.model.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/main.router.dart';
import 'package:tribu/pages/with_tribu/event/attendee_list.page.dart';
import 'package:tribu/pages/with_tribu/event/date_proposal.page.dart';
import 'package:tribu/pages/with_tribu/event/event_form_modal.widget.dart';
import 'package:tribu/pages/with_tribu/event/tool/tool_list.widget.dart';
import 'package:tribu/theme.dart';
import 'package:tribu/utils/color.dart';
import 'package:tribu/widgets/card_button.dart';
import 'package:tribu/widgets/confirm_dialog.dart';
import 'package:tribu/widgets/date_proposal_button.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/utils/expandable.widget.dart';

class EventViewer extends HookConsumerWidget {
  const EventViewer(
    this.event, {
    super.key,
    this.onNewToolPressed,
    this.selected = false,
    this.onSelectionChanged,
  });
  final Event event;
  final void Function()? onNewToolPressed;
  final bool selected;
  final void Function({required bool isSelected})? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;
    final toolPageListNotifier =
        ref.watch(toolPageListProvider(tribuId).notifier);

    Map<String, bool?> getAttendeesMap() {
      return event.mapOrNull(
        punctual: (punctualEvent) => punctualEvent.attendeesMap,
        stay: (stayEvent) => stayEvent.attendeesMap,
      )!;
    }

    final myProfile = ref.watch(ownProfileProvider(tribuId));

    final showPlannedToComeCard =
        event is! PermanentEvent && getAttendeesMap()[myProfile.id] != true;

    final isEditingTools = useState(false);

    return Card(
      elevation: selected ? 4 : 0,
      color: selected ? lighten(tribuBlue, 92) : lighten(tribuBlue, 92),
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: selected
            ? null
            : () {
                onSelectionChanged?.call(isSelected: !selected);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !selected
                        ? Container(height: 48)
                        : PopupMenuButton(
                            icon: Icon(MdiIcons.dotsVertical),
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<dynamic>(
                                child: ListTile(
                                  leading: Icon(MdiIcons.pencil),
                                  title: Text(S.of(context).editEventAction),
                                ),
                                onTap: () async {
                                  final eventModified =
                                      await showTribuBottomModal<Event>(
                                    context,
                                    ref,
                                    (context) => EventFormModal(
                                      event: event,
                                    ),
                                    title: S.of(context).editEventAction,
                                  );
                                  if (eventModified != null) {
                                    await ref
                                        .read(
                                          eventListProvider(tribuId).notifier,
                                        )
                                        .updateEvent(eventModified);
                                  }
                                },
                              ),
                              PopupMenuItem<dynamic>(
                                child: ListTile(
                                  leading: Icon(MdiIcons.delete),
                                  title: Text(S.of(context).deleteEventAction),
                                ),
                                onTap: () {
                                  showDialog<dynamic>(
                                    context: context,
                                    builder: (_) => ConfirmDialog(() async {
                                      await ref
                                          .read(
                                            eventListProvider(tribuId).notifier,
                                          )
                                          .deleteEvent(event);
                                    }),
                                  );
                                },
                              ),
                              PopupMenuItem<dynamic>(
                                child: ListTile(
                                  leading: Icon(MdiIcons.wrenchCog),
                                  title: Text(S.of(context).manageToolsAction),
                                ),
                                onTap: () {
                                  isEditingTools.value = true;
                                },
                              ),
                            ],
                          ),
                  )
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: SizedBox(height: selected ? 8 : 0),
              ),
              if (event is! PermanentEvent) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DateProposalOrVoteButton(
                      event.mapOrNull(
                        punctual: (value) => value.dateProposalList,
                        stay: (value) => value.dateProposalList,
                      )!,
                      readOnly: !selected,
                      onTap: () {
                        toolPageListNotifier.push(
                          MaterialPage(
                            key: ValueKey(event.id),
                            child: DateProposalListPage(event.id!),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    AttendeesButton(
                      attendeesMap: event.mapOrNull(
                        punctual: (punctualEvent) => punctualEvent.attendeesMap,
                        stay: (stayEvent) => stayEvent.attendeesMap,
                      )!,
                      profileList: ref.watch(profileListProvider(tribuId)),
                      readOnly: !selected,
                      onTap: () {
                        toolPageListNotifier.push(
                          MaterialPage(
                            key: ValueKey(event.id),
                            child: AttendeeListPage(eventId: event.id!),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
              if (showPlannedToComeCard) ...[
                const SizedBox(height: 8),
                InvitationCard(
                  tribuId: tribuId,
                  event: event,
                  isExpanded: selected,
                  willAttend: getAttendeesMap()[myProfile.id],
                )
              ],
              if (!showPlannedToComeCard) ...[
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(height: selected ? 8 : 0),
                ),
                ToolList(
                  event: event,
                  onNewToolPressed: onNewToolPressed,
                  onEditionCompleted: () => isEditingTools.value = false,
                  viewMode: selected
                      ? isEditingTools.value
                          ? ToolListViewMode.editable
                          : ToolListViewMode.expanded
                      : ToolListViewMode.collapsed,
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class InvitationCard extends HookConsumerWidget {
  const InvitationCard({
    required this.tribuId,
    required this.event,
    this.isExpanded = false,
    this.willAttend,
    super.key,
  });

  final String tribuId;
  final Event event;
  final bool? willAttend;
  final bool isExpanded;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = TribuSubHeader(
      S.of(context).eventInvitationTitle,
      color: Theme.of(context).colorScheme.onSecondaryContainer,
    );
    return Card(
      color: willAttend == null
          ? Theme.of(context).colorScheme.secondaryContainer
          : isExpanded
              ? null
              : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        child: TribuExpandable(
          isExpanded: isExpanded,
          collapsed: willAttend == false
              ? TribuSubHeader(
                  S.of(context).eventInvitationDeclinedTitle,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                )
              : header,
          expanded: Column(
            children: [
              header,
              TribuSubHeader(
                S.of(context).willYouAttend,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.outlined(
                    onPressed: () {
                      ref
                          .read(
                            eventListProvider(tribuId).notifier,
                          )
                          .updateAttendeePresence(
                            eventId: event.id!,
                            profileId: ref.read(ownProfileProvider(tribuId)).id,
                            isPresent: true,
                          );
                    },
                    icon: Icon(MdiIcons.check),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton.outlined(
                    isSelected: willAttend == false,
                    onPressed: () {
                      ref
                          .read(
                            eventListProvider(tribuId).notifier,
                          )
                          .updateAttendeePresence(
                            eventId: event.id!,
                            profileId: ref.read(ownProfileProvider(tribuId)).id,
                            isPresent: false,
                          );
                    },
                    icon: Icon(MdiIcons.close),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AttendeesButton extends StatelessWidget {
  const AttendeesButton({
    required this.attendeesMap,
    required this.profileList,
    super.key,
    this.onTap,
    this.readOnly = false,
  });
  final Map<String, bool?> attendeesMap;
  final List<Profile> profileList;
  final void Function()? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TribuCardButton(
      label: Text(
        '${attendeesMap.values.where((element) => element ?? false).length} / ${profileList.length}',
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      icon: Icon(
        MdiIcons.accountMultipleCheck,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
      readOnly: readOnly,
    );
  }
}

class DateProposalOrVoteButton extends HookConsumerWidget {
  const DateProposalOrVoteButton(
    this.dateProposalList, {
    super.key,
    this.onTap,
    this.readOnly = false,
  });
  final List<EventDateProposal> dateProposalList;
  final void Function()? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateSelected = dateProposalList.firstWhereOrNull(
      (dateProposal) => dateProposal.selected,
    );
    if (dateSelected != null) {
      return DateProposalButton(
        dateSelected,
        onTap: onTap,
        readOnly: readOnly,
      );
    } else {
      return TribuCardButton(
        label: Text(
          S.of(context).eventDateVoteInProgress,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        label2: Text(
          S
              .of(context)
              .dateproposallistlengthPropositions(dateProposalList.length),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        icon: Icon(MdiIcons.calendarQuestion),
        onTap: onTap,
        readOnly: readOnly,
      );
    }
  }
}
