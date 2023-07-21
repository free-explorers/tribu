import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tool/expenses/expense/expense.model.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/profile/profile_dropdown_multiple.dart';
import 'package:tribu/widgets/text_field.dart';

class EditExpenseDialog extends HookConsumerWidget {
  const EditExpenseDialog({
    required this.onConfirmed,
    required this.eventId,
    super.key,
    this.expense,
  });
  final Expense? expense;
  final Future<dynamic> Function(Expense) onConfirmed;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelTextController = useTextEditingController(text: expense?.label);
    final labelFocusNode = useFocusNode();
    if (expense == null) {
      //labelFocusNode.requestFocus();
    }
    final formatter = NumberFormat.currency(symbol: '');
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final amountTextController = useTextEditingController(
      text: expense != null ? formatter.format(expense?.amount) : null,
    );
    final amountFocusNode = useFocusNode();
    useEffect(() {
      void cb() {
        if (amountFocusNode.hasFocus) {
          amountTextController.value = amountTextController.value.copyWith(
            selection: TextSelection(
              baseOffset: 0,
              extentOffset: amountTextController.text.length,
            ),
          );
        }
      }

      amountFocusNode.addListener(cb);

      return () {
        amountFocusNode.removeListener(cb);
      };
    });
    final tribuId = ref.watch(tribuIdSelectedProvider)!;
    final myProfile = ref.watch(ownProfileProvider(tribuId));
    final paidByState = useState(expense?.paidBy ?? myProfile.id);

    final event = ref.watch(eventProvider(eventId))!;
    final eventAttendeesProfileList = ref.read(
      eventAttendeesProfileListProvider(
        event,
      ),
    );
    final paidForState = useState(
      expense?.paidFor ?? eventAttendeesProfileList.map((e) => e.id).toList(),
    );

    final loading = useState(false);
    Future<void> onSubmitted() async {
      if (loading.value) return;
      final valid = formKey.currentState!.validate();
      if (valid) {
        loading.value = true;
        if (expense != null) {
          await onConfirmed(
            expense!.copyWith(
              label: labelTextController.text,
              amount: formatter.parse(amountTextController.text).toDouble(),
              paidBy: paidByState.value,
              paidFor: paidForState.value,
            ),
          );
        } else {
          await onConfirmed(
            Expense(
              label: labelTextController.text,
              amount: formatter.parse(amountTextController.text).toDouble(),
              paidBy: paidByState.value,
              paidFor: paidForState.value,
            ),
          );
        }

        loading.value = false;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TribuTextTheme(
            child: TextFormField(
              textInputAction: TextInputAction.next,
              controller: labelTextController,
              focusNode: labelFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).thisFieldIsRequired;
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                focusColor: Theme.of(context).colorScheme.secondary,
                labelText: S.of(context).expenseLabel,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          TribuTextTheme(
            child: TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: amountTextController,
              focusNode: amountFocusNode,
              decoration: InputDecoration(
                filled: true,
                focusColor: Theme.of(context).colorScheme.secondary,
                labelText: S.of(context).amount,
              ),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    formatter.parse(newValue.text);
                  } catch (e) {
                    return oldValue;
                  }
                  return newValue;
                })
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This is required';
                }
                return null;
              },
              onFieldSubmitted: (string) {
                amountTextController.value =
                    amountTextController.value.copyWith(
                  text: formatter.format(formatter.parse(string)),
                );
              },
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ProfileDropdown(
            decoration: InputDecoration(
              filled: true,
              focusColor: Theme.of(context).colorScheme.secondary,
              labelText: S.of(context).paidBy,
            ),
            initialValue: [paidByState.value],
            onSelectionChange: (userId) {
              paidByState.value = userId;
            },
            filter: eventAttendeesProfileList.contains,
          ),
          const SizedBox(
            height: 16,
          ),
          ProfileDropdown(
            decoration: InputDecoration(
              filled: true,
              focusColor: Theme.of(context).colorScheme.secondary,
              labelText: S.of(context).paidFor,
            ),
            initialValue: paidForState.value,
            onMultiSelectionChange: (userIdList) {
              paidForState.value = userIdList;
            },
            allowEmptySelection: false,
            filter: (profile) => ref
                .read(
                  eventAttendeesProfileListProvider(
                    ref.read(eventProvider(eventId))!,
                  ),
                )
                .contains(profile),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(S.of(context).cancelAction),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(
                width: 16,
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: onSubmitted,
                child: loading.value
                    ? const CircularProgressIndicator()
                    : Text(
                        expense != null
                            ? S.of(context).updateAction
                            : S.of(context).createAction,
                      ),
              )
            ],
          )
        ],
      ),
    );
  }
}
