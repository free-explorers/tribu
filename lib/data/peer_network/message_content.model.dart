import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/data/presence/presence.model.dart';

part 'message_content.model.freezed.dart';
part 'message_content.model.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
class MessageContent with _$MessageContent {
  factory MessageContent.presence({required Presence payload}) =
      PresenceMessageContent;
  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);
}
