import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/permanent/permanent_event_form.dart';
import 'package:tribu/widgets/expandable_card.widget.dart';

class PermanentEventFormCard extends HookConsumerWidget {
  const PermanentEventFormCard({
    this.expanded = false,
    this.onExpansionChanged,
    this.event,
    super.key,
  });
  final PermanentEvent? event;
  final bool expanded;
  final void Function({required bool isExpanded})? onExpansionChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newEventState = useState<PermanentEvent?>(event);
    final formIsValidState = useState(false);
    return ExpandableCard(
      expanded: expanded,
      icon: MdiIcons.infinity,
      title: S.of(context).permanentEventTypeTitle,
      subtitle: S.of(context).permanentEventTypeDescription,
      onExpansionChanged: onExpansionChanged,
      children: [
        PermanentEventForm(
          event: newEventState.value,
          onChanged: (event, {required isValid}) {
            formIsValidState.value = isValid;
            if (isValid) {
              newEventState.value = event;
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
              : () => Navigator.pop(context, newEventState.value),
          child: Text(
            event != null
                ? S.of(context).editAction
                : S.of(context).createAction,
          ),
        )
      ],
    );
  }
}
