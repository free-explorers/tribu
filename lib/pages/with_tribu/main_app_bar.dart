import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tribu/config.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/profile_list/profile_list.page.dart';
import 'package:tribu/widgets/confirm_dialog.dart';
import 'package:tribu/widgets/presence_list_viewer.widget.dart';

class MainAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const MainAppBar({required this.initializeDone, super.key});
  final AsyncValue<bool> initializeDone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.watch(tribuIdSelectedProvider)!;
    final tribuName =
        ref.watch(tribuSelectedProvider.select((tribu) => tribu?.name ?? ''));
    final pageListNotifier = ref.watch(pageListProvider.notifier);
    final scaffoldKey = ref.watch(mainScaffoldKeyProvider);
    final tribuListNotifier = ref.watch(tribuListProvider.notifier);

    return AppBar(
      leading: IconButton(
        onPressed: () => scaffoldKey.currentState!.openDrawer(),
        icon: Icon(MdiIcons.menu),
      ),
      title: Text(tribuName),
      actions: [
        if (initializeDone.value != null)
          const PresenceListViewer(
            match: '',
          ),
        IconButton(
          onPressed: () {
            Share.share(
              S.of(context).inviteLinkText(
                    tribuName,
                    AppConfig.buildInvitationLink(
                      tribuId,
                      ref.read(tribuEncryptionKeyProvider(tribuId))!,
                    ),
                  ),
            );
          },
          icon: Icon(MdiIcons.shareVariant),
        ),
        PopupMenuButton(
          icon: Icon(MdiIcons.dotsVertical),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<dynamic>(
              child: ListTile(
                leading: Icon(MdiIcons.accountMultiple),
                title: Text(S.of(context).memberListPageTitle),
              ),
              onTap: () {
                pageListNotifier.push(
                  const MaterialPage(
                    key: ValueKey('MemberListPage'),
                    child: ProfileListPage(),
                  ),
                );
              },
            ),
            PopupMenuItem<dynamic>(
              child: ListTile(
                leading: Icon(MdiIcons.exitToApp),
                title: Text(S.of(context).leaveTribuAction),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog<dynamic>(
                    context: context,
                    builder: (_) => ConfirmDialog(() async {
                      final tribuToRemove = ref.read(tribuSelectedProvider)!;
                      final tribuIdSelectedNotifier =
                          ref.read(tribuIdSelectedProvider.notifier);
                      await tribuIdSelectedNotifier.setLastActiveTribu();
                      await tribuListNotifier.leaveTribu(tribuToRemove);
                      ref.read(keepAliveTribuProvider(tribuId))!.close();
                    }),
                  );
                },
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
