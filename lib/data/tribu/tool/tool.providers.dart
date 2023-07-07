import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';

final toolListProvider =
    StateNotifierProvider.family<ToolListNotifier, List<Tool>, String>(
        (ref, eventId) {
  final tribuId = ref.watch(tribuIdSelectedProvider)!;

  final event = ref
      .read(eventListProvider(tribuId))
      .firstWhere((element) => element.id == eventId);

  ref.listen<Event?>(
      eventListProvider(tribuId).select(
        (eventList) =>
            eventList.firstWhereOrNull((event) => event.id == eventId),
      ), (Event? previous, Event? next) {
    if (previous != null && next != null) {
      if (previous.toolIdList != next.toolIdList) {
        ref.invalidateSelf();
      }
    }
  });

  final notifier =
      ToolListNotifier(tribuId, event.toolIdList, event.encryptionKey);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final toolPageListProvider = StateNotifierProvider.family
    .autoDispose<PageListNotifier, List<MaterialPage<dynamic>>, String>(
  (ref, tribuId) => PageListNotifier(),
);
