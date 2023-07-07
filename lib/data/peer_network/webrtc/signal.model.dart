import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tribu/utils/timestamp.converter.dart';

part 'signal.model.freezed.dart';
part 'signal.model.g.dart';

@freezed
class Signal with _$Signal {
  factory Signal(
      {String? id, @TimestampNullableConverter() DateTime? helloAt,}) = _Signal;
  factory Signal.fromJson(Map<String, dynamic> json) => _$SignalFromJson(json);
}
