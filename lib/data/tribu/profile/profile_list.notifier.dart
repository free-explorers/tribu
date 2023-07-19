import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

class ProfileListNotifier extends StateNotifier<List<Profile>> with Manager {
  factory ProfileListNotifier(String tribuId, String encryptionKey) {
    // Call the private constructor
    final completer = Completer<bool>();
    final firebaseStream = getCollection(tribuId, encryptionKey)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList())
      ..first.then((value) {
        completer.complete(true);
      });

    return ProfileListNotifier._(
      tribuId,
      encryptionKey,
      firebaseStream,
      completer.future,
    );
  }
  ProfileListNotifier._(
    this.tribuId,
    this.encryptionKey,
    this.profileListStream,
    this.initialized,
  ) : super([]) {
    onDisposeList.add(
      profileListStream.listen((profileList) {
        allProfileMapById = {
          for (var profile in profileList) profile.id: profile
        };
        state = profileList
            .where(
              (element) =>
                  element.mergedInto == null && element.disabled == null,
            )
            .toList();
      }).cancel,
    );
    //updateOnline();
  }
  List<Profile> get value => state;
  final String tribuId;
  final String encryptionKey;
  Map<String, Profile> allProfileMapById = {};
  final Stream<List<Profile>> profileListStream;
  final Future<bool> initialized;

  static Future<void> createProfile(String tribuId, Profile profile) async {
    final encryptionKey = await EncryptionManager.getKey(tribuId);
    await getCollection(tribuId, encryptionKey).doc(profile.id).set(profile);
  }

  Future<void> createExternalProfile(String profileName) async {
    final collection = getCollection(tribuId, encryptionKey);
    final profileRef = collection.doc();
    final profileToCreate = Profile(
      id: profileRef.id,
      name: profileName,
      createdAt: DateTime.now(),
      external: true,
    );
    await profileRef.set(profileToCreate);
  }

  Future<void> updateProfile(Profile profile) {
    return getCollection(tribuId, encryptionKey).doc(profile.id).set(profile);
  }

  Profile getMyProfile() {
    return getProfile(FirebaseAuth.instance.currentUser!.uid);
  }

  Profile getProfile(String userId) {
    final checkedProfile = <String>[];
    Profile? profileFound;
    do {
      final userIdToSearch = profileFound?.mergedInto ?? userId;
      if (checkedProfile.contains(userIdToSearch)) {
        throw Exception('Profile merge loop detected $checkedProfile');
      }
      checkedProfile.add(userIdToSearch);
      profileFound = allProfileMapById[userIdToSearch];
      if (profileFound == null) throw Exception('Profile cannot be found');
    } while (profileFound.mergedInto != null);

    return profileFound;
  }

  static CollectionReference<Profile> getCollection(
    String tribuId,
    String encryptionKey,
  ) {
    return FirebaseFirestore.instance
        .collection('tribuList')
        .doc(tribuId)
        .collection('profileList')
        .withConverter<Profile>(
      fromFirestore: (snapshot, _) {
        final json = snapshot.data()!
          ..putIfAbsent('id', () => snapshot.id)
          ..update(
            'createdAt',
            (value) => value ?? Timestamp.fromDate(DateTime.now()),
            ifAbsent: () => Timestamp.fromDate(DateTime.now()),
          );

        return Profile.fromJson(
          EncryptionManager.decryptFields(json, ['name'], encryptionKey),
        );
      },
      toFirestore: (profile, _) {
        final json = profile.toJson()
          ..remove('id')
          ..update(
            'createdAt',
            (value) => profile.createdAt.minute == DateTime.now().minute
                ? FieldValue.serverTimestamp()
                : value,
          );
        return EncryptionManager.encryptFields(json, ['name'], encryptionKey);
      },
    );
  }
}
