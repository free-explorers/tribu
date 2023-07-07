import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/utils/timestamp.converter.dart';

part 'signal_description.model.freezed.dart';
part 'signal_description.model.g.dart';

@freezed
class SignalDescription with _$SignalDescription {
  @JsonSerializable(explicitToJson: true)
  const factory SignalDescription({
    @RTCSessionDescriptionConverter() required RTCSessionDescription offer,
    required String offeredBy,
    String? id,
    @RTCSessionDescriptionNullableConverter() RTCSessionDescription? answer,
    @TimestampNullableConverter() DateTime? offeredAt,
  }) = _SignalDescription;
  factory SignalDescription.fromJson(Map<String, dynamic> json) =>
      _$SignalDescriptionFromJson(json);
}

class RTCSessionDescriptionConverter
    implements JsonConverter<RTCSessionDescription, Map<String, dynamic>> {
  const RTCSessionDescriptionConverter();

  @override
  RTCSessionDescription fromJson(Map<String, dynamic> json) =>
      RTCSessionDescription(json['sdp'] as String, json['type'] as String);

  @override
  Map<String, dynamic> toJson(RTCSessionDescription object) {
    return object.toMap() as Json;
  }
}

class RTCSessionDescriptionNullableConverter
    implements JsonConverter<RTCSessionDescription?, Map<String, dynamic>?> {
  const RTCSessionDescriptionNullableConverter();

  @override
  RTCSessionDescription? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return RTCSessionDescription(json['sdp'] as String, json['type'] as String);
  }

  @override
  Map<String, dynamic>? toJson(RTCSessionDescription? object) =>
      object?.toMap() as Json;
}
