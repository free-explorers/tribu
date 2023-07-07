import 'package:collection/collection.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event_date_proposal/event_date_proposal.model.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/card_button.dart';
import 'package:tribu/widgets/date_proposal_button.dart';
import 'package:tribu/widgets/profile/profile_dropdown_multiple.dart';
import 'package:tribu/widgets/text_field.dart';

class PunctualEventForm extends HookConsumerWidget {
  const PunctualEventForm({super.key, this.event, this.onChanged});
  final PunctualEvent? event;
  final void Function(PunctualEvent event, {required bool isValid})? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Title Field
    final titleTextController = useTextEditingController(text: event?.title);
    final titleFocusNode = useFocusNode();

    // Date proposals
    final dateProposalListState =
        useState<List<PunctualDateProposal>>(event?.dateProposalList ?? []);

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
            : PunctualEvent(
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
      PunctualDateProposal original,
      PunctualDateProposal updated,
    ) {
      final currentList = dateProposalListState.value;
      final currentIndex = currentList.indexOf(original);
      currentList[currentIndex] = updated;
      dateProposalListState.value = [...currentList];
      whenChanged();
    }

    void addDateProposal(DateTime date) {
      dateProposalListState.value = [
        ...dateProposalListState.value,
        PunctualDateProposal(
          date: date,
          isTimeDisplayed: false,
          attendeeVoteList: [],
          selected: false,
        )
      ];
      whenChanged();
    }

    void removeDateProposal(PunctualDateProposal dateProposal) {
      dateProposalListState.value = dateProposalListState.value
          .whereNot((element) => element == dateProposal)
          .toList();
      whenChanged();
    }

    void setTimeToDateProposal(
      PunctualDateProposal dateProposal,
      TimeOfDay timeOfDay,
    ) {
      updateDateProposal(
        dateProposal,
        dateProposal.copyWith(
          isTimeDisplayed: true,
          date: DateTime(
            dateProposal.date.year,
            dateProposal.date.month,
            dateProposal.date.day,
            timeOfDay.hour,
            timeOfDay.minute,
          ),
        ),
      );
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
                    buildPunctualDateRow(
                      context,
                      ref,
                      dateProposal: dateProposal,
                      onDateSelected: (value) => updateDateProposal(
                        dateProposal,
                        dateProposal.copyWith(date: value),
                      ),
                      onTimeSelected: (timeOfDay) =>
                          setTimeToDateProposal(dateProposal, timeOfDay),
                      onRemoved: () => removeDateProposal(dateProposal),
                    ),
                    const SizedBox(
                      height: 8,
                    )
                  ],
                )
                .flattened,
            buildPunctualDateRow(
              context,
              ref,
              isFirst: dateProposalListState.value.isEmpty,
              onDateSelected: addDateProposal,
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
    PunctualDateProposal? dateProposal,
    String label = '',
    void Function(DateTime)? onDateSelected,
    bool disabled = false,
  }) {
    Future<void> onTap() => showDatePicker(
          context: context,
          initialDate: dateProposal?.date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 10000)),
        ).then((dateSelected) {
          if (dateSelected != null) {
            onDateSelected?.call(dateSelected);
          }
        });

    if (dateProposal != null) {
      return DateProposalButton(
        dateProposal,
        onTap: onTap,
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
        onTap: onTap,
        disabled: disabled,
      );
    }
  }

  Widget buildPunctualDateRow(
    BuildContext context,
    WidgetRef ref, {
    PunctualDateProposal? dateProposal,
    void Function(DateTime)? onDateSelected,
    void Function(TimeOfDay)? onTimeSelected,
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
              ? S.of(context).pickInitialDate
              : S.of(context).pickAdditionnalDate,
          onDateSelected: onDateSelected,
        ),
        if (isFirst || !isTimePickerDisabled) ...[
          const SizedBox(width: 4),
          Opacity(
            opacity: isTimePickerDisabled ? 0.5 : 1,
            child: IconButton.filled(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              icon: Icon(
                MdiIcons.clockEdit,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: isTimePickerDisabled
                  ? null
                  : () => showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      ).then((timeSelected) {
                        if (timeSelected != null) {
                          onTimeSelected?.call(timeSelected);
                        }
                      }),
            ),
          )
        ],
        if (!isTimePickerDisabled)
          IconButton(onPressed: onRemoved, icon: Icon(MdiIcons.delete))
      ],
    );
  }
}
