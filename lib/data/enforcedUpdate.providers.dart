import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';

final enforcedUpdateVersionProvider = StreamProvider<String>((ref) {
  final docString =
      Platform.isAndroid ? 'enforcedAndroidVersion' : 'enforcedIosVersion';
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('tribuParams')
      .doc(docString)
      .snapshots()
      .map((snapshot) => snapshot.data()!['value'] as String);
});

final enforcedUpdateRequiredProvider = Provider<bool>((ref) {
  final currentVersion =
      ref.watch(packageInfoProvider.select((infos) => infos.version));

  final enforcedVersionAsync = ref.watch(enforcedUpdateVersionProvider);
  if (enforcedVersionAsync.hasValue) {
    final enforcedVersion = enforcedVersionAsync.value!;
    final currentVersionList =
        currentVersion.split('.').map(int.parse).toList();
    final enforcedVersionList =
        enforcedVersion.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      if (enforcedVersionList[i] > currentVersionList[i]) return true;
    }
  }
  return false;
});
