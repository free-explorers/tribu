import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/data_model.manager.dart';
import 'package:tribu/data/presence/presence.provider.dart';
import 'package:tribu/data/tribu/tool/tool.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/main_app_bar.dart';
import 'package:tribu/pages/with_tribu/main_drawer.dart';
import 'package:tribu/pages/with_tribu/tribu.router.dart';
import 'package:tribu/pages/with_tribu/upgrade_tribu_model.page.dart';
import 'package:tribu/theme.dart';

class WithTribu extends HookConsumerWidget {
  const WithTribu({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.watch(tribuIdSelectedProvider);

    // When deleting the last tribu
    if (tribuId == null) {
      return Container();
    }

    final tribu = ref.watch(
      tribuSelectedProvider,
    );

    final upgradeNeeded = tribu?.modelVersion != null &&
        tribu!.modelVersion < currentModelVersion;

    final initializeDone = ref.watch(initializeTribuProvider(tribuId));

    final tabController = useTabController(initialLength: 2);
    ref.listen<String?>(tribuIdSelectedProvider,
        (String? previous, String? next) {
      tabController.index = 0;
    });

    final tabIndexSelected = ref.watch(tabIndexSelectedProvider);

    ref.listen(
      tabIndexSelectedProvider,
      (int? previous, int next) {
        if (next != tabController.index) {
          tabController.index = next;
        }
      },
    );
    final scaffoldKey = ref.watch(mainScaffoldKeyProvider);
    final toolPageList = ref.watch(toolPageListProvider(tribuId));
    final toolPageListNotifier =
        ref.watch(toolPageListProvider(tribuId).notifier);

    final toolPageOpened = toolPageList.isNotEmpty;
    final primaryTheme = ref.read(primaryThemeProvider);

    final mainAppBar = MainAppBar(initializeDone: initializeDone);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: upgradeNeeded
          ? Scaffold(
              drawer: const MainDrawer(),
              appBar: AppBar(
                title: Text(tribu.name),
                elevation: 0,
              ),
              body: UpgradeTribuModelPage(
                tribuId: tribuId,
                modelVersion: tribu.modelVersion,
              ),
            )
          : Scaffold(
              key: scaffoldKey,
              appBar: toolPageOpened ? null : mainAppBar,
              drawer: const MainDrawer(),
              drawerEnableOpenDragGesture:
                  !(toolPageOpened && tabIndexSelected == 1),
              resizeToAvoidBottomInset: true,
              body: initializeDone.whenOrNull(
                data: (_) {
                  final delegate = useMemoized(
                    () => TribuRouterDelegate(
                      tabController: tabController,
                      mainAppBar: mainAppBar,
                    ),
                  );
                  final rootBackButtonDispatcher =
                      Router.of(context).backButtonDispatcher!;
                  final backButtonDispatcher = WithTribuBackButtonDispatcher(
                    rootDispatcher: rootBackButtonDispatcher,
                    tabController: tabController,
                    toolPageListNotifier: toolPageListNotifier,
                    childDelegate: delegate,
                    parentDelegate: Router.of(context).routerDelegate,
                  )..takePriority();
                  final myPresence =
                      ref.read(presenceListProvider(tribuId).notifier);
                  tabController.addListener(() {
                    ref.read(tabIndexSelectedProvider.state).state =
                        tabController.index;
                    if (tabController.index == 0) {
                      myPresence.setRoute('chat');
                    } else {
                      myPresence.setRoute('tool');
                    }
                  });
                  return Router(
                    routerDelegate: delegate,
                    backButtonDispatcher: backButtonDispatcher,
                  );
                },
              ),
              /* bottomNavigationBar: Theme(
          data: primaryTheme,
          child: SizedBox(
            height: 56,
            child: BottomAppBar(
              padding: EdgeInsets.zero,
              color: Theme.of(context).colorScheme.primary,
              elevation: 0,
              child: TabBar(
                dividerColor: Colors.transparent,
                automaticIndicatorColorAdjustment: false,
                indicator: const BoxDecoration(),
                controller: tabController,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                onTap: (index) {
                  if (index == 1 &&
                      !tabController.indexIsChanging &&
                      toolPageList.isNotEmpty) {
                    toolPageListNotifier.pop();
                  }
                },
                tabs: const [
                  Tab(height: 56, icon: Icon(MdiIcons.forum)),
                  Tab(
                    height: 56,
                    icon: Icon(MdiIcons.viewAgenda),
                  )
                ],
              ),
            ),
          ),
        ), */
              bottomNavigationBar: Theme(
                data: primaryTheme,
                child: NavigationBar(
                  elevation: 0,
                  selectedIndex: tabController.index,
                  destinations: [
                    NavigationDestination(
                      icon: Icon(MdiIcons.forum),
                      label: S.of(context).ChatPageTitle,
                    ),
                    NavigationDestination(
                      icon: Icon(MdiIcons.viewAgenda),
                      label: S.of(context).eventsPageTitle,
                    )
                  ],
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  onDestinationSelected: (index) {
                    if (index == 1 &&
                        index == tabController.index &&
                        toolPageList.isNotEmpty) {
                      toolPageListNotifier.pop();
                    }
                    tabController.animateTo(index);
                  },
                ),
              ),
            ),
    );
  }
}
