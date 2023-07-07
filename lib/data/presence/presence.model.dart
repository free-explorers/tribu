import 'package:freezed_annotation/freezed_annotation.dart';

part 'presence.model.freezed.dart';
part 'presence.model.g.dart';

@freezed
class Presence with _$Presence {
  const factory Presence(
      {required String userId,
      required String route,
      required bool here, String? focus,}) = _Presence;
  factory Presence.fromJson(Map<String, dynamic> json) =>
      _$PresenceFromJson(json);
}
