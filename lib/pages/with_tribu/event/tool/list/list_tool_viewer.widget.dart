import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/pages/with_tribu/event/tool/list/edit_list_tool_form.dart';
import 'package:tribu/widgets/counter_badge.widget.dart';

class ListToolViewer extends HookConsumerWidget {
  const ListToolViewer(this.tool, {super.key, this.onPressed});
  final ListTool tool;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        listToolDefault.values
            .firstWhere((element) => element.iconName == tool.icon)
            .icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        tool.name,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      trailing: CounterBadge(
        "${tool.aggregated.checkedLength != null && tool.aggregated.checkedLength! > 0 ? '${tool.aggregated.checkedLength} / ' : ''}${tool.aggregated.length}",
      ),
      onTap: onPressed,
    );
  }
}
