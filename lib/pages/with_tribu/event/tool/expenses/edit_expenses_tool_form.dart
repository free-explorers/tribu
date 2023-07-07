import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/currency/currency_dropdown.widget.dart';
import 'package:tribu/widgets/text_field.dart';

class EditExpensesToolForm extends HookConsumerWidget {
  const EditExpensesToolForm({super.key, this.tool, this.onChanged});
  final ExpensesTool? tool;
  final void Function(ExpensesTool, {required bool isValid})? onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final textController = useTextEditingController(text: tool?.name);
    final currencyState = useState(
      tool?.currency ?? NumberFormat.compactCurrency().currencyName!,
    );
    void whenChanged() {
      onChanged?.call(
        tool?.copyWith(
              name: textController.value.text,
              currency: currencyState.value,
            ) ??
            ExpensesTool(
              name: textController.value.text,
              currency: currencyState.value,
            ),
        isValid: textController.value.text.isNotEmpty,
      );
    }

    return Form(
      key: formKey,
      onChanged: whenChanged,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TribuTextField(
            controller: textController,
            placeholder: S.of(context).expensesToolNamePlaceholder,
          ),
          const SizedBox(
            height: 8,
          ),
          CurrencyDropdown(
            initialValue: currencyState.value,
            decoration: InputDecoration(
              filled: true,
              labelText: S.of(context).currency,
            ),
            onSelectionChange: (e) {
              currencyState.value = e;
              whenChanged();
            },
          )
        ],
      ),
    );
  }
}
