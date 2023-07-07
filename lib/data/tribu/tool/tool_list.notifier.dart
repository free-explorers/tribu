import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';

class ToolListNotifier extends StateNotifier<List<Tool>> with Manager {
  factory ToolListNotifier(
    String tribuId,
    List<String> toolIdList,
    String encryptionKey,
  ) {
    var stream = const Stream<List<Tool>>.empty();
    if (toolIdList.isNotEmpty) {
      stream = getCollection(tribuId, encryptionKey)
          .where(FieldPath.documentId, whereIn: toolIdList)
          .snapshots()
          .map((event) => event.docs.map((e) => e.data()).toList());
    }

    final component =
        ToolListNotifier._(tribuId, toolIdList, encryptionKey, stream);

    return component;
  }
  ToolListNotifier._(
    this.tribuId,
    this.toolIdList,
    this.encryptionKey,
    this.toolListStream,
  ) : super([]) {
    onDisposeList.add(toolListStream.listen((event) => state = event).cancel);
  }
  final String tribuId;
  final List<String> toolIdList;
  final String encryptionKey;
  final Stream<List<Tool>> toolListStream;

  Future<void> updateTool(Tool tool) async {
    await getCollection(tribuId, encryptionKey).doc(tool.id).set(tool);
  }

  DocumentReference<Tool> getToolDoc(String toolId) {
    return getCollection(tribuId, encryptionKey).doc(toolId);
  }

  static CollectionReference<Tool> getCollection(
    String tribuId,
    String encryptionKey,
  ) {
    return FirebaseFirestore.instance
        .collection('tribuList')
        .doc(tribuId)
        .collection('toolList')
        .withConverter<Tool>(
      fromFirestore: (snapshot, _) {
        return Tool.fromEncryptedJson(
          snapshot.data()!..putIfAbsent('id', () => snapshot.id),
          encryptionKey,
        );
      },
      toFirestore: (tool, _) {
        return tool.encrypt(encryptionKey)..remove('id');
      },
    );
  }
}
