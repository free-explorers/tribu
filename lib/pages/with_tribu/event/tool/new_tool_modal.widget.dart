import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/expenses_tool_creation_card.dart';
import 'package:tribu/pages/with_tribu/event/tool/list/list_tool_creation_card.dart';

class NewToolModal extends HookConsumerWidget {
  const NewToolModal({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentToolOpened = useState<String?>(null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListToolCreationCard(
          expanded: currentToolOpened.value == 'list',
          onExpansionChanged: ({required isExpanded}) =>
              isExpanded ? currentToolOpened.value = 'list' : null,
        ),
        const SizedBox(
          height: 8,
        ),
        ExpensesToolCreationCard(
          expanded: currentToolOpened.value == 'expenses',
          onExpansionChanged: ({required isExpanded}) =>
              isExpanded ? currentToolOpened.value = 'expenses' : null,
        ),
      ],
    );
  }
}
