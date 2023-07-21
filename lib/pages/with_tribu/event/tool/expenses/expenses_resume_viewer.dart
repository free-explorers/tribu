import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tool/expenses/expense.providers.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/balance_amount.widget.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/expense_smart_balance_dialog.dart';
import 'package:tribu/widgets/currency/currency.widget.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/utils/expandable.widget.dart';

double getBalance(ExpenseResume resume) {
  return resume.totalPayed - resume.totalDue;
}

class ExpensesResumeViewer extends HookConsumerWidget {
  const ExpensesResumeViewer({
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

    final expenseResumeList = ref
        .watch(expenseResumeListProvider((toolId, eventId)))
      ..sort((a, b) => getBalance(a).compareTo(getBalance(b)));

    final isExpanded = useState(false);

    final profileNotifier = ref.watch(
      profileListProvider(ref.read(tribuIdSelectedProvider)!).notifier,
    );
    final currentUserProfile = profileNotifier.getMyProfile();

    final userExpenseResume = expenseResumeList.firstWhereOrNull(
      (element) => element.profileId == currentUserProfile.id,
    );

    final tribuId = ref.read(tribuIdSelectedProvider);
    final toolPageListNotifier =
        ref.watch(toolPageListProvider(tribuId!).notifier);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: TribuSubHeader(
                      S.of(context).userTotalCost,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Card(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: CurrencyViewer(
                        userExpenseResume?.totalDue ?? 0,
                        currencyName: tool.currency,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: TribuSubHeader(
                      S.of(context).userBalance,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Card(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: BalanceAmount(
                        userExpenseResume != null
                            ? getBalance(userExpenseResume)
                            : 0,
                        currencyName: tool.currency,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TribuSubHeader(
            S.of(context).mostIndebted,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Card(
          child: Column(
            children: [
              ExpenseBalanceTile(
                expenseResumeList.elementAt(0),
                currencyName: tool.currency,
              ),
              TribuExpandable(
                isExpanded: isExpanded.value,
                collapsed: Container(),
                expanded: Column(
                  children: [
                    ...expenseResumeList.skip(1).map(
                          (e) => ExpenseBalanceTile(
                            e,
                            currencyName: tool.currency,
                          ),
                        )
                  ],
                ),
              ),
              const Divider(
                height: 0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        label: isExpanded.value
                            ? Text(S.of(context).hideAll)
                            : Text(S.of(context).viewAll),
                        icon: Icon(
                          isExpanded.value
                              ? MdiIcons.chevronUp
                              : MdiIcons.chevronDown,
                        ),
                        onPressed: () => isExpanded.value = !isExpanded.value,
                      ),
                    ),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                        ),
                        label: Text(S.of(context).balanceAction),
                        icon: Icon(MdiIcons.scaleBalance),
                        onPressed: () {
                          if (ref
                              .read(expenseListProvider((toolId, eventId)))
                              .isEmpty) {
                            showDialog<dynamic>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(S.of(context).balanceAction),
                                content: Text(
                                  S.of(context).noExpenseSmartBalance,
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(S.of(context).cancelAction),
                                    onPressed: () => Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(),
                                  )
                                ],
                              ),
                            );
                          } else {
                            toolPageListNotifier.push(
                              MaterialPage(
                                key: const ValueKey('ExpenseResumeViewer'),
                                child: ExpenseSmartBalancePage(
                                  toolId: toolId,
                                  eventId: eventId,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExpenseResume {
  ExpenseResume({
    required this.profileId,
    this.totalDue = 0,
    this.totalPayed = 0,
  });
  final String profileId;
  double totalDue;
  double totalPayed;
}

class ExpenseBalanceTile extends HookConsumerWidget {
  const ExpenseBalanceTile(
    this.resume, {
    required this.currencyName,
    super.key,
  });
  final ExpenseResume resume;
  final String currencyName;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;
    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);
    final profile = profileListNotifier.getProfile(resume.profileId);
    final balance = getBalance(resume);
    return ListTile(
      leading: ProfileAvatar(profile),
      title: Text(profile.name),
      trailing: BalanceAmount(
        balance,
        currencyName: currencyName,
      ),
    );
  }
}
