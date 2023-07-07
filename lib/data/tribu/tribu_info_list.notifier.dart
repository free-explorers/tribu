import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/tribu.model.dart';
import 'package:tribu/data/tribu/tribu_info.model.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';
import 'package:tribu/storage.dart';

class TribuInfoMapNotifier extends StateNotifier<Map<String, TribuInfo>> {
  TribuInfoMapNotifier(this.tribuListNotifier) : super({}) {
    initialized = initialize();
  }
  final TribuListNotifier tribuListNotifier;
  late Future<bool> initialized;

  Future<bool> initialize() async {
    var tribuList = tribuListNotifier.value;
    for (final tribu in tribuList) {
      await initializeTribuInfo(tribu);
    }
    tribuListNotifier.stream.listen((updatedTribuList) {
      final oldTribuList = tribuList;
      final newTribuList = <Tribu>[];
      for (final tribu in updatedTribuList) {
        if (oldTribuList.contains(tribu)) {
          oldTribuList.remove(tribu);
        } else {
          newTribuList.add(tribu);
        }
      }
      newTribuList.forEach(initializeTribuInfo);
      oldTribuList.forEach(removeTribuInfo);
      tribuList = updatedTribuList;
    });
    return true;
  }

  TribuInfo? get(String tribuId) {
    return state[tribuId];
  }

  List<TribuInfo> getList() {
    return state.values.toList();
  }

  Future<void> initializeTribuInfo(Tribu tribu) async {
    final storage = await Storage.getSharedPreferences();
    final tribuInfoJson = storage.getString('${tribu.id}TribuInfo');
    if (tribuInfoJson != null) {
      await updateTribuInfo(
        TribuInfo.fromJson(json.decode(tribuInfoJson) as Json),
      );
    } else {
      await updateTribuInfo(
        TribuInfo(
          tribuId: tribu.id!,
          lastRead: DateTime.now(),
          unreadMessage: 0,
        ),
      );
    }
  }

  Future<void> updateTribuInfo(TribuInfo tribuInfo) async {
    final storage = await Storage.getSharedPreferences();
    await storage.setString(
      '${tribuInfo.tribuId}TribuInfo',
      json.encode(tribuInfo.toJson()),
    );
    state[tribuInfo.tribuId] = tribuInfo;
    state = state;
  }

  Future<void> removeTribuInfo(Tribu tribu) async {
    final storage = await Storage.getSharedPreferences();
    await storage.remove('${tribu.id}TribuInfo');
    state.remove(tribu.id);
    state = state;
  }
}
