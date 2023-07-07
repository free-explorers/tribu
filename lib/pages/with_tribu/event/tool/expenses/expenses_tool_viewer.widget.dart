import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';

class ExpensesToolViewer extends HookConsumerWidget {
  const ExpensesToolViewer(this.tool, {super.key, this.onPressed});
  final ExpensesTool tool;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        MdiIcons.abacus,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        tool.name,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: onPressed,
    );
  }
}
