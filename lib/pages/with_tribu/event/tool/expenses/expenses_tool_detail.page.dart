import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tool/expenses/expense.providers.dart';
import 'package:tribu/data/tribu/tool/expenses/expense/expense.model.dart';
import 'package:tribu/data/tribu/tool/expenses/expense_list.notifier.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/main.router.dart';
import 'package:tribu/pages/with_tribu/event/event_scaffold.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/edit_expense_dialog.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/expenses_resume_viewer.dart';
import 'package:tribu/utils/asyncValue.extension.dart';
import 'package:tribu/widgets/currency/currency.widget.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/utils/simple_column_list.dart';

class ExpensesToolDetailPage extends HookConsumerWidget {
  const ExpensesToolDetailPage({
    required this.toolId,
    required this.eventId,
    super.key,
  });
  //final ExpenseListNotifier expenseListNotifier;
  final String toolId;
  final String eventId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;
    final event = ref
        .watch(eventListProvider(tribuId))
        .firstWhere((element) => element.id == eventId);

    final expenseListNotifier =
        ref.watch(expenseListProvider((toolId, eventId)).notifier);

    final toolList = ref.watch(toolListProvider(eventId));

    final tool = useMemoized(
      () => toolList.firstWhere((aTool) => aTool.id == toolId),
      [toolList],
    ) as ExpensesTool;

    final expenseListAsync =
        useStream(expenseListNotifier.expenseListStream).asyncValue;

    final totalAmount = ref.watch(expenseTotalProvider((tool.id!, eventId)));

    return EventScaffold(
      event: event,
      pageIcon: Icon(MdiIcons.abacus),
      pageTitle: tool.name,
      body: expenseListAsync.when(
        data: (expenseList) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 72,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpensesResumeViewer(
                    toolId: toolId,
                    eventId: eventId,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 24, top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TribuSubHeader(
                            S.of(context).expensesSubHeader,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: CurrencyViewer(
                            totalAmount,
                            currencyName: tool.currency,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        )
                      ],
                    ),
                  ),
                  SimpleColumnList(
                    itemCount: expenseList.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(
                      height: 8,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final expense = expenseList.elementAt(index);
                      return ExpenseWidget(
                        eventId: eventId,
                        expense: expense,
                        currencyName: tool.currency,
                        expenseListNotifier: expenseListNotifier,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (err, stack) => Text(err.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showTribuBottomModal<dynamic>(
            context,
            ref,
            (_) {
              return EditExpenseDialog(
                eventId: eventId,
                onConfirmed: (updatedExpense) async =>
                    expenseListNotifier.updateExpense(updatedExpense),
              );
            },
            title: S.of(context).newExpenseAction,
          );
        },
        label: Text(S.of(context).newExpenseAction),
        icon: Icon(MdiIcons.plus),
      ),
    );
  }
}

class ExpenseWidget extends HookConsumerWidget {
  const ExpenseWidget({
    required this.expense,
    required this.currencyName,
    required this.eventId,
    required this.expenseListNotifier,
    super.key,
  });
  final Expense expense;
  final String currencyName;
  final ExpenseListNotifier expenseListNotifier;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);

    return Dismissible(
      key: Key(expense.id!),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          expenseListNotifier.deleteExpense(expense);
        }
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          MdiIcons.deleteCircle,
          color: Colors.red,
        ),
      ),
      child: Card(
        child: ListTile(
          leading:
              ProfileAvatar(profileListNotifier.getProfile(expense.paidBy)),
          title: Text(expense.label),
          trailing: CurrencyViewer(
            expense.amount,
            currencyName: currencyName,
          ),
          onTap: () {
            showTribuBottomModal<dynamic>(
              context,
              ref,
              (_) {
                return EditExpenseDialog(
                  eventId: eventId,
                  expense: expense,
                  onConfirmed: (updatedExpense) async =>
                      expenseListNotifier.updateExpense(updatedExpense),
                );
              },
              title: S.of(context).editExpenseAction,
            );
          },
        ),
      ),
    );
  }
}
