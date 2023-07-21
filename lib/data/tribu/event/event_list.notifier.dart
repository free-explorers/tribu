import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event_date_proposal/event_date_proposal.model.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool_list.notifier.dart';
import 'package:tribu/utils/encryption/encryption.dart';

class EventListNotifier extends StateNotifier<List<Event>> with Manager {
  factory EventListNotifier(String tribuId, String encryptionKey) {
    final stream = getCollection(tribuId, encryptionKey)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());
    final component = EventListNotifier._(tribuId, encryptionKey, stream);

    return component;
  }
  EventListNotifier._(this.tribuId, this.encryptionKey, this.eventListStream)
      : super([]) {
    onDisposeList.add(eventListStream.listen((event) => state = event).cancel);
  }
  final String tribuId;
  final String encryptionKey;
  final Stream<List<Event>> eventListStream;

  Future<DocumentReference<Event>> createEvent(Event event) async {
    return getCollection(tribuId, encryptionKey).add(event);
  }

  Future<void> updateEvent(Event event) async {
    await getCollection(tribuId, encryptionKey).doc(event.id).set(event);
  }

  Future<void> deleteEvent(Event event) async {
    //final batch = FirebaseFirestore.instance.batch()..delete();
    final callable =
        FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
      'deleteToolAssociatedData',
    );
    await getCollection(tribuId, encryptionKey).doc(event.id).delete();
    unawaited(
      callable.call<String>(
        {'tribuId': tribuId, 'toolIdList': event.toolIdList},
      ),
    );
  }

  DocumentReference<Event> getEventDoc(String eventId) {
    return getCollection(tribuId, encryptionKey).doc(eventId);
  }

  Future<void> addToolToEvent(Event event, Tool tool) async {
    final eventDoc = getCollection(tribuId, encryptionKey).doc(event.id);
    final toolDoc =
        ToolListNotifier.getCollection(tribuId, event.encryptionKey).doc();
    final batch = FirebaseFirestore.instance.batch()
      ..update(eventDoc, {
        'toolIdList': FieldValue.arrayUnion([toolDoc.id]),
      })
      ..set(toolDoc, tool);
    await batch.commit();
  }

  Future<void> deleteToolOfEvent(Event event, String toolId) async {
    final eventDoc = getCollection(tribuId, encryptionKey).doc(event.id);
    final toolDoc = ToolListNotifier.getCollection(tribuId, event.encryptionKey)
        .doc(toolId);
    final batch = FirebaseFirestore.instance.batch()
      ..update(eventDoc, {
        'toolIdList': FieldValue.arrayRemove([toolId]),
      })
      ..delete(toolDoc);
    await batch.commit();
  }

  Future<void> addDateProposalToEvent(
    Event event,
    EventDateProposal proposal,
  ) async {
    await getCollection(tribuId, encryptionKey).doc(event.id).update({
      'dateProposalList': FieldValue.arrayUnion([proposal]),
    });
  }

  Future<StayDateProposal?> pickStayDateProposal(
    BuildContext context,
    StayDateProposal? dateProposal,
  ) {
    return showDateRangePicker(
      context: context,
      initialDateRange: dateProposal != null
          ? DateTimeRange(
              start: dateProposal.startDate,
              end: dateProposal.endDate,
            )
          : null,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 10000)),
    ).then((dateRangeSelected) {
      if (dateRangeSelected != null) {
        if (dateProposal != null) {
          return dateProposal.copyWith(
            startDate: dateRangeSelected.start,
            endDate: dateRangeSelected.end,
          );
        }
        return StayDateProposal(
          startDate: dateRangeSelected.start,
          endDate: dateRangeSelected.end,
          attendeeVoteList: [],
          selected: false,
        );
      }
      return null;
    });
  }

  Future<void> updateEventDateProposalList(
    Event event,
    List<EventDateProposal> dateProposalList,
  ) async {
    await getCollection(tribuId, encryptionKey).doc(event.id).update({
      'dateProposalList': dateProposalList.map(
        (e) => EncryptionManager.encrypt(
          jsonEncode(e.toJson()),
          event.encryptionKey,
        ),
      ),
    });
  }

  Future<void> updateAttendeePresence({
    required String eventId,
    required String profileId,
    required bool isPresent,
  }) async {
    await getCollection(tribuId, encryptionKey)
        .doc(eventId)
        .update({'attendeesMap.$profileId': isPresent});
  }

  static CollectionReference<Event> getCollection(
    String tribuId,
    String encryptionKey,
  ) {
    return FirebaseFirestore.instance
        .collection('tribuList')
        .doc(tribuId)
        .collection('eventList')
        .withConverter<Event>(
      fromFirestore: (snapshot, _) {
        return Event.fromEncryptedJson(
          snapshot.data()!..putIfAbsent('id', () => snapshot.id),
          encryptionKey,
        );
      },
      toFirestore: (event, _) {
        return event.encrypt(encryptionKey)..remove('id');
      },
    );
  }
}
