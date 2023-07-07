import 'package:tribu/data/common.providers.dart';

abstract class Encryptable {
  // ignore: avoid_unused_constructor_parameters
  Encryptable.fromEncryptedJson(Json json, String encryptionKey);
  Json encrypt(String encryptionKey);
}
