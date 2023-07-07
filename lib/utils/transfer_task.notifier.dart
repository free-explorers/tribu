import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/manager.abstract.dart';

class TransferTaskManager extends StateNotifier<Map<String, Task>>
    with Manager {

  TransferTaskManager() : super({});
  static Map<String, Task> tasks = {};

  UploadTask uploadFile(File file, String remotePath, {String? contentType}) {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child(remotePath);

    final metaData =
        contentType != null ? SettableMetadata(contentType: contentType) : null;

    final task = fileRef.putFile(file, metaData);
    state[remotePath] = task;
    state = Map.from(state);

    return task;
  }

  DownloadTask downloadFile(String remotePath, File destinationFile) {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child(remotePath);

    final task = fileRef.writeToFile(destinationFile);

    state[remotePath] = task;
    state = Map.from(state);
    return task;
  }
}

final transferTaskManagerProvider =
    StateNotifierProvider<TransferTaskManager, Map<String, Task>>(
        (ref) => TransferTaskManager(),);

final transferTaskProvider = Provider.family<Task?, String>((ref, remotePath) {
  return ref
      .watch(transferTaskManagerProvider.select((map) => map[remotePath]));
});
final transferTaskSnapshotEventsProvider =
    StreamProvider.family<TaskSnapshot?, String>((ref, remotePath) async* {
  final task = ref.watch(transferTaskProvider(remotePath));
  if (task != null) {
    yield task.snapshot;
    yield* task.snapshotEvents;
  } else {
    yield null;
  }
});

final transferTaskStatusProvider =
    Provider.family<TaskState?, String>((ref, remotePath) {
  final task = ref.watch(transferTaskProvider(remotePath));
  /* final state = ref.watch(transferTaskSnapshotEventsProvider(remotePath));
  ref.listen<TaskSnapshot?>(transferTaskSnapshotEventsProvider(remotePath),
      (previous, next) {
    
  }); */
  final currentState = task?.snapshot.state;
  if (task != null) {
    final sub = task.snapshotEvents.listen((event) {
      if (event.state != currentState) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(sub.cancel);
  }

  return task?.snapshot.state;
});
