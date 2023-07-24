import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tool/list/item/list_item.model.dart';
import 'package:tribu/data/tribu/tool/list/list_tool.manager.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/event_scaffold.dart';
import 'package:tribu/pages/with_tribu/event/tool/list/edit_list_tool_form.dart';
import 'package:tribu/pages/with_tribu/profile_list/profile_list.page.dart';
import 'package:tribu/utils/asyncValue.extension.dart';
import 'package:tribu/widgets/profile/multi_profiles.widget.dart';
import 'package:tribu/widgets/utils/debounce.dart';
import 'package:tribu/widgets/utils/simple_column_list.dart';

class ListToolDetailPage extends HookConsumerWidget {
  const ListToolDetailPage({
    required this.eventId,
    required this.toolId,
    super.key,
  });
  final String eventId;
  final String toolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final event = ref
        .watch(eventListProvider(tribuId))
        .firstWhere((element) => element.id == eventId);
    final toolList = ref.watch(toolListProvider(event.id!));

    final tool = useMemoized(
      () => toolList.firstWhere((aTool) => aTool.id == toolId),
      [toolList],
    ) as ListTool;

    final listToolManager = useMemoized(
      () => ListToolManager(tribuId, toolId, event.encryptionKey),
    );

    final listItemListAsync =
        useStream(listToolManager.listItemListStream).asyncValue;

    // Use to keep displaying page correctly
    // when closing animation for tool deleted
    return EventScaffold(
      event: event,
      pageIcon: Icon(
        listToolDefault.values
            .firstWhere((element) => element.iconName == tool.icon)
            .icon,
      ),
      pageTitle: tool.name,
      body: listItemListAsync.when(
        data: (itemList) {
          final notCheckedList =
              itemList.where((element) => !element.checked).toList();
          final checkedList = itemList
              .where((element) => element.checked)
              .toList()
            ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                NewItemTextField(
                  onSubmitted: (text) {
                    listToolManager.addItem(ListItem(label: text));
                  },
                ),
                const SizedBox(height: 8),
                SimpleColumnList(
                  itemCount: notCheckedList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return ItemWidget(
                      event: event,
                      item: notCheckedList.elementAt(index),
                      listToolManager: listToolManager,
                    );
                  },
                ),
                const SizedBox(height: 8),
                SimpleColumnList(
                  itemCount: checkedList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return ItemWidget(
                      event: event,
                      item: checkedList.elementAt(index),
                      listToolManager: listToolManager,
                    );
                  },
                ),
                if (itemList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          MdiIcons.checkboxMarkedOutline,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          MdiIcons.arrowRightBold,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                        const Spacer(),
                        Icon(
                          MdiIcons.arrowLeftBold,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          MdiIcons.delete,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  )
              ],
            ),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (err, stack) => Text(err.toString()),
      ),
    );
  }
}

class NewItemTextField extends HookConsumerWidget {
  const NewItemTextField({super.key, this.onSubmitted});
  final void Function(String)? onSubmitted;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    return TextField(
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: S.of(context).newListItemPlaceholder,
        prefixIcon: Icon(
          MdiIcons.plusCircle,
          color: Theme.of(context).colorScheme.primary,
        ),
        fillColor: Theme.of(context).colorScheme.secondary,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      onSubmitted: (text) {
        if (onSubmitted != null && text.isNotEmpty) {
          onSubmitted!(text);
          controller.clear();
          focusNode.requestFocus();
        }
      },
    );
  }
}

class ItemWidget extends HookConsumerWidget {
  const ItemWidget({
    required this.item,
    required this.listToolManager,
    required this.event,
    super.key,
  });
  final Event event;
  final ListItem item;
  final ListToolManager listToolManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);

    final pageListNotifier = ref.watch(pageListProvider.notifier);
    final newValue = useState(item.label);

    final editing = useState(false);
    final focusNode = useFocusNode();
    useEffect(() {
      void cb() {
        if (!focusNode.hasPrimaryFocus) {
          editing.value = false;
        }
      }

      focusNode.addListener(cb);
      return () {
        focusNode.removeListener(cb);
      };
    });

    final debouncer = useMemoized(() => Debouncer(milliseconds: 500), []);
    return Dismissible(
      key: Key(item.id!),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          listToolManager.updateItem(item.copyWith(checked: !item.checked));
        } else if (direction == DismissDirection.endToStart) {
          listToolManager.deleteItem(item);
        }
      },
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          MdiIcons.checkboxMarkedOutline,
          color: Colors.green,
        ),
      ),
      secondaryBackground: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          MdiIcons.delete,
          color: Colors.red,
        ),
      ),
      child: Card(
        child: ListTile(
          leading: item.checked ? Icon(MdiIcons.check) : null,
          //In order to allow dissmissible drag event to occur we need to
          //disable pointer events on textFormField but to allow the tap to
          //focus to happend we use a hack to replicate
          //the tap on it when needed
          title: GestureDetector(
            onTapUp: (details) {
              if (editing.value == false) {
                editing.value = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  WidgetsBinding.instance.handlePointerEvent(
                    PointerDownEvent(
                      position: Offset(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                    ),
                  );
                  WidgetsBinding.instance.handlePointerEvent(
                    PointerUpEvent(
                      position: Offset(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                    ),
                  );
                });
              }
            },
            child: AbsorbPointer(
              absorbing: !editing.value,
              child: TextFormField(
                focusNode: focusNode,
                maxLines: null,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                initialValue: item.label,
                onChanged: (value) {
                  newValue.value = value;
                  debouncer.run(() {
                    listToolManager
                        .updateItem(item.copyWith(label: newValue.value));
                  });
                },
                onFieldSubmitted: (value) =>
                    listToolManager.updateItem(item.copyWith(label: value)),
              ),
            ),
          ),
          trailing: Builder(
            builder: (context) {
              void callback() {
                pageListNotifier.push(
                  MaterialPage(
                    key: const ValueKey('profileListPage'),
                    child: ProfileListPage(
                      initialProfileIdSelectedList: item.assignedList,
                      onMultiSelectionConfirmed: (profileIdSelectedList) async {
                        await listToolManager.updateItem(
                          item.copyWith(assignedList: profileIdSelectedList),
                        );
                      },
                      filter: (profile) => ref
                          .read(eventAttendeesProfileListProvider(event))
                          .contains(profile),
                    ),
                  ),
                );
              }

              if (item.assignedList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(6),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.07),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        MdiIcons.accountMultiplePlus,
                        color: Colors.black.withOpacity(0.25),
                      ),
                      onPressed: callback,
                      splashRadius: 22,
                    ),
                  ),
                );
              } else {
                return TextButton(
                  onPressed: callback,
                  child: MultiProfiles(
                    item.assignedList
                        .map(profileListNotifier.getProfile)
                        .toList(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
