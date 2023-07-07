import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension MyAsyncSnapshot<T> on AsyncSnapshot<T> {
  AsyncValue<T> get asyncValue {
    if (hasError) {
      return AsyncValue.error(error!, stackTrace!);
    } else if (hasData) {
      return AsyncValue.data(data as T);
    } else {
      return const AsyncValue.loading();
    }
  }
}
