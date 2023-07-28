import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/stay/stay_event_form.dart';
import 'package:tribu/widgets/expandable_card.widget.dart';

class StayEventFormCard extends HookConsumerWidget {
  const StayEventFormCard({
    this.event,
    this.expanded = false,
    this.onExpansionChanged,
    super.key,
  });
  final StayEvent? event;
  final bool expanded;
  final void Function({required bool isExpanded})? onExpansionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = useState<StayEvent?>(event);
    final formIsValidState = useState(false);
    return ExpandableCard(
      expanded: expanded,
      icon: MdiIcons.calendarExpandHorizontal,
      title: S.of(context).stayEventTypeTitle,
      subtitle: S.of(context).stayEventTypeDescription,
      onExpansionChanged: onExpansionChanged,
      children: [
        StayEventForm(
          event: eventState.value,
          onChanged: (event, {required bool isValid}) {
            formIsValidState.value = isValid;
            if (isValid) {
              eventState.value = event;
            }
          },
        ),
        const SizedBox(
          height: 16,
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: !formIsValidState.value
              ? null
              : () => Navigator.pop(context, eventState.value),
          child: Text(
            event != null
                ? S.of(context).updateAction
                : S.of(context).createAction,
          ),
        )
      ],
    );
  }
}
