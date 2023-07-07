import 'package:flutter/foundation.dart';

mixin Manager {
  List<VoidCallback> onDisposeList = [];
  bool disposed = false;
  void dispose() {
    debugPrint('Dispose Manager $this');
    for (final func in onDisposeList) {
      func.call();
    }
    disposed = true;
  }
}
