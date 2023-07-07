import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/data/peer_network/decrypted_message.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

part 'encrypted_message.model.freezed.dart';
part 'encrypted_message.model.g.dart';

@freezed
class EncryptedMessage with _$EncryptedMessage {
  const factory EncryptedMessage({
    required String forUserId,
    required String fromUserId,
    required String tribuId,
    required String encryptedContent,
  }) = _EncryptedMessage;
  factory EncryptedMessage.fromJson(Map<String, dynamic> json) =>
      _$EncryptedMessageFromJson(json);

  factory EncryptedMessage.encrypt(
    DecryptedMessage decryptedMessage,
    String encryptionKey,
  ) {
    return EncryptedMessage(
      forUserId: decryptedMessage.forUserId,
      fromUserId: decryptedMessage.fromUserId,
      tribuId: decryptedMessage.tribuId,
      encryptedContent: EncryptionManager.encrypt(
        jsonEncode(decryptedMessage.content),
        encryptionKey,
      ),
    );
  }
}
