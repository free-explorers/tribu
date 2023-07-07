import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/pages/with_tribu/event/permanent/permanent_event_form_card.dart';
import 'package:tribu/pages/with_tribu/event/punctual/punctual_event_form_card.dart';
import 'package:tribu/pages/with_tribu/event/stay/stay_event_form_card.dart';

class EventFormModal extends HookConsumerWidget {
  const EventFormModal({
    super.key,
    this.event,
  });

  final Event? event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCardOpened = useState<String?>(null);
    if (event != null) {
      return event!.map(
        permanent: (permanent) => PermanentEventFormCard(
          expanded: true,
          event: permanent,
        ),
        punctual: (punctual) => PunctualEventFormCard(
          expanded: true,
          event: punctual,
        ),
        stay: (stay) => StayEventFormCard(
          expanded: true,
          event: stay,
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PermanentEventFormCard(
          expanded: currentCardOpened.value == 'permanent',
          onExpansionChanged: ({required isExpanded}) {
            isExpanded ? currentCardOpened.value = 'permanent' : null;
          },
        ),
        const SizedBox(
          height: 8,
        ),
        PunctualEventFormCard(
          expanded: currentCardOpened.value == 'punctual',
          onExpansionChanged: ({required isExpanded}) =>
              isExpanded ? currentCardOpened.value = 'punctual' : null,
        ),
        const SizedBox(
          height: 8,
        ),
        StayEventFormCard(
          expanded: currentCardOpened.value == 'stay',
          onExpansionChanged: ({required isExpanded}) =>
              isExpanded ? currentCardOpened.value = 'stay' : null,
        )
      ],
    );
  }
}
