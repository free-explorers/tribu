import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/encryptable.dart';
import 'package:tribu/data/tribu/event/event_date_proposal/event_date_proposal.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';
import 'package:tribu/utils/timestamp.converter.dart';

part 'event.model.freezed.dart';
part 'event.model.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
class Event with _$Event implements Encryptable {
  Event._();
  factory Event.permanent({
    required String title, // Encrypted by self encryptionKey
    required List<String> toolIdList,
    @TimestampConverter() required DateTime createdAt,
    required String encryptionKey, // Encrypted by tribu encryption key
    String? id,
  }) = PermanentEvent;

  @JsonSerializable(explicitToJson: true)
  factory Event.punctual({
    required String title, // Encrypted by self encryptionKey
    required List<String> toolIdList,
    @TimestampConverter() required DateTime createdAt,
    required List<PunctualDateProposal>
        dateProposalList, // Encrypted by self encryptionKey
    required Map<String, bool?> attendeesMap,
    required String encryptionKey, // Encrypted by tribu encryption key
    String? id,
  }) = PunctualEvent;

  @JsonSerializable(explicitToJson: true)
  factory Event.stay({
    required String title, // Encrypted by self encryptionKey
    required List<String> toolIdList,
    @TimestampConverter() required DateTime createdAt,
    required List<StayDateProposal>
        dateProposalList, // Encrypted by self encryptionKey
    required Map<String, bool?> attendeesMap,
    required String encryptionKey, // Encrypted by tribu encryption key
    String? id,
  }) = StayEvent;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  factory Event.fromEncryptedJson(
    Json encryptedJson,
    String encryptionKey,
  ) {
    encryptedJson.update(
      'encryptionKey',
      (value) => EncryptionManager.decrypt(value as String, encryptionKey),
    );
    final eventEncryptionKey = encryptedJson['encryptionKey'] as String;
    encryptedJson.update(
      'title',
      (value) => EncryptionManager.decrypt(value as String, eventEncryptionKey),
    );
    if (encryptedJson.containsKey('dateProposalList')) {
      encryptedJson.update(
        'dateProposalList',
        (value) => (value as List<dynamic>).map(
          (e) {
            final encodedJson =
                EncryptionManager.decrypt(e as String, eventEncryptionKey);
            final decodedJson = jsonDecode(encodedJson);
            return decodedJson;
          },
        ).toList(),
      );
    }
    return Event.fromJson(encryptedJson);
  }

  @override
  Json encrypt(String tribuEncryptionKey) {
    final json = toJson();
    final eventEncryptionKey = encryptionKey;
    json
      ..update(
        'title',
        (value) =>
            EncryptionManager.encrypt(value as String, eventEncryptionKey),
      )
      ..update(
        'encryptionKey',
        (value) =>
            EncryptionManager.encrypt(value as String, tribuEncryptionKey),
      );

    if (json.containsKey('dateProposalList')) {
      json.update(
        'dateProposalList',
        (value) => (value as List<Json>)
            .map(
              (e) =>
                  EncryptionManager.encrypt(jsonEncode(e), eventEncryptionKey),
            )
            .toList(),
      );
    }
    return json;
  }
}
