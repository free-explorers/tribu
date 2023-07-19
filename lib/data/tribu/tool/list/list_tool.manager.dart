import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/tribu/tool/list/item/list_item.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

class ListToolManager extends StateNotifier<List<ListItem>> with Manager {
  factory ListToolManager(String tribuId, String toolId, String encryptionKey) {
    // Call the private constructor
    final stream = getCollection(tribuId, toolId, encryptionKey)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((listItems) => listItems.docs.map((e) => e.data()).toList());
    final component = ListToolManager._(tribuId, toolId, encryptionKey, stream);

    return component;
  }
  ListToolManager._(
    this.tribuId,
    this.toolId,
    this.encryptionKey,
    this.listItemListStream,
  ) : super([]) {
    onDisposeList.add(
      listItemListStream.listen((itemList) {
        state = itemList;
      }).cancel,
    );
  }
  final String tribuId;
  final String toolId;
  final String encryptionKey;
  final Stream<List<ListItem>> listItemListStream;

  Future<void> addItem(ListItem item) async {
    await getCollection(tribuId, toolId, encryptionKey).add(item);
  }

  Future<void> updateItem(ListItem updatedItem) async {
    var item = updatedItem;
    final originalItem = state.firstWhere((element) => element.id == item.id);
    if (originalItem.checked != item.checked) {
      item = item.copyWith(updatedAt: DateTime.now());
    }

    await getCollection(tribuId, toolId, encryptionKey).doc(item.id).set(item);
  }

  Future<void> deleteItem(ListItem item) async {
    await getCollection(tribuId, toolId, encryptionKey).doc(item.id).delete();
  }

  static CollectionReference<ListItem> getCollection(
    String tribuId,
    String toolId,
    String encryptionKey,
  ) {
    return FirebaseFirestore.instance
        .collection('tribuList')
        .doc(tribuId)
        .collection('toolList')
        .doc(toolId)
        .collection('listItemList')
        .withConverter<ListItem>(
      fromFirestore: (snapshot, _) {
        return ListItem.fromJson(
          EncryptionManager.decryptFields(
            snapshot.data()!..putIfAbsent('id', () => snapshot.id),
            ['label'],
            encryptionKey,
          ),
        );
      },
      toFirestore: (listItem, _) {
        final json = listItem.toJson()
          ..remove('id')
          ..update(
            'createdAt',
            (value) => value ?? FieldValue.serverTimestamp(),
          )
          ..update(
            'updatedAt',
            (value) => value ?? FieldValue.serverTimestamp(),
          );
        return EncryptionManager.encryptFields(json, ['label'], encryptionKey);
      },
    );
  }
}
