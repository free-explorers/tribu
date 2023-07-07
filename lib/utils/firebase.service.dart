import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

// ignore: always_use_package_imports
import '../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static final instance = FirebaseService._();
  Completer<dynamic>? _completer;

  Future<void> init() async {
    var completer = _completer;
    if (completer == null) {
      completer = Completer();
      _completer = completer;
      await _initInternal();
    }
    return completer.future;
  }

  Future<void> _initInternal() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _completer!.complete();
  }
}
