import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final temporaryDirectoryProvider = Provider<Directory>(
    (ref) => throw Exception('Provider was not initialized'),);

final permanentDirectoryProvider = Provider<Directory>(
    (ref) => throw Exception('Provider was not initialized'),);
