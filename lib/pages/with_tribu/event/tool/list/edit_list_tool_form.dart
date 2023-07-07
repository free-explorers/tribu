import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/text_field.dart';

final listToolDefault = {
  'custom': ListType(
    icon: MdiIcons.formatListBulletedType,
    iconName: 'formatListBulletedType',
    label: ([context]) => '',
  ),
  'shopping': ListType(
    icon: MdiIcons.cart,
    iconName: 'cart',
    label: ([context]) =>
        (context != null ? S.of(context) : S.current).listToolShoppingListName,
  ),
  'todo': ListType(
    icon: MdiIcons.orderBoolAscendingVariant,
    iconName: 'orderBoolAscendingVariant',
    label: ([context]) =>
        (context != null ? S.of(context) : S.current).listToolTodoListName,
  ),
  'idea': ListType(
    icon: MdiIcons.lightbulbOn,
    iconName: 'lightbulbOn',
    label: ([context]) =>
        (context != null ? S.of(context) : S.current).listToolIdeaListName,
  ),
  'luggage': ListType(
    icon: MdiIcons.bagSuitcase,
    iconName: 'bagSuitcase',
    label: ([context]) =>
        (context != null ? S.of(context) : S.current).listToolLuggageListName,
  )
};

class EditListToolForm extends HookConsumerWidget {
  const EditListToolForm({super.key, this.tool, this.onChanged});
  final ListTool? tool;
  final void Function(ListTool, {required bool isValid})? onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController(text: tool?.name);

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final typeList = listToolDefault.values.toList();
    final selected = useState(
      tool != null
          ? typeList.indexWhere((type) => type.iconName == tool!.icon)
          : 0,
    );

    void whenChanged() {
      onChanged?.call(
        tool?.copyWith(
              name: textController.value.text,
              icon: typeList.elementAt(selected.value).iconName,
            ) ??
            ListTool(
              name: textController.value.text,
              icon: typeList.elementAt(selected.value).iconName,
            ),
        isValid: textController.value.text != '',
      );
    }

    return Form(
      key: formKey,
      onChanged: whenChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ToggleButtons(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            isSelected: typeList
                .map((e) => typeList.indexOf(e) == selected.value)
                .toList(),
            onPressed: (index) {
              final previous = selected.value;
              selected.value = index;

              if (textController.text == '' ||
                  textController.text ==
                      typeList.elementAt(previous).label(context)) {
                textController.text = typeList.elementAt(index).label(context);
              }
              whenChanged();
            },
            children: typeList.map((e) => Icon(e.icon)).toList(),
          ),
          const SizedBox(
            height: 16,
          ),
          TribuTextField(
            //autofocus: true,
            controller: textController,
            placeholder: S.of(context).listNamePlaceholder,
          )
        ],
      ),
    );
  }
}

class ListType {
  const ListType({
    required this.icon,
    required this.iconName,
    required this.label,
  });
  final IconData icon;
  final String iconName;
  final String Function([BuildContext?]) label;
}
