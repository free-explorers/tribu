import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/tribu/tool/expenses/expense/expense.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

class ExpenseListNotifier extends StateNotifier<List<Expense>> with Manager {
  factory ExpenseListNotifier(
    String tribuId,
    String toolId,
    String encryptionKey,
  ) {
    // Call the private constructor
    final stream = getCollection(tribuId, toolId, encryptionKey)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());

    return ExpenseListNotifier._(tribuId, toolId, encryptionKey, stream);
  }
  ExpenseListNotifier._(
    this.tribuId,
    this.toolId,
    this.encryptionKey,
    this.expenseListStream,
  ) : super([]) {
    onDisposeList.add(
      expenseListStream.listen((event) {
        state = event;
      }).cancel,
    );
  }
  final String tribuId;
  final String toolId;
  final String encryptionKey;
  final Stream<List<Expense>> expenseListStream;

  Future<void> addExpense(Expense expense) async {
    await getCollection(tribuId, toolId, encryptionKey).add(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await getCollection(tribuId, toolId, encryptionKey)
        .doc(expense.id)
        .set(expense);
  }

  Future<void> deleteExpense(Expense expense) async {
    await getCollection(tribuId, toolId, encryptionKey)
        .doc(expense.id)
        .delete();
  }

  static CollectionReference<Expense> getCollection(
    String tribuId,
    String toolId,
    String encryptionKey,
  ) {
    return FirebaseFirestore.instance
        .collection('tribuList')
        .doc(tribuId)
        .collection('toolList')
        .doc(toolId)
        .collection('expenseList')
        .withConverter<Expense>(
      fromFirestore: (snapshot, _) {
        return Expense.fromJson(
          EncryptionManager.decryptFields(
            snapshot.data()!..putIfAbsent('id', () => snapshot.id),
            ['label'],
            encryptionKey,
          ),
        );
      },
      toFirestore: (expense, _) {
        final json = expense.toJson()
          ..remove('id')
          ..update(
            'createdAt',
            (value) => value ?? FieldValue.serverTimestamp(),
          );
        return EncryptionManager.encryptFields(json, ['label'], encryptionKey);
      },
    );
  }
}
