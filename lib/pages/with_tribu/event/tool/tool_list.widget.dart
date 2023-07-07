import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/edit_expenses_tool_dialog.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/expenses_tool_detail.page.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/expenses_tool_viewer.widget.dart';
import 'package:tribu/pages/with_tribu/event/tool/list/edit_list_tool_dialog.dart';
import 'package:tribu/pages/with_tribu/event/tool/list/list_tool_detail.page.dart';
import 'package:tribu/pages/with_tribu/event/tool/list/list_tool_viewer.widget.dart';
import 'package:tribu/widgets/card_button.dart';
import 'package:tribu/widgets/confirm_dialog.dart';
import 'package:tribu/widgets/utils/expandable.widget.dart';

enum ToolListViewMode { collapsed, expanded, editable }

class ToolList extends HookConsumerWidget {
  const ToolList({
    required this.event,
    this.onNewToolPressed,
    this.onEditionCompleted,
    this.viewMode = ToolListViewMode.collapsed,
    super.key,
  });
  final Event event;
  final ToolListViewMode viewMode;
  final void Function()? onNewToolPressed;
  final void Function()? onEditionCompleted;

  bool get shouldBeExpanded {
    return viewMode != ToolListViewMode.collapsed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolList = ref.watch(toolListProvider(event.id!));
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final toolPageListNotifier =
        ref.watch(toolPageListProvider(tribuId).notifier);
    final eventToolList = useMemoized(
      () => event.toolIdList
          .map(
            (toolId) => toolList.firstWhereOrNull(
              (tool) => tool.id == toolId,
            ),
          )
          .whereNotNull()
          .toList(),
      [toolList, event],
    );

    return TribuExpandable(
      isExpanded: shouldBeExpanded,
      collapsed: Row(
        children: [
          TribuCardButton(
            readOnly: true,
            label: Text(
              S.of(context).toolsLengthText(event.toolIdList.length),
            ),
            icon: Icon(MdiIcons.listBox),
          )
        ],
      ),
      expanded: Column(
        children: [
          Card(
            color: viewMode == ToolListViewMode.editable
                ? Theme.of(context).colorScheme.secondaryContainer
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewMode != ToolListViewMode.editable)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: eventToolList.length,
                    itemBuilder: (context, index) => eventToolList[index].map(
                      list: (listTool) => ListToolViewer(
                        listTool,
                        onPressed: () async {
                          toolPageListNotifier.push(
                            MaterialPage(
                              key: PageStorageKey(listTool.id!),
                              child: ListToolDetailPage(
                                toolId: listTool.id!,
                                eventId: event.id!,
                              ),
                            ),
                          );
                        },
                      ),
                      expenses: (expensesTool) => ExpensesToolViewer(
                        expensesTool,
                        onPressed: () async {
                          toolPageListNotifier.push(
                            MaterialPage(
                              key: ValueKey(expensesTool.id!),
                              child: ExpensesToolDetailPage(
                                toolId: expensesTool.id!,
                                eventId: event.id!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (viewMode == ToolListViewMode.editable)
                  ReorderableListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => ListTile(
                      key: Key(eventToolList[index].id!),
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: Icon(MdiIcons.drag),
                      ),
                      title: Text(eventToolList[index].name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog<dynamic>(
                                context: context,
                                builder: (_) => eventToolList[index].map(
                                  list: (list) => EditListToolDialog(
                                    toolId: list.id!,
                                    eventId: event.id!,
                                  ),
                                  expenses: (expenses) =>
                                      EditExpensesToolDialog(
                                    toolId: expenses.id!,
                                    eventId: event.id!,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(MdiIcons.pencil),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog<dynamic>(
                                context: context,
                                builder: (_) => ConfirmDialog(() async {
                                  await ref
                                      .read(
                                        eventListProvider(tribuId).notifier,
                                      )
                                      .deleteToolOfEvent(
                                        event,
                                        eventToolList[index].id!,
                                      );
                                }),
                              );
                            },
                            icon: Icon(MdiIcons.delete),
                          )
                        ],
                      ),
                    ),
                    itemCount: eventToolList.length,
                    onReorder: (oldIndex, newIndex) async {
                      final currentIdList = [...event.toolIdList];
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = currentIdList.removeAt(oldIndex);
                      currentIdList.insert(newIndex, item);
                      await ref
                          .read(
                            eventListProvider(tribuId).notifier,
                          )
                          .updateEvent(
                            event.copyWith(toolIdList: currentIdList),
                          );
                    },
                  )
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewMode == ToolListViewMode.expanded)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  onPressed: onNewToolPressed,
                  icon: Icon(MdiIcons.plus),
                  label: Text(S.of(context).newToolAction),
                ),
              if (viewMode == ToolListViewMode.editable)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  onPressed: onEditionCompleted,
                  icon: Icon(MdiIcons.wrenchCheck),
                  label: Text(S.of(context).confirmChangesAction),
                ),
            ],
          )
        ],
      ),
    );
  }
}
