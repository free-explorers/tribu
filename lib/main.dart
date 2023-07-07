import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/data/storage.providers.dart';
import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/data/tribu/tribu_info_list.notifier.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';
import 'package:tribu/data/user/user.manager.dart';
import 'package:tribu/data/user/user.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/main.router.dart';
import 'package:tribu/notification.dart';
import 'package:tribu/pages/join_tribu.page.dart';
import 'package:tribu/storage.dart';
import 'package:tribu/theme.dart';
import 'package:tribu/utils/firebase.service.dart';

const useEmulator = false;

class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<dynamic> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
      {
        "provider": "${provider.name ?? provider.runtimeType}",
        "newValue": "$newValue"
      }''');
  }
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

      await FirebaseService.instance.init();
      // Pass all uncaught errors from the framework to Crashlytics.
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]);
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      FirebaseMessaging.onBackgroundMessage(
        NotificationTool.firebaseMessagingBackgroundHandler,
      );
      final overrideList = await initializeApp();

      FlutterNativeSplash.remove();

      runApp(
        ProviderScope(
          overrides: overrideList,
          //observers: [Logger()],
          child: const TribuApp(),
        ),
      );
    },
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack),
  );
}

Future<List<Override>> initializeApp() async {
  final overrideList = <Override>[];
  final secureStorage = await Storage.getSecureStorage();
  await secureStorage.write(
    key: 'locale',
    value: Intl.canonicalizedLocale(Platform.localeName),
  );
  overrideList.add(secureStorageProvider.overrideWithValue(secureStorage));
  final deviceInfo = DeviceInfoPlugin();

  Future<bool> getPhysicalDevice() async {
    var isPhysicalDevice = false;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
    }
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      isPhysicalDevice = iosInfo.isPhysicalDevice;
    }
    return isPhysicalDevice;
  }

  late PackageInfo packageInfo;
  final res = await Future.wait<dynamic>([
    Hive.initFlutter(),
    PackageInfo.fromPlatform().then((value) => packageInfo = value),
    getPhysicalDevice(),
    //Initialize first call as it take some time
    Storage.getSharedPreferences(),
    path.getTemporaryDirectory().then(
          (value) => overrideList
              .add(temporaryDirectoryProvider.overrideWithValue(value)),
        ),
    () async {
      Directory? finalDir;
      if (Platform.isAndroid) {
        finalDir = await path.getExternalStorageDirectory();
      }
      return finalDir ??= await path.getApplicationDocumentsDirectory();
    }()
        .then(
      (value) =>
          overrideList.add(permanentDirectoryProvider.overrideWithValue(value)),
    )
  ]);

  Hive
    ..registerAdapter(MessageAdapter())
    ..registerAdapter(MediaAdapter());

  final userNotifier = UserNotifier();
  overrideList
    ..add(userProvider.overrideWith((ref) => userNotifier))
    ..add(packageInfoProvider.overrideWithValue(packageInfo));

  final firebaseRes = await Future.wait([
    userNotifier.initialized,
    FirebaseDynamicLinks.instance.getInitialLink(),
  ]);

  final hiveBox = await Storage.getHiveBox<String>('appBox');
  overrideList.add(boxProvider.overrideWithValue(hiveBox));

  final tribuIdLoadedMap = <String, bool>{};
  overrideList
      .add(tribuIdLoadedMapProvider.overrideWithValue(tribuIdLoadedMap));

  final tribuListNotifier = TribuListNotifier(secureStorage);
  overrideList.add(tribuListProvider.overrideWith((ref) => tribuListNotifier));
  final tribuListInfoNotifier = TribuInfoMapNotifier(tribuListNotifier);
  overrideList
      .add(tribuInfoMapProvider.overrideWith((ref) => tribuListInfoNotifier));
  final tribuIdSelectedNotifier =
      TribuIdSelectedNotifier(tribuListInfoNotifier, hiveBox);
  overrideList.add(
    tribuIdSelectedProvider.overrideWith((ref) => tribuIdSelectedNotifier),
  );

  await tribuListNotifier.initialized;
  if (tribuIdSelectedNotifier.value != null) {
    if (tribuListNotifier.value.indexWhere(
          (element) => element.id == tribuIdSelectedNotifier.value,
        ) ==
        -1) {
      await tribuIdSelectedNotifier.setTribuId(null);
    }
  }
  if (tribuIdSelectedNotifier.value == null) {
    if (tribuListNotifier.value.isNotEmpty) {
      await tribuIdSelectedNotifier
          .setTribuId(tribuListNotifier.value.elementAt(0).id);
    }
  }
  overrideList.add(tribuListProvider.overrideWith((ref) => tribuListNotifier));
  final initialLink = firebaseRes.elementAt(1) as PendingDynamicLinkData?;

  final pageListNotifier = PageListNotifier();

  void pushJoinPage(PendingDynamicLinkData dynamicLinkData) {
    pageListNotifier.push(
      MaterialPage(
        key: const ValueKey('JoinTribuPage'),
        child: JoinTribuPage(link: dynamicLinkData.link),
      ),
    );
  }

  if (initialLink != null) {
    pushJoinPage(initialLink);
  }

  FirebaseDynamicLinks.instance.onLink.listen(pushJoinPage).onError((error) {
    // Handle errors
  });
  overrideList.add(pageListProvider.overrideWith((ref) => pageListNotifier));

  final isPhysicalDevice = res.elementAt(2) as bool;

  if (useEmulator) {
    final host = isPhysicalDevice ? '192.168.1.86' : 'localhost';
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8082);
  }

  overrideList
      .add(firestoreProvider.overrideWithValue(FirebaseFirestore.instance));

  final notificationPlugin = await NotificationTool.initiatePlugin(
    onSelectNotification: (notificationResponse) {
      if (notificationResponse.payload != null) {
        tribuIdSelectedNotifier.setTribuId(notificationResponse.payload);
      }
    },
  );
  try {
    final notificationAppLaunchDetails =
        await notificationPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      await tribuIdSelectedNotifier.setTribuId(
        notificationAppLaunchDetails!.notificationResponse?.payload,
      );
    }
  } catch (exception, stack) {
    await FirebaseCrashlytics.instance.recordError(exception, stack);
  }

  overrideList
      .add(notificationPluginProvider.overrideWithValue(notificationPlugin));
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final tribuId = message.data['tribuId'];
    if (!tribuIdLoadedMap.containsKey(tribuId) ||
        tribuIdLoadedMap[tribuId] == false) {
      await NotificationTool.handleNotification(notificationPlugin, message);
    }
  });

  return overrideList;
}

class TribuApp extends HookConsumerWidget {
  const TribuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightTheme = ref.watch(lightThemeProvider);
    final defaultDarkTheme = ThemeData.dark();
    final pageListNotifier = ref.watch(pageListProvider.notifier);

    final routerDelegate =
        useMemoized(() => MainRouterDelegate(pageListNotifier));
    final routeInformationParser = useMemoized(TribuRouteInformationParser.new);

    return AdaptiveTheme(
      light: lightTheme,
      dark: defaultDarkTheme.copyWith(
        colorScheme: defaultDarkTheme.colorScheme
            .copyWith(primary: Colors.red, secondary: Colors.green),
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp.router(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: theme,
        darkTheme: theme,
        routerDelegate: routerDelegate,
        routeInformationParser: routeInformationParser,
      ),
    );
  }
}
