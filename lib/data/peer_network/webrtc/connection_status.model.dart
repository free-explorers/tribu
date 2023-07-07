import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_status.model.freezed.dart';
part 'connection_status.model.g.dart';

@freezed
class ConnectionStatus with _$ConnectionStatus {
  const factory ConnectionStatus(
      {required RTCDataChannelState state,
      required String userId,}) = _ConnectionStatus;
  factory ConnectionStatus.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStatusFromJson(json);
}
