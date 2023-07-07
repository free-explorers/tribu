import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/enforcedUpdate.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class EnforcedUpdatePage extends HookConsumerWidget {
  const EnforcedUpdatePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryTheme = ref.watch(primaryThemeProvider);
    final currentVersion =
        ref.watch(packageInfoProvider.select((infos) => infos.version));
    final enforcedVersionAsync = ref.watch(enforcedUpdateVersionProvider);
    final responsivePadding = MediaQuery.of(context).size.width / 10;

    Future<void> updateAppAction() async {
      if (Platform.isAndroid) {
        final updateInfos = await InAppUpdate.checkForUpdate();
        if (updateInfos.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else {
          await launchUrl(
            Uri.parse(
              'https://play.google.com/store/apps/details?id=com.tribu.default',
            ),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        await launchUrl(
          Uri.parse(
            'https://apps.apple.com/us/app/tribu-lets-live-together/id1620848629?platform=iphone',
          ),
          mode: LaunchMode.externalApplication,
        );
      }
    }

    return Theme(
      data: primaryTheme,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(responsivePadding),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MdiIcons.cellphoneArrowDown,
                      size: MediaQuery.of(context).size.width / 3,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    Text(
                      S.of(context).upgradingAppRequired,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentVersion,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Icon(MdiIcons.arrowRight),
                        const SizedBox(
                          width: 16,
                        ),
                        Text(
                          enforcedVersionAsync.valueOrNull ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: updateAppAction,
                      child: Text(S.of(context).updateTribuAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
