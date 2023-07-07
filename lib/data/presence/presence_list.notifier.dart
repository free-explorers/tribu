import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/manager.abstract.dart';
import 'package:tribu/data/peer_network/decrypted_message.model.dart';
import 'package:tribu/data/peer_network/message_content.model.dart';
import 'package:tribu/data/peer_network/webrtc/connection_status.model.dart';
import 'package:tribu/data/peer_network/webrtc/webrtc.manager.dart';
import 'package:tribu/data/presence/presence.model.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';

class PresenceListNotifier extends StateNotifier<List<Presence>>
    with Manager, WidgetsBindingObserver {
  factory PresenceListNotifier(
    String tribuId,
    WebrtcManager webrtcManager,
    TribuListNotifier tribuListNotifier,
    TribuIdSelectedNotifier tribuIdSelectedNotifier,
  ) {
    return PresenceListNotifier._(
      tribuId,
      webrtcManager,
      tribuListNotifier,
      tribuIdSelectedNotifier,
    );
  }
  PresenceListNotifier._(
    this.tribuId,
    this.webrtcManager,
    this.tribuListNotifier,
    this.tribuIdSelectedNotifier,
  ) : super(<Presence>[]) {
    WidgetsBinding.instance.addObserver(this);
    onDisposeList
      ..add(() => WidgetsBinding.instance.removeObserver(this))
      ..add(
        tribuIdSelectedNotifier.addListener((selectedTribuId) {
          updateHere();
        }),
      );
    webrtcManager.eventStream
        .where(
          (message) =>
              message.tribuId == tribuId &&
              message.content is PresenceMessageContent,
        )
        .map(
          (message) => message.content.payload,
        )
        .listen((presence) {
      final index =
          state.indexWhere((element) => element.userId == presence.userId);
      if (index > -1) {
        state[index] = presence;
      } else {
        state.add(presence);
      }
      state = [...state];
    });

    webrtcManager.connectionStatusStream
        .where(
      (ConnectionStatus status) => memberIdList.contains(status.userId),
    )
        .listen((ConnectionStatus status) {
      if (status.state == RTCDataChannelState.RTCDataChannelOpen) {
        onMyPresenceChange();
      } else if ([
        RTCDataChannelState.RTCDataChannelClosing,
        RTCDataChannelState.RTCDataChannelClosed
      ].contains(status.state)) {
        state =
            state.where((element) => element.userId != status.userId).toList();
      }
    });

    FocusManager.instance.addListener(onFocusChange);
    onDisposeList
        .add(() => FocusManager.instance.removeListener(onFocusChange));
  }
  final String tribuId;
  final WebrtcManager webrtcManager;
  final TribuListNotifier tribuListNotifier;
  final TribuIdSelectedNotifier tribuIdSelectedNotifier;
  List<String> get memberIdList {
    final tribu =
        tribuListNotifier.value.firstWhere((tribu) => tribu.id == tribuId);

    return tribu.authorizedMemberList
        .where((element) => element != FirebaseAuth.instance.currentUser!.uid)
        .toList();
  }

  Presence myPresence = Presence(
    userId: FirebaseAuth.instance.currentUser!.uid,
    route: 'chat',
    here: true,
  );
  List<Presence> get value => state;

  void setRoute(String route) {
    if (route == myPresence.route) return;
    myPresence = myPresence.copyWith(route: route);
    onMyPresenceChange();
  }

  void addRoute(String route) {
    myPresence = myPresence.copyWith(route: '${myPresence.route}/$route');
    onMyPresenceChange();
  }

  void setFocus(String? focus) {
    myPresence = myPresence.copyWith(focus: focus);
    onMyPresenceChange();
  }

  void onMyPresenceChange() {
    for (final memberId in memberIdList) {
      webrtcManager.send(
        DecryptedMessage(
          forUserId: memberId,
          fromUserId: FirebaseAuth.instance.currentUser!.uid,
          tribuId: tribuId,
          content: MessageContent.presence(payload: myPresence),
        ),
      );
    }
  }

  void onFocusChange() {}

  void updateHere() {
    final isAppFocused =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    final isHere = isAppFocused && tribuIdSelectedNotifier.value == tribuId;
    myPresence = myPresence.copyWith(here: isHere);
    onMyPresenceChange();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    updateHere();
  }
}

class PresenceObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('didPop');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print(
      'didPush $route',
    );
  }
}
