import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/user/user.model.dart';

class UserNotifier extends StateNotifier<TribuUser?> with Manager {
  factory UserNotifier() {
    return UserNotifier._();
  }

  UserNotifier._() : super(null) {
    initialized = initialize();
  }
  late Future<bool> initialized;
  Future<bool> initialize() async {
    final firebaseUser = FirebaseAuth.instance.currentUser ??
        (await FirebaseAuth.instance.signInAnonymously()).user;
    final tribuUserSnapshot =
        await getCollection().doc(firebaseUser!.uid).get();

    if (!tribuUserSnapshot.exists) {
      state = await createTribuUser(firebaseUser);
    } else {
      state = tribuUserSnapshot.data();
      await checkToken();
    }

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(updateFCMTokenIfNeeded);
    return true;
  }

  Future<TribuUser> createTribuUser(User firebaseUser) async {
    final token = await FirebaseMessaging.instance.getToken();
    final tribuUser =
        TribuUser(id: firebaseUser.uid, fcmTokenList: {token!: DateTime.now()});
    await getCollection().doc(firebaseUser.uid).set(tribuUser);
    return tribuUser;
  }

  Future<void> checkToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await updateFCMTokenIfNeeded(token);
    }
  }

  Future<void> updateFCMTokenIfNeeded(String token) async {
    final tribuUser = state;
    if (tribuUser != null) {
      final tokenKnown = tribuUser.fcmTokenList.containsKey(token);
      var olderThanAWeek = false;
      if (tokenKnown) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        olderThanAWeek = (currentTime -
                tribuUser.fcmTokenList[token]!.millisecondsSinceEpoch) >
            604800000;
      }
      if (!tokenKnown || olderThanAWeek) {
        await getCollection().doc(tribuUser.id).update({
          'fcmTokenList.$token': DateTime.now().toString(),
        });
      }
    }
  }

  static CollectionReference<TribuUser> getCollection() {
    return FirebaseFirestore.instance
        .collection('userList')
        .withConverter<TribuUser>(
          fromFirestore: (snapshot, _) => TribuUser.fromJson(
            snapshot.data()!..putIfAbsent('id', () => snapshot.id),
          ),
          toFirestore: (tribuUser, _) => tribuUser.toJson()..remove('id'),
        );
  }
}
