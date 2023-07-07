// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tribu/utils/timestamp.converter.dart';

part 'list_item.model.freezed.dart';
part 'list_item.model.g.dart';

@freezed
class ListItem with _$ListItem {
  factory ListItem(
      {required String label, String? id,
      @Default(false) bool checked,
      @Default([]) List<String> assignedList,
      @TimestampNullableConverter() DateTime? createdAt,
      @TimestampNullableConverter() DateTime? updatedAt,}) = _ListItem;

  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);
}
