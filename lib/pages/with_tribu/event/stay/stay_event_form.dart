import 'package:collection/collection.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/event/event_date_proposal/event_date_proposal.model.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/card_button.dart';
import 'package:tribu/widgets/date_proposal_button.dart';
import 'package:tribu/widgets/profile/profile_dropdown_multiple.dart';
import 'package:tribu/widgets/text_field.dart';

class StayEventForm extends HookConsumerWidget {
  const StayEventForm({super.key, this.event, this.onChanged});
  final StayEvent? event;
  final void Function(StayEvent event, {required bool isValid})? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Title Field
    final titleTextController = useTextEditingController(text: event?.title);
    final titleFocusNode = useFocusNode();

    // Date proposals
    final dateProposalListState =
        useState<List<StayDateProposal>>(event?.dateProposalList ?? []);

    // Attendees list
    final tribuId = ref.watch(tribuIdSelectedProvider)!;
    final profileList = ref.watch(profileListProvider(tribuId));
    final me = FirebaseAuth.instance.currentUser!.uid;
    final attendeesMapState = useState(
      event?.attendeesMap ??
          {
            for (var profile in profileList)
              profile.id: profile.id == me ? true : null
          },
    );

    final eventEncryptionKey =
        useState(encrypt.Key.fromSecureRandom(32).base64);

    void whenChanged() {
      onChanged?.call(
        event != null
            ? event!.copyWith(
                title: titleTextController.value.text,
                dateProposalList: dateProposalListState.value.length == 1
                    ? [dateProposalListState.value[0].copyWith(selected: true)]
                    : dateProposalListState.value,
                attendeesMap: attendeesMapState.value,
              )
            : StayEvent(
                title: titleTextController.value.text,
                toolIdList: [],
                createdAt: DateTime.now(),
                dateProposalList: dateProposalListState.value.length == 1
                    ? [dateProposalListState.value[0].copyWith(selected: true)]
                    : dateProposalListState.value,
                attendeesMap: attendeesMapState.value,
                encryptionKey: eventEncryptionKey.value,
              ),
        isValid: titleTextController.value.text.isNotEmpty &&
            dateProposalListState.value.isNotEmpty,
      );
    }

    void updateDateProposal(
      StayDateProposal original,
      StayDateProposal updated,
    ) {
      final currentList = dateProposalListState.value;
      final currentIndex = currentList.indexOf(original);
      currentList[currentIndex] = updated;
      dateProposalListState.value = [...currentList];
      whenChanged();
    }

    void addDateProposal(StayDateProposal dateProposal) {
      dateProposalListState.value = [
        ...dateProposalListState.value,
        dateProposal
      ];
      whenChanged();
    }

    void removeDateProposal(StayDateProposal dateProposal) {
      dateProposalListState.value = dateProposalListState.value
          .whereNot((element) => element == dateProposal)
          .toList();
      whenChanged();
    }

    return Form(
      key: formKey,
      onChanged: whenChanged,
      child: Column(
        children: [
          // Title
          TribuTextTheme(
            child: TextFormField(
              textInputAction: TextInputAction.next,
              controller: titleTextController,
              focusNode: titleFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).thisFieldIsRequired;
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                focusColor: Theme.of(context).colorScheme.secondary,
                labelText: S.of(context).titlePlaceholder,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...[
            ...dateProposalListState.value
                .map(
                  (dateProposal) => [
                    buildStayDateRow(
                      context,
                      ref,
                      dateProposal: dateProposal,
                      onDateProposalSelected: (updatedDateProposal) =>
                          updateDateProposal(
                        dateProposal,
                        updatedDateProposal,
                      ),
                      onRemoved: () => removeDateProposal(dateProposal),
                    ),
                    const SizedBox(
                      height: 8,
                    )
                  ],
                )
                .flattened,
            buildStayDateRow(
              context,
              ref,
              isFirst: dateProposalListState.value.isEmpty,
              onDateProposalSelected: addDateProposal,
            ),
          ],
          const SizedBox(height: 16),

          ProfileDropdown(
            decoration: InputDecoration(
              filled: true,
              focusColor: Theme.of(context).colorScheme.secondary,
              labelText: S.of(context).attendeesPlaceholder,
            ),
            initialValue: attendeesMapState.value.keys.toList(),
            onMultiSelectionChange: (userIdList) {
              final currentAttendeesMap = attendeesMapState.value;
              final currentSet = currentAttendeesMap.keys.toSet();
              final selectionSet = userIdList.toSet();
              final newSet = selectionSet.difference(currentSet);
              final oldSet = currentSet.difference(selectionSet);
              for (final userId in oldSet) {
                if (userId != FirebaseAuth.instance.currentUser!.uid) {
                  currentAttendeesMap.remove(userId);
                }
              }
              for (final userId in newSet) {
                currentAttendeesMap[userId] = false;
              }
              attendeesMapState.value = Map.from(currentAttendeesMap);
            },
          )
        ],
      ),
    );
  }

  Widget buildDatePickerWidget(
    BuildContext context,
    WidgetRef ref, {
    StayDateProposal? dateProposal,
    String label = '',
    void Function()? onPress,
    bool disabled = false,
  }) {
    if (dateProposal != null) {
      return DateProposalButton(
        dateProposal,
        onTap: onPress,
      );
    } else {
      return TribuCardButton(
        icon: Icon(
          MdiIcons.calendarPlus,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        onTap: onPress,
        disabled: disabled,
      );
    }
  }

  Widget buildStayDateRow(
    BuildContext context,
    WidgetRef ref, {
    StayDateProposal? dateProposal,
    void Function(StayDateProposal)? onDateProposalSelected,
    void Function()? onRemoved,
    bool isFirst = false,
  }) {
    final isTimePickerDisabled = dateProposal == null;
    return Row(
      children: [
        buildDatePickerWidget(
          context,
          ref,
          dateProposal: dateProposal,
          label: isFirst
              ? S.of(context).pickInitialDateRange
              : S.of(context).pickAdditionnalDateRange,
          onPress: () {
            final currentTribuId = ref.read(tribuIdSelectedProvider)!;
            final notifier = ref.read(
              eventListProvider(currentTribuId).notifier,
            );
            notifier.pickStayDateProposal(context, dateProposal).then((value) {
              if (value != null) {
                onDateProposalSelected?.call(value);
              }
            });
          },
        ),
        if (!isTimePickerDisabled)
          IconButton(onPressed: onRemoved, icon: Icon(MdiIcons.delete))
      ],
    );
  }
}
