import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  throw Exception('Provider was not initialized');
});

final boxProvider = Provider<Box<dynamic>>((ref) {
  throw Exception('Provider was not initialized');
});

class Storage {
  static final boxOpenCountMap = <String, int?>{};

  static FlutterSecureStorage? _secureStorage;
  static SharedPreferences? _sharedPreferencesInstance;
  static Future<FlutterSecureStorage> getSecureStorage() async {
    if (_secureStorage != null) return _secureStorage!;
    const secureStorage = FlutterSecureStorage(
      iOptions: IOSOptions(
        groupId: 'B54HUBPLW2.com.tribu.shared',
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    if (Platform.isIOS) {
      final locale = await secureStorage.read(key: 'locale');
      if (locale == null) {
        const prevStorage = FlutterSecureStorage();
        final allValues = await prevStorage.readAll();
        allValues.forEach((key, value) {
          secureStorage.write(key: key, value: value);
        });
      }
    }
    _secureStorage = secureStorage;
    return secureStorage;
  }

  static Future<SharedPreferences> getSharedPreferences() async {
    if (_sharedPreferencesInstance != null) return _sharedPreferencesInstance!;
    _sharedPreferencesInstance = await SharedPreferences.getInstance();
    return _sharedPreferencesInstance!;
  }

  static Future<Box<T>> getHiveBox<T>(
    String boxName, {
    bool track = false,
  }) async {
    final encryptionKey = await getHiveKey(await getSecureStorage());
    boxName = boxName.toLowerCase() + FirebaseAuth.instance.currentUser!.uid;
    try {
      final box = await Hive.openBox<T>(
        boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      if (track) {
        boxOpenCountMap[boxName] = boxOpenCountMap[boxName] ?? 0;
        boxOpenCountMap[boxName] = boxOpenCountMap[boxName]! + 1;
      }
      return box;
    } catch (e) {
      await Hive.deleteBoxFromDisk(boxName);
      return getHiveBox(boxName);
    }
  }

  static Future<void> closeHiveBox(
    Box<dynamic> box, {
    bool track = false,
  }) async {
    if (track) {
      final count = boxOpenCountMap[box.name];
      if (count != null && count > 0) {
        boxOpenCountMap[box.name] = boxOpenCountMap[box.name]! - 1;
        if (boxOpenCountMap[box.name]! > 0) {
          return;
        }
      }
    }
    return box.close();
  }

  static Future<Uint8List> getHiveKey(
    FlutterSecureStorage secureStorage,
  ) async {
    final hiveKeyStorageName =
        'hive_key_${FirebaseAuth.instance.currentUser!.uid}';
    final containsEncryptionKey =
        await secureStorage.containsKey(key: hiveKeyStorageName);
    String? keyStringified;
    if (containsEncryptionKey) {
      try {
        keyStringified = await secureStorage.read(key: hiveKeyStorageName);
      } on PlatformException catch (_) {
        // Workaround for https://github.com/mogol/flutter_secure_storage/issues/43
        await secureStorage.deleteAll();
      }
    }
    if (!containsEncryptionKey || keyStringified == null) {
      final key = Hive.generateSecureKey();
      keyStringified = base64UrlEncode(key);
      await secureStorage.write(key: hiveKeyStorageName, value: keyStringified);
    }
    return base64Url.decode(keyStringified);
  }

  static Future<void> clearStorageForTribu(String tribuId) async {
    print('clearStorageForTribu $tribuId');
    final boxNameList = [
      tribuId,
      '${tribuId}MessageList',
      '${tribuId}BackgroundMessageList'
    ];
    await Future.wait(
      boxNameList.map((boxName) async {
        final box = await getHiveBox<dynamic>(boxName);
        await box.deleteAll(box.keys);
      }),
    );
  }
}
