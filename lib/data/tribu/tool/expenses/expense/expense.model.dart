import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tribu/utils/timestamp.converter.dart';

part 'expense.model.freezed.dart';
part 'expense.model.g.dart';

@freezed
class Expense with _$Expense {
  factory Expense({
    required String label,
    required double amount,
    required String paidBy,
    String? id,
    @Default([]) List<String> paidFor,
    @TimestampNullableConverter() DateTime? createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
