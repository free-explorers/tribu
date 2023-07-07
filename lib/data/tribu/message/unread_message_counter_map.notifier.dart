import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';

class UnreadMessageCounterMapNotifier extends StateNotifier<Map<String, int>>
    with Manager, WidgetsBindingObserver {
  factory UnreadMessageCounterMapNotifier({
    required TribuListNotifier tribuListNotifier,
    required SharedPreferences prefInstance,
  }) {
    final manager =
        UnreadMessageCounterMapNotifier._(tribuListNotifier, prefInstance);

    return manager;
  }
  UnreadMessageCounterMapNotifier._(this.tribuListNotifier, this.prefInstance)
      : super({}) {
    WidgetsBinding.instance.addObserver(this);
    onDisposeList.add(() => WidgetsBinding.instance.removeObserver(this));
    initialized = initialize();
  }
  late Future<bool> initialized;
  final TribuListNotifier tribuListNotifier;
  final SharedPreferences prefInstance;

  Future<bool> initialize() async {
    await tribuListNotifier.initialized;
    refreshCounter();
    tribuListNotifier.addListener((state) => refreshCounter());
    return true;
  }

  void refreshCounter() {
    for (final tribu in tribuListNotifier.value) {
      state[tribu.id!] = prefInstance.getInt('${tribu.id}UnReadCounter') ?? 0;
    }
    state = {...state};
  }

  Future<void> updateCounter(String tribuId, int number) async {
    await prefInstance.setInt('${tribuId}UnReadCounter', number);
    state[tribuId] = number;
    state = {...state};
  }

  Future<void> clearCounter(String tribuId) async {
    return updateCounter(tribuId, 0);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    await initialized;
    if (state == AppLifecycleState.resumed) {
      refreshCounter();
    }
  }
}
