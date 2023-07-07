import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

import 'package:tribu/utils/timestamp.converter.dart';

part 'message.model.freezed.dart';
part 'message.model.g.dart';

@freezed
class Message with _$Message {
  @HiveType(typeId: 0)
  @JsonSerializable(explicitToJson: true)
  const factory Message({
    @HiveField(1) required String text,
    @HiveField(2) required String author,
    @HiveField(3) required String status,
    @HiveField(4) @TimestampConverter() required DateTime sentAt,
    @HiveField(0) String? id,
    @HiveField(5) Map<String, bool>? receivedBy,
    @HiveField(6) List<Media>? mediaList,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  static Map<String, dynamic> decryptJson(
    Map<String, dynamic> json,
    String encryptionKey,
  ) {
    return EncryptionManager.decryptFields(
      json,
      ['text'],
      encryptionKey,
    );
  }
}
