import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';

final eventListProvider =
    StateNotifierProvider.family<EventListNotifier, List<Event>, String>(
        (ref, tribuId) {
  final encryptionKey = ref.watch(tribuEncryptionKeyProvider(tribuId))!;
  final notifier = EventListNotifier(tribuId, encryptionKey);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final eventProvider =
    Provider.family.autoDispose<Event?, String>((ref, eventId) {
  final tribuId = ref.read(tribuIdSelectedProvider)!;
  final eventList = ref.watch(eventListProvider(tribuId));
  return eventList.firstWhereOrNull((event) => event.id == eventId);
});

final eventPageListProvider = StateNotifierProvider.family
    .autoDispose<PageListNotifier, List<MaterialPage<dynamic>>, String>(
  (ref, tribuId) => PageListNotifier(),
);

final orderedEventListProvider =
    Provider.family<List<Event>, String>((ref, tribuId) {
  final eventList = ref.watch(eventListProvider(tribuId));

  final sortedList = eventList.sorted((eventA, eventB) {
    final firstDate = getDateFromEvent(eventA);
    final secondDate = getDateFromEvent(eventB);
    return secondDate.compareTo(firstDate);
  });
  return sortedList;
});

final currentEventOpenedIdProvider =
    StateProvider.family<String?, String>((ref, tribuId) => null);

DateTime getDateFromEvent(Event event) {
  return event.map(
    permanent: (event) => DateTime.fromMillisecondsSinceEpoch(
      (DateTime.now().millisecondsSinceEpoch * 2) -
          event.createdAt.millisecondsSinceEpoch,
    ),
    punctual: (event) {
      return event.createdAt;
    },
    stay: (event) {
      return event.createdAt;
    },
  );
}
