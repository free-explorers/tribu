import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';

part 'notification_data.model.freezed.dart';
part 'notification_data.model.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
class NotificationData with _$NotificationData {
  factory NotificationData.message({
    required String tribuId,
    required Message json,
  }) = MessageNotificationData;

  factory NotificationData.newMember({
    required String tribuId,
    required Profile json,
  }) = NewMemberNotificationData;

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);
}
