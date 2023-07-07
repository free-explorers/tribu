import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/edit_expenses_tool_form.dart';
import 'package:tribu/theme.dart';

class EditExpensesToolDialog extends HookConsumerWidget {
  const EditExpensesToolDialog({
    required this.toolId,
    required this.eventId,
    super.key,
  });
  final String toolId;
  final String eventId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolList = ref.watch(toolListProvider(eventId));
    final tool = useMemoized(
      () => toolList.firstWhere((aTool) => aTool.id == toolId),
      [toolList],
    ) as ExpensesTool;
    final toolListNotifier = ref.watch(toolListProvider(eventId).notifier);
    final primaryTheme = ref.watch(primaryThemeProvider);
    final loading = useState(false);
    final updatedToolState = useState(tool);
    final navigator = Navigator.of(context, rootNavigator: true);
    Future<void> onSubmitted() async {
      if (tool != updatedToolState.value) {
        loading.value = true;
        await toolListNotifier.updateTool(updatedToolState.value);
        loading.value = false;
      }
      navigator.pop();
    }

    return Theme(
      data: primaryTheme,
      child: AlertDialog(
        title: Text(S.of(context).editToolDialogTitle),
        content: EditExpensesToolForm(
          tool: tool,
          onChanged: (updatedTool, {required isValid}) {
            if (isValid) {
              updatedToolState.value = updatedTool;
            }
          },
        ),
        actions: [
          TextButton(
            child: Text(S.of(context).cancelAction),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onSubmitted,
            child: loading.value
                ? const CircularProgressIndicator()
                : Text(S.of(context).updateAction),
          )
        ],
      ),
    );
  }
}
