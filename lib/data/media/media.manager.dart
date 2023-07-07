import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/data/media/media_in_transition.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/theme.dart';
import 'package:tribu/utils/encryption/encryption.dart';
import 'package:tribu/utils/media/image.dart';
import 'package:tribu/utils/transfer_task.notifier.dart';

class MediaManager extends StateNotifier<Map<String, MediaInTransition>>
    with Manager {
  MediaManager(
    this.tribuId,
    this.encryptionKey,
    this.transferTaskManager,
    this.temporaryDirectory,
    this.permanentDirectory,
  ) : super({});
  final String tribuId;
  final String encryptionKey;
  final TransferTaskManager transferTaskManager;
  final Directory temporaryDirectory;
  final Directory permanentDirectory;

  Future<Media> processPathToMedia(String path) async {
    final inputFile = File(path);
    final creationDate = DateTime.now();
    final localPath = generateUniquePath(tribuId, creationDate, path);
    var fileToProcess =
        await File('${permanentDirectory.absolute.path}/$localPath')
            .create(recursive: true);

    fileToProcess = await inputFile.copy(fileToProcess.path);

    // Get File dimension
    final size = await ImageUtils.getImageSize(fileToProcess);

    final blurhash = await compute(blurhashCompute, fileToProcess);
    return Media(
      createdAt: DateTime.now(),
      mime: lookupMimeType(path)!,
      localPath: localPath,
      additionalData: {
        'width': size.width,
        'height': size.height,
        'blurhash': blurhash
      },
    );
  }

  Future<List<String>> pickMediaList(BuildContext context) async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    if (result != null) {
      final pathList = result.paths.whereType<String>().toList();
      if (result.paths.length > 6) {
        await showDialog<Widget>(
          context: context,
          builder: (context) => Consumer(
            builder: (context, ref, child) {
              return Theme(
                data: ref.read(primaryThemeProvider),
                child: AlertDialog(
                  content: Text(S.of(context).maximumFilePerMessage(6)),
                  actions: [
                    TextButton(
                      child: Text(S.of(context).confirmAction),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                    )
                  ],
                ),
              );
            },
          ),
        );
        return [];
      }

      final fileSizeList =
          await Future.wait(pathList.map((path) => File(path).length()));
      //check file size
      for (final sizeInBytes in fileSizeList) {
        final sizeInMegaBytes = sizeInBytes / (1024 * 1024);
        const sizeInMegaBytesLimit = 10;
        if (sizeInMegaBytes > sizeInMegaBytesLimit) {
          await showDialog<Widget>(
            context: context,
            builder: (context) => Consumer(
              builder: (context, ref, child) {
                return Theme(
                  data: ref.read(primaryThemeProvider),
                  child: AlertDialog(
                    content: Text(
                      S
                          .of(context)
                          .aFileIsLargerThanTheLimit(sizeInMegaBytesLimit),
                    ),
                    actions: [
                      TextButton(
                        child: Text(S.of(context).confirmAction),
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                      )
                    ],
                  ),
                );
              },
            ),
          );
          return [];
        }
      }
      return pathList;
    }
    return [];
  }

/* Future<File> generateMediaThumbnail(String filePath, int desiredSize) async {
    final thumbnailDirectory = await getPermanentDirectory();
    final destinationPath = await getThumbnailPath(filePath);
    final mime = lookupMimeType(filePath)!;


    final exif = await readExifFromFile(File(filePath));

    Uint8List? exifBytes;
    if (exif.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      final field = exif['JPEGThumbnail'] as IfdTag;
      final ifdBytes = field.values as IfdBytes;
      exifBytes = ifdBytes.bytes;
    } else if (exif.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      final field = exif['TIFFThumbnail'] as IfdTag;
      final ifdBytes = field.values as IfdBytes;
      exifBytes = ifdBytes.bytes;
    }

    print('exif length ${exif.length}');
    for (final entry in exif.entries) {
      print("${entry.key}: ${entry.value}");
    }

    if (exifBytes != null) {
      final file = await File(destinationPath).create(recursive: true);
      await file.writeAsBytes(exifBytes);
      return file;
    }

    if (mime.contains('video')) {
/*       await VideoThumbnail.thumbnailFile(
          video: filePath,
          thumbnailPath: destinationPath,
          maxHeight: desiredSize); */

      final thumbnailBytes = await VideoCompress.getByteThumbnail(filePath,
          quality: 10, // default(100)
          position: -1 // default(-1)
          );
      final file = await File(destinationPath).create(recursive: true);
      await file.writeAsBytes(thumbnailBytes!);
      return file;
    } else if (mime.contains('image')) {
      /* await compute(resizeImage,
        ResizeTaskParams(filePath!, destinationPath, maxHeight)); */
      await FlutterImageCompress.compressAndGetFile(filePath, destinationPath,
          minWidth: desiredSize, minHeight: desiredSize);
    } else {
      throw Exception('File mime type is incorrect');
    }

    return File(destinationPath);
  } */

  MediaInTransition updateState(String path, MediaInTransition mit) {
    state[path] = mit;
    state = Map.from(state);
    return mit;
  }

  void removeFromState(String path) {
    state.remove(path);
    state = Map.from(state);
  }

  Future<Media> uploadMedia(Media media) async {
    if (media.localPath == null) return media;

    var mediaInTransition = MediaInTransition(
      media,
      status: MediaTransitionStatus.processing,
    );

    updateState(media.localPath!, mediaInTransition);

    final fileToUpload =
        File('${permanentDirectory.absolute.path}/${media.localPath}');

    final encryptedFilePath =
        '${temporaryDirectory.absolute.path}/${basename(media.localPath!)}';

    final remoteUrl = await EncryptionManager.encryptFile(
      fileToUpload,
      encryptedFilePath,
      encryptionKey,
    ).then((encryptedFile) async {
      mediaInTransition = updateState(
        media.localPath!,
        mediaInTransition.copyWith(
          progress: mediaInTransition.progress + 30,
        ),
      );
      final uploadTask = transferTaskManager
          .uploadFile(encryptedFile, media.localPath!, contentType: media.mime);
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        if (taskSnapshot.state == TaskState.running) {
          mediaInTransition = updateState(
            media.localPath!,
            mediaInTransition.copyWith(
              progress: 30 +
                  (70 *
                      taskSnapshot.bytesTransferred /
                      taskSnapshot.totalBytes),
            ),
          );
        }
      });
      await uploadTask;
      await encryptedFile.delete();
      removeFromState(media.localPath!);
      return uploadTask.snapshot.ref.fullPath;
    });

    return media.copyWith(remoteUrl: remoteUrl);
  }

  Future<Media> downloadMedia(Media media) async {
    if (media.remoteUrl == null || state.containsKey(media.remoteUrl)) {
      return media;
    }
    var mediaInTransition = MediaInTransition(
      media,
      status: MediaTransitionStatus.downloading,
    );
    updateState(media.remoteUrl!, mediaInTransition);

    final filePath = '${temporaryDirectory.absolute.path}/${media.remoteUrl}';
    final encryptedFile = await File(filePath).create(recursive: true);

    final downloadTask =
        transferTaskManager.downloadFile(media.remoteUrl!, encryptedFile);

    downloadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.running) {
        mediaInTransition = updateState(
          media.remoteUrl!,
          mediaInTransition.copyWith(
            progress:
                70 * taskSnapshot.bytesTransferred / taskSnapshot.totalBytes,
          ),
        );
      }
    });
    await downloadTask;

    final finalPath = '${permanentDirectory.absolute.path}/${media.remoteUrl}';

    await EncryptionManager.decryptFile(
      encryptedFile,
      finalPath,
      encryptionKey,
    );
    mediaInTransition = updateState(
      media.remoteUrl!,
      mediaInTransition.copyWith(progress: mediaInTransition.progress + 30),
    );

    await encryptedFile.delete();
    updateState(
      media.remoteUrl!,
      mediaInTransition.copyWith(status: MediaTransitionStatus.done),
    );

    return media.copyWith(localPath: media.remoteUrl);
  }

  static String generateUniquePath(String tribuId, DateTime time, String path) {
    return '$tribuId/${time.millisecondsSinceEpoch}_${basename(path)}';
  }
}

class ComputeProcessMediaParams {
  ComputeProcessMediaParams(this.media, this.encryptionKey);
  final Media media;
  final String encryptionKey;
}

class ComputeProcessMediaResult {
  ComputeProcessMediaResult(
    this.width,
    this.height,
    this.thumbnailPath,
    this.blurHash,
    this.encryptedFilePath,
  );
  final double width;
  final double height;
  final String thumbnailPath;
  final String blurHash;
  final String encryptedFilePath;
}
