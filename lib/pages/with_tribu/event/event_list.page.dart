import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/main.router.dart';
import 'package:tribu/pages/with_tribu/event/event_form_modal.widget.dart';
import 'package:tribu/pages/with_tribu/event/tool/new_tool_modal.widget.dart';
import 'package:tribu/widgets/event_viewer.dart';

class EventListPage extends HookConsumerWidget {
  const EventListPage({super.key, this.onToolSelected});
  final void Function(Widget page)? onToolSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final currentEventOpenedNotifier =
        ref.watch(currentEventOpenedIdProvider(tribuId).notifier);

    final currentEventOpened = ref.watch(currentEventOpenedIdProvider(tribuId));
    final orderedEventList = ref.watch(orderedEventListProvider(tribuId));
    ref.listen<List<Event>>(
      orderedEventListProvider(tribuId),
      (previous, next) {
        if (previous == null) return;
        if (previous.isEmpty && next.isNotEmpty) {
          currentEventOpenedNotifier.state = next.first.id;
        }
      },
    );
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.only(
          left: 16,
          top: 16,
          right: 16,
          bottom: 88,
        ),
        shrinkWrap: true,
        separatorBuilder: (context, index) => const SizedBox(
          height: 16,
        ),
        itemCount: orderedEventList.length,
        itemBuilder: (context, index) => EventViewer(
          selected: currentEventOpened == orderedEventList[index].id,
          onSelectionChanged: ({required isSelected}) =>
              currentEventOpenedNotifier.update(
            (state) => isSelected ? orderedEventList[index].id : null,
          ),
          orderedEventList[index],
          onNewToolPressed: () async {
            final toolToCreate = await showTribuBottomModal<Tool>(
              context,
              ref,
              (context) => const NewToolModal(),
              title: S.of(context).newToolAction,
            );
            if (toolToCreate != null) {
              return ref
                  .read(eventListProvider(tribuId).notifier)
                  .addToolToEvent(orderedEventList[index], toolToCreate);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final eventToCreate = await showTribuBottomModal<Event>(
            context,
            ref,
            (context) => const EventFormModal(),
            title: S.of(context).newEventAction,
          );
          if (eventToCreate != null) {
            final newEventDoc = await ref
                .read(eventListProvider(tribuId).notifier)
                .createEvent(eventToCreate);

            currentEventOpenedNotifier.state = newEventDoc.id;
          }
        },
        label: Text(S.of(context).newEventAction),
        icon: Icon(MdiIcons.plus),
      ),
    );
  }
}
