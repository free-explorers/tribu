import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/utils/encryption/encryption.dart';

part 'tribu.model.freezed.dart';
part 'tribu.model.g.dart';

@freezed
class Tribu with _$Tribu {
  factory Tribu({
    required String name,
    required List<String> authorizedMemberList,
    required int modelVersion,
    String? id,
  }) = _Tribu;
  factory Tribu.fromJson(Map<String, dynamic> json) => _$TribuFromJson(json);

  factory Tribu.fromEncryptedJson(Map<String, dynamic> json, String key) {
    json.update(
      'name',
      (encryptedString) =>
          EncryptionManager.decrypt(encryptedString as String, key),
    );
    return Tribu.fromJson(json);
  }
}
