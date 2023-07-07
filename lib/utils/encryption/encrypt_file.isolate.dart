import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;

class FileEncryptionParams {
  FileEncryptionParams(this.file, this.destinationPath, this.encryptionKey);
  final File file;
  final String destinationPath;
  final String encryptionKey;
}

Future<File> encryptFileIsolate(FileEncryptionParams params) async {
  final iv = encrypt.IV.fromSecureRandom(16);
  final encrypter = encrypt.Encrypter(
    encrypt.AES(encrypt.Key.fromBase64(params.encryptionKey)),
  );
  final encrypted =
      encrypter.encryptBytes(params.file.readAsBytesSync(), iv: iv);
  final b = BytesBuilder()
    ..add(encrypted.bytes)
    ..add(iv.bytes);
  print('outputFile');
  final outputFile = await File(params.destinationPath).create(recursive: true);
  outputFile.writeAsBytesSync(b.toBytes());
  return outputFile;
}
