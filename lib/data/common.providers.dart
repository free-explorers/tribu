import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef Json = Map<String, dynamic>;

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final currentUserProvider =
    Provider((ref) => FirebaseAuth.instance.currentUser);

final firebaseMessagingProvider = Provider((ref) => FirebaseMessaging.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  throw Exception('Provider was not initialized');
});
//final appRouterProvider = Provider((ref) => AppRouter());

class PageListNotifier extends StateNotifier<List<MaterialPage<dynamic>>> {
  PageListNotifier() : super(const []);
  List<MaterialPage<dynamic>> get list => state.toList();
  void push(MaterialPage<dynamic> page) {
    final existingPage =
        state.firstWhereOrNull((element) => element.key == page.key);
    if (existingPage != null) pop(page: existingPage);
    state = [...state, page];
  }

  void pop({MaterialPage<dynamic>? page}) {
    if (page != null) {
      state = [...state..remove(page)];
    } else {
      state = [...state..removeLast()];
    }
  }
}

final pageListProvider =
    StateNotifierProvider<PageListNotifier, List<MaterialPage<dynamic>>>(
  (ref) => throw Exception('Provider was not initialized'),
);

final mainScaffoldKeyProvider = Provider((ref) => GlobalKey<ScaffoldState>());

final unlockBottomInsetResize = StateProvider((ref) => false);

final notificationPluginProvider = Provider<FlutterLocalNotificationsPlugin>(
  (ref) => throw Exception('Provider was not initialized'),
);

final tabIndexSelectedProvider = StateProvider((ref) => 0);

final tribuIdLoadedMapProvider = Provider<Map<String, bool>>(
  (ref) => throw Exception('Provider was not initialized'),
);

final packageInfoProvider = Provider<PackageInfo>(
  (ref) => throw Exception('Provider was not initialized'),
);
