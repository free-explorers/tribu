import 'dart:math';

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
import 'package:tribu/theme.dart';
import 'package:tribu/widgets/currency/currency.widget.dart';
import 'package:tribu/widgets/profile/profile_viewer.widget.dart';

class ExpenseSmartBalancePage extends HookConsumerWidget {
  const ExpenseSmartBalancePage({
    required this.toolId,
    required this.eventId,
    super.key,
  });
  final String toolId;
  final String eventId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryTheme = ref.watch(primaryThemeProvider);
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final toolList = ref.watch(toolListProvider(eventId));

    final toolSelected = useMemoized(
      () => toolList.firstWhere((aTool) => aTool.id == toolId),
      [toolList],
    ) as ExpensesTool;

    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);

    final balanceList = ref
        .watch(expenseResumeListProvider((toolSelected.id!, eventId)))
        .map(
          (resume) => BalanceResume(
            resume.profileId,
            resume.totalPayed - resume.totalDue,
          ),
        )
        .toList();

    List<BalanceResume> getDebtList() =>
        balanceList.where((e) => e.balance < 0).toList()
          ..sort((a, b) => a.balance.compareTo(b.balance));

    List<BalanceResume> getCreditList() =>
        balanceList.where((e) => e.balance > 0).toList()
          ..sort((a, b) => b.balance.compareTo(a.balance));

    final payBackMap = <String, List<BalancePayBack>>{};
    while (getDebtList().isNotEmpty && getCreditList().isNotEmpty) {
      final debt = getDebtList().first;
      final credit = getCreditList().first;
      final amount = min(debt.balance.abs(), credit.balance.abs());
      payBackMap
          .putIfAbsent(debt.profileId, () => [])
          .add(BalancePayBack(debt.profileId, credit.profileId, amount));
      debt.balance += amount;
      credit.balance -= amount;
    }

    return Theme(
      data: primaryTheme,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(MdiIcons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(S.of(context).balanceAction),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: ListView.separated(
            itemCount: payBackMap.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: 8,
            ),
            itemBuilder: (context, index) {
              final payBackList =
                  payBackMap[payBackMap.keys.toList().elementAt(index)]!;
              final balance = payBackList
                  .map((e) => e.amount)
                  .reduce((value, element) => value + element);
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ProfileViewer(
                            profileListNotifier
                                .getProfile(payBackList.first.from),
                          ),
                          const Spacer(),
                          BalanceAmount(
                            -balance,
                            currencyName: toolSelected.currency,
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    ...payBackList.map(
                      (e) => ListTile(
                        textColor: Theme.of(context).colorScheme.secondary,
                        title: Row(
                          children: [
                            CurrencyViewer(
                              e.amount,
                              currencyName: toolSelected.currency,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Icon(
                                MdiIcons.chevronDoubleRight,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            ProfileViewer(
                              profileListNotifier.getProfile(e.to),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BalanceResume {
  BalanceResume(this.profileId, this.balance);
  final String profileId;
  double balance;
}

class BalancePayBack {
  BalancePayBack(this.from, this.to, this.amount);
  final String from;
  final String to;
  final double amount;
}
