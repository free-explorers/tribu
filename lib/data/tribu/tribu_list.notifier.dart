import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tribu/data/data_model.manager.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event_list.notifier.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile_list.notifier.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/event/tool/list/edit_list_tool_form.dart';
import 'package:tribu/storage.dart';
import 'package:tribu/utils/encryption/encryption.dart';

class TribuListNotifier extends StateNotifier<List<Tribu>> {
  factory TribuListNotifier(FlutterSecureStorage secureStorage) {
    final stream = getCollection()
        .where(
          'authorizedMemberList',
          arrayContains: FirebaseAuth.instance.currentUser!.uid,
        )
        .snapshots()
        .map((event) {
      return event.docs.map((e) => e.data()).toList();
    });
    return TribuListNotifier._(secureStorage, stream);
  }

  TribuListNotifier._(this.secureStorage, this._firestoreStream) : super([]) {
    _firestoreStream.listen((event) {
      state = event;
    });
    initialized = initialize();
  }
  List<Tribu> get value => state;
  final FlutterSecureStorage secureStorage;
  final Stream<List<Tribu>> _firestoreStream;
  late Future<bool> initialized;

  Future<bool> initialize() async {
    await _firestoreStream.first;
    return true;
  }

  Future<Tribu?> getTribu(String tribuId) async {
    return (await getCollection().doc(tribuId).get()).data();
  }

  Future<Tribu> createTribu(String name, String memberName) async {
    final tribuDoc = getCollection().doc();
    final newTribu = Tribu(
      id: tribuDoc.id,
      name: name,
      modelVersion: currentModelVersion,
      authorizedMemberList: [FirebaseAuth.instance.currentUser!.uid],
    );
    final tribuEncryptionKey = await EncryptionManager.generateKey(tribuDoc.id);
    await tribuDoc.set(newTribu);
    await ProfileListNotifier.createProfile(
      tribuDoc.id,
      Profile(
        id: FirebaseAuth.instance.currentUser!.uid,
        name: memberName,
        createdAt: DateTime.now(),
      ),
    );
    final eventEncryptionKey = Key.fromSecureRandom(32).base64;

    final batch = FirebaseFirestore.instance.batch();

    final shoppingListDoc =
        ToolListNotifier.getCollection(tribuDoc.id, eventEncryptionKey).doc();
    batch.set(
      shoppingListDoc,
      Tool.list(
        name: listToolDefault['shopping']!.label(),
        icon: listToolDefault['shopping']!.iconName,
      ),
    );

    final todoListDoc =
        ToolListNotifier.getCollection(tribuDoc.id, eventEncryptionKey).doc();
    batch.set(
      todoListDoc,
      Tool.list(
        name: listToolDefault['todo']!.label(),
        icon: listToolDefault['todo']!.iconName,
      ),
    );

    final expensesListDoc =
        ToolListNotifier.getCollection(tribuDoc.id, eventEncryptionKey).doc();
    batch.set(
      expensesListDoc,
      Tool.expenses(
        name: S.current.expenseToolName,
        currency: NumberFormat.compactCurrency().currencyName!,
      ),
    );

    final eventDoc =
        EventListNotifier.getCollection(tribuDoc.id, tribuEncryptionKey).doc();

    batch.set(
      eventDoc,
      PermanentEvent(
        title: S.current.defaultPermanentEventName,
        toolIdList: [shoppingListDoc.id, todoListDoc.id, expensesListDoc.id],
        createdAt: DateTime.now(),
        encryptionKey: eventEncryptionKey,
      ),
    );
    await batch.commit();
    return newTribu;
  }

  Future<void> joinTribu(
    Tribu tribu,
    String encryptionKey,
    Profile profile,
  ) async {
    await secureStorage.write(key: tribu.id!, value: encryptionKey);
    await getCollection().doc(tribu.id).update({
      'authorizedMemberList':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
    });
    await ProfileListNotifier.createProfile(tribu.id!, profile);
  }

  Future<void> leaveTribu(Tribu tribu) async {
    await Future.wait([
      getCollection().doc(tribu.id).update({
        'authorizedMemberList':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      }),
      Storage.clearStorageForTribu(tribu.id!),
    ]);
    await EncryptionManager.deleteKey(tribu.id!);
  }

  static CollectionReference<Tribu> getCollection() {
    return FirebaseFirestore.instance
        .collection('tribuList')
        .withConverter<Tribu>(
          fromFirestore: (snapshot, _) => Tribu.fromJson(
            snapshot.data()!..putIfAbsent('id', () => snapshot.id),
          ),
          toFirestore: (tribu, _) => tribu.toJson()..remove('id'),
        );
  }
}
