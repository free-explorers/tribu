import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SelectableTile {

  const SelectableTile({required this.title, this.leading, this.trailing});
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
}

enum SelectionMode { none, single, multi }

class SelectableList<k> extends HookConsumerWidget {

  const SelectableList(this.itemList,
      {required this.buildTile, super.key,
      this.mode = SelectionMode.none,
      this.bottomPadding = 16.0,
      this.onSelection,
      this.onMultiSelection,
      this.itemSelectedList = const [],
      this.shrinkWrap = false,});
  final List<k> itemList;
  final SelectableTile Function(BuildContext context, k item, int index)
      buildTile;
  final double bottomPadding;
  final List<k> itemSelectedList;
  final SelectionMode mode;
  final bool shrinkWrap;
  final void Function(k)? onSelection;
  final void Function(List<k>)? onMultiSelection;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: EdgeInsets.only(
          top: 16, left: 16, right: 16, bottom: bottomPadding,),
      itemCount: itemList.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: 8,
      ),
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        final item = itemList.elementAt(index);
        final tileWidget = buildTile(context, item, index);
        Widget widget;
        if (mode == SelectionMode.multi) {
          widget = CheckboxListTile(
            secondary: tileWidget.leading,
            title: tileWidget.title,
            onChanged: (bool? checked) {
              onMultiSelection?.call(checked!
                  ? [...itemSelectedList, item]
                  : itemSelectedList
                      .where((itemSelected) => itemSelected != item)
                      .toList(),);
            },
            value: itemSelectedList.contains(item),
          );
        } else {
          widget = ListTile(
            leading: tileWidget.leading,
            title: tileWidget.title,
            onTap: mode == SelectionMode.single
                ? () {
                    onSelection?.call(item);
                  }
                : null,
          );
        }
        return Card(
          child: widget,
        );
      },
    );
  }
}
