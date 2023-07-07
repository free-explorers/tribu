import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/edit_expenses_tool_form.dart';
import 'package:tribu/widgets/expandable_card.widget.dart';

class ExpensesToolCreationCard extends HookConsumerWidget {
  const ExpensesToolCreationCard({
    super.key,
    this.expanded = false,
    this.onExpansionChanged,
  });
  final bool expanded;
  final void Function({required bool isExpanded})? onExpansionChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolToCreate = useState<ExpensesTool?>(
      ExpensesTool(
        name: S.of(context).expenseToolName,
        currency: NumberFormat.compactCurrency().currencyName!,
      ),
    );
    final toolIsValid = useState(true);
    return ExpandableCard(
      expanded: expanded,
      icon: MdiIcons.abacus,
      title: S.of(context).expenseToolName,
      subtitle: S.of(context).expenseToolDescription,
      children: [
        EditExpensesToolForm(
          tool: toolToCreate.value,
          onChanged: (tool, {required isValid}) {
            toolToCreate.value = tool;
            toolIsValid.value = isValid;
          },
        ),
        const SizedBox(
          height: 8,
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: toolIsValid.value
              ? () => Navigator.pop(context, toolToCreate.value)
              : null,
          child: Text(S.of(context).createAction),
        )
      ],
      onExpansionChanged: ({required isExpanded}) =>
          onExpansionChanged?.call(isExpanded: isExpanded),
    );
  }
}
