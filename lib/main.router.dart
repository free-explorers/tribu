import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/enforcedUpdate.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/pages/enforced_update.page.dart';
import 'package:tribu/pages/join_tribu.page.dart';
import 'package:tribu/pages/with_tribu/with_tribu.page.dart';
import 'package:tribu/pages/without_tribu.page.dart';
import 'package:tribu/theme.dart';

class TribuRouteInformationParser
    extends RouteInformationParser<TribuRoutePath> {
  @override
  Future<TribuRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    if (routeInformation.location != null) {
      const pattern = 'https://get.trbu.app/';
      if (routeInformation.location!.contains(pattern)) {
        final regex = RegExp('link=(.*)&apn');

        final url = regex
            .firstMatch(Uri.decodeFull(routeInformation.location!))
            ?.group(1);
        if (url != null && url.isNotEmpty) {
          return JoinTribuPath(url);
        }
      }
    }
    return NoTribuPath();
  }

  @override
  RouteInformation restoreRouteInformation(TribuRoutePath configuration) {
    if (configuration is NoTribuPath) {
      return const RouteInformation(location: '/home');
    } else {
      return const RouteInformation(location: '/settings');
    }
  }
}

class MainRouterDelegate extends RouterDelegate<TribuRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TribuRoutePath> {
  MainRouterDelegate(this.pageListNotifier);
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final PageListNotifier pageListNotifier;

  @override
  TribuRoutePath get currentConfiguration {
    return NoTribuPath();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tribuIdSelected = ref.watch(tribuIdSelectedProvider);
        final pageList = ref.watch(pageListProvider);
        final unlocked = ref.watch(unlockBottomInsetResize);
        final enforcedUpdateRequired =
            ref.watch(enforcedUpdateRequiredProvider);

        return Scaffold(
          resizeToAvoidBottomInset: unlocked,
          body: Navigator(
            key: navigatorKey,
            pages: [
              if (tribuIdSelected == null)
                const MaterialPage(
                  key: ValueKey('CreateOrJoinTribuPage'),
                  child: WithoutTribuPage(),
                ),
              if (tribuIdSelected != null)
                const MaterialPage(
                  key: ValueKey('WithTribuPage'),
                  child: WithTribu(),
                ),
              ...pageList,
              if (enforcedUpdateRequired)
                const MaterialPage(
                  key: ValueKey('enforcedUpdate'),
                  child: EnforcedUpdatePage(),
                ),
            ],
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }
              pageListNotifier.pop();
              notifyListeners();
              return true;
            },
          ),
        );
      },
    );
  }

  @override
  Future<void> setNewRoutePath(TribuRoutePath configuration) async {
    if (configuration is JoinTribuPath) {
      pageListNotifier.push(
        MaterialPage(
          key: const ValueKey('JoinTribuPage'),
          child: JoinTribuPage(link: Uri.parse(configuration.url)),
        ),
      );
    }
  }
}

// Routes
abstract class TribuRoutePath {}

class NoTribuPath extends TribuRoutePath {}

class JoinTribuPath extends TribuRoutePath {
  JoinTribuPath(this.url);
  final String url;
}

Future<T?> showTribuBottomModal<T>(
  BuildContext context,
  WidgetRef ref,
  Widget Function(BuildContext) builder, {
  String? title,
}) {
  ref.read(unlockBottomInsetResize.notifier).state = true;
  return showModalBottomSheet<T>(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      final primaryTheme = ref.read(primaryThemeProvider);
      return Theme(
        data: primaryTheme,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: primaryTheme.colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
                Builder(builder: builder)
              ],
            ),
          ),
        ),
      );
    },
  )..whenComplete(
      () => ref.read(unlockBottomInsetResize.notifier).state = false,
    );
}
