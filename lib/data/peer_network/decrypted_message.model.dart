import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/peer_network/encrypted_message.model.dart';
import 'package:tribu/data/peer_network/message_content.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

part 'decrypted_message.model.freezed.dart';
part 'decrypted_message.model.g.dart';

@freezed
class DecryptedMessage with _$DecryptedMessage {
  const factory DecryptedMessage({
    required String forUserId,
    required String fromUserId,
    required String tribuId,
    required MessageContent content,
  }) = _DecryptedMessage;

  factory DecryptedMessage.fromJson(Map<String, dynamic> json) =>
      _$DecryptedMessageFromJson(json);

  factory DecryptedMessage.decrypt(
    EncryptedMessage encryptedMessage,
    String encryptionKey,
  ) {
    final decryptedData = EncryptionManager.decrypt(
      encryptedMessage.encryptedContent,
      encryptionKey,
    );
    return DecryptedMessage(
      forUserId: encryptedMessage.forUserId,
      fromUserId: encryptedMessage.fromUserId,
      tribuId: encryptedMessage.tribuId,
      content: MessageContent.fromJson(
        jsonDecode(decryptedData) as Json,
      ),
    );
  }
}
