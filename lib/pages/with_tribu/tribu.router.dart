import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/presence/presence_list.notifier.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/pages/with_tribu/chat/chat.dart';
import 'package:tribu/pages/with_tribu/event/event_list.page.dart';
import 'package:tribu/pages/with_tribu/main_app_bar.dart';

class TribuRouterDelegate extends RouterDelegate<dynamic>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<dynamic> {
  TribuRouterDelegate({required this.tabController, required this.mainAppBar});
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final TabController tabController;
  final MainAppBar mainAppBar;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tribuId = ref.read(tribuIdSelectedProvider);
        final toolPageList = ref.watch(toolPageListProvider(tribuId!));
        final toolPageListNotifier =
            ref.watch(toolPageListProvider(tribuId).notifier);
        final toolPageOpened = toolPageList.isNotEmpty;
        return TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Scaffold(
              key: PageStorageKey('${tribuId}Chat'),
              appBar: toolPageOpened ? mainAppBar : null,
              body: const ChatPage(),
            ),
            Navigator(
              pages: [
                MaterialPage(
                  key: const ValueKey('EventListPage'),
                  child: Scaffold(
                    appBar: toolPageOpened ? mainAppBar : null,
                    body: const EventListPage(),
                  ),
                ),
                ...toolPageList
              ],
              onPopPage: (route, result) {
                print('onPopPage');
                if (!route.didPop(result)) {
                  return false;
                }
                toolPageListNotifier.pop();
                notifyListeners();

                return true;
              },
              observers: [PresenceObserver()],
            )
          ],
        );
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) {
    // TODO: implement setNewRoutePath
    throw UnimplementedError();
  }
}

class WithTribuBackButtonDispatcher extends ChildBackButtonDispatcher {
  WithTribuBackButtonDispatcher({
    required this.tabController,
    required this.rootDispatcher,
    required this.toolPageListNotifier,
    required this.childDelegate,
    required this.parentDelegate,
  }) : super(rootDispatcher);
  final TabController tabController;
  final BackButtonDispatcher rootDispatcher;
  final PageListNotifier toolPageListNotifier;
  final RouterDelegate<dynamic> childDelegate;
  final RouterDelegate<dynamic> parentDelegate;

  @override
  Future<bool> notifiedByParent(Future<bool> defaultValue) async {
    final childDelegatePop = await childDelegate.popRoute();
    if (childDelegatePop) return childDelegatePop;
    final parentDelegatePop = await parentDelegate.popRoute();
    if (parentDelegatePop) return parentDelegatePop;

    if (toolPageListNotifier.list.isNotEmpty) {
      toolPageListNotifier.pop();
      return Future.value(true);
    }
    if (tabController.index != 0) {
      tabController.index = 0;
      return Future.value(true);
    }
    return Future.value(false);
  }
}
