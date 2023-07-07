import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.model.freezed.dart';
part 'user.model.g.dart';

@freezed
class TribuUser with _$TribuUser {
  factory TribuUser(
      {required String id,
      required Map<String, DateTime> fcmTokenList,}) = _TribuUser;
  factory TribuUser.fromJson(Map<String, dynamic> json) =>
      _$TribuUserFromJson(json);
}
