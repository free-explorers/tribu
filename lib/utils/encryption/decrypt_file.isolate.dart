import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;

class FileDecryptionParams {
  FileDecryptionParams(this.file, this.destinationPath, this.encryptionKey);
  final File file;
  final String destinationPath;
  final String encryptionKey;
}

Future<File> decryptFileIsolate(FileDecryptionParams params) async {
  final bytesWithIV = params.file.readAsBytesSync();
  final bytesToDecode = bytesWithIV.sublist(0, bytesWithIV.length - 16);
  // ignore: non_constant_identifier_names
  final IVBytes =
      bytesWithIV.sublist(bytesWithIV.length - 16, bytesWithIV.length);
  final iv = encrypt.IV(IVBytes);
  final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromBase64(params.encryptionKey)),);
  final encrypted = encrypt.Encrypted(bytesToDecode);
  final outputFile = await File(params.destinationPath).create(recursive: true);
  outputFile.writeAsBytesSync(
      Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv)),);
  return outputFile;
}
