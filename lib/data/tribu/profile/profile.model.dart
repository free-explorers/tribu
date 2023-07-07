import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tribu/utils/timestamp.converter.dart';

part 'profile.model.freezed.dart';
part 'profile.model.g.dart';

@freezed
class Profile with _$Profile {
  factory Profile(
      {required String id,
      required String name,
      @TimestampConverter() required DateTime createdAt,
      String? mergedInto,
      bool? disabled,
      bool? external,}) = _Profile;
  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
