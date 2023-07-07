import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:tribu/storage.dart';
import 'package:tribu/utils/encryption/decrypt_file.isolate.dart';
import 'package:tribu/utils/encryption/encrypt_file.isolate.dart';

class EncryptionManager {
  static Future<String> generateKey(String tribuId) async {
    final key = Key.fromSecureRandom(32).base64;
    final secureStorage = await Storage.getSecureStorage();
    await secureStorage.write(key: tribuId, value: key);
    return key;
  }

  static Future<void> deleteKey(String tribuId) async {
    final secureStorage = await Storage.getSecureStorage();
    await secureStorage.delete(key: tribuId);
  }

  static Future<String> getKey(String tribuId) async {
    final secureStorage = await Storage.getSecureStorage();
    final key = await secureStorage.read(key: tribuId);
    return key!;
  }

  static String encrypt(String text, String key) {
    if (text.isEmpty) return text;
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(Key.fromBase64(key)));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64 + iv.base64;
  }

  static Uint8List encryptBytes(Uint8List bytes, String key) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(Key.fromBase64(key)));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    final b = BytesBuilder()
      ..add(encrypted.bytes)
      ..add(iv.bytes);
    return b.toBytes();
  }

  static String decrypt(String encryptedTextWithIV, String key) {
    if (encryptedTextWithIV.isEmpty) return encryptedTextWithIV;
    final encryptedText =
        encryptedTextWithIV.substring(0, encryptedTextWithIV.length - 24);
    final iv = IV.fromBase64(
      encryptedTextWithIV.substring(encryptedTextWithIV.length - 24),
    );
    final encrypter = Encrypter(AES(Key.fromBase64(key)));
    final encrypted = Encrypted.from64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  static Uint8List decryptBytes(Uint8List bytesWithIV, String key) {
    final bytesToDecode = bytesWithIV.sublist(0, bytesWithIV.length - 16);
    final IVBytes =
        bytesWithIV.sublist(bytesWithIV.length - 16, bytesWithIV.length);
    final iv = IV(IVBytes);
    final encrypter = Encrypter(AES(Key.fromBase64(key)));
    final encrypted = Encrypted(bytesToDecode);
    return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
  }

  static Map<String, dynamic> encryptFields(
    Map<String, dynamic> json,
    List<String> fields,
    String key,
  ) {
    for (final field in fields) {
      json.update(
        field,
        (value) => encrypt(value as String, key),
        ifAbsent: () => null,
      );
    }
    return json;
  }

  static Map<String, dynamic> decryptFields(
    Map<String, dynamic> json,
    List<String> fields,
    String key,
  ) {
    for (final field in fields) {
      json.update(
        field,
        (value) => decrypt(value as String, key),
        ifAbsent: () => null,
      );
    }
    return json;
  }

  static Future<File> encryptFile(
    File file,
    String destinationPath,
    String key,
  ) {
    return foundation.compute(
      encryptFileIsolate,
      FileEncryptionParams(file, destinationPath, key),
    );
  }

  static Future<File> decryptFile(
    File file,
    String destinationPath,
    String key,
  ) {
    return foundation.compute(
      decryptFileIsolate,
      FileDecryptionParams(file, destinationPath, key),
    );
  }
}
