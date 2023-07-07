import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tool/expenses/expense/expense.model.dart';
import 'package:tribu/data/tribu/tool/expenses/expense_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/pages/with_tribu/event/tool/expenses/expenses_resume_viewer.dart';

final expenseListProvider = StateNotifierProvider.family
    .autoDispose<ExpenseListNotifier, List<Expense>, (String, String)>(
        (ref, record) {
  final (String toolId, String eventId) = record;
  final tribuId = ref.read(tribuIdSelectedProvider)!;
  final event = ref
      .watch(eventListProvider(tribuId))
      .firstWhere((element) => element.id == eventId);
  final notifier = ExpenseListNotifier(tribuId, toolId, event.encryptionKey);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final expenseResumeListProvider = Provider.family
    .autoDispose<List<ExpenseResume>, (String, String)>((ref, record) {
  final (toolId, eventId) = record;

  final tribuId = ref.read(tribuIdSelectedProvider)!;
  final event = ref.watch(eventProvider(eventId))!;
  final profileList = ref.watch(eventAttendeesProfileListProvider(event));
  final profileListNotifier = ref.watch(profileListProvider(tribuId).notifier);
  final expenseList = ref.watch(expenseListProvider((toolId, eventId)));
  final expenseResumeMap = <String, ExpenseResume>{};
  for (final profile in profileList) {
    expenseResumeMap[profile.id] = ExpenseResume(profileId: profile.id);
  }
  ExpenseResume getResume(String profileId) {
    if (!expenseResumeMap.containsKey(profileId)) {
      expenseResumeMap[profileId] = ExpenseResume(profileId: profileId);
    }
    return expenseResumeMap[profileId]!;
  }

  for (final expense in expenseList) {
    final paidBy = profileListNotifier.getProfile(expense.paidBy);
    getResume(paidBy.id).totalPayed += expense.amount;
    final dueList = expense.paidFor;
    for (final profileId in dueList) {
      getResume(profileListNotifier.getProfile(profileId).id).totalDue +=
          expense.amount / dueList.length;
    }
  }

  return expenseResumeMap.values.toList();
});

final expenseTotalProvider =
    Provider.family.autoDispose<double, (String, String)>((ref, record) {
  final expenseList = ref.watch(expenseListProvider(record));
  var res = 0.0;
  for (final element in expenseList) {
    res += element.amount;
  }
  return res;
});
