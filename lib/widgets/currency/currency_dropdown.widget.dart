import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CurrencyDropdown extends HookConsumerWidget {
  const CurrencyDropdown({
    required this.initialValue,
    required this.onSelectionChange,
    super.key,
    this.decoration,
  });
  final String initialValue;

  final void Function(String) onSelectionChange;
  final InputDecoration? decoration;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String buildValue(String currencyName) {
      return currencyName;
    }

    final focusNode = useFocusNode();
    final textController =
        useTextEditingController(text: buildValue(initialValue));

    final currentValue = useState(initialValue);

    focusNode.canRequestFocus = false;

    final finalDecoration =
        decoration ?? InputDecoration(suffixIcon: Icon(MdiIcons.formDropdown));

    return TextFormField(
      decoration: finalDecoration.copyWith(suffixIcon: Icon(MdiIcons.menuDown)),
      focusNode: focusNode,
      controller: textController,
      readOnly: true,
      onTap: () {
        showCurrencyPicker(
          context: context,
          onSelect: (Currency currency) {
            currentValue.value = currency.code;
            textController.value =
                textController.value.copyWith(text: buildValue(currency.code));
            onSelectionChange(currency.code);
          },
        );
        textController.selection =
            const TextSelection(baseOffset: 0, extentOffset: 0);
      },
    );
  }
}
