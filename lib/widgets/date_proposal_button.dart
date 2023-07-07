import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event_date_proposal/event_date_proposal.model.dart';
import 'package:tribu/widgets/card_button.dart';

class DateProposalButton extends HookConsumerWidget {
  const DateProposalButton(
    this.dateProposal, {
    super.key,
    this.onTap,
    this.selected = false,
    this.disabled = false,
    this.readOnly = false,
  });
  final EventDateProposal dateProposal;
  final void Function()? onTap;
  final bool selected;
  final bool disabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TribuCardButton(
      readOnly: readOnly,
      icon: Icon(
        dateProposal.map(
          punctual: (value) => MdiIcons.calendar,
          stay: (value) => MdiIcons.calendarExpandHorizontal,
        ),
      ),
      label: Text(
        DateFormat('E. d MMMM').format(
          dateProposal.map(
            punctual: (value) => value.date,
            stay: (value) => value.startDate,
          ),
        ),
      ),
      label2: dateProposal.map(
        punctual: (punctualDateProposal) => punctualDateProposal.isTimeDisplayed
            ? Text(
                DateFormat('jm').format(punctualDateProposal.date),
              )
            : null,
        stay: (stayDateProposal) => Text(
          DateFormat('E. d MMMM').format(
            stayDateProposal.endDate,
          ),
        ),
      ),
      onTap: onTap,
      disabled: onTap == null || disabled,
      style: selected
          ? TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
            )
          : null,
    );
  }
}
