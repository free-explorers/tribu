import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/message/message.providers.dart';
import 'package:tribu/data/tribu/tribu.model.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/create_tribu.page.dart';
import 'package:tribu/pages/join_tribu.page.dart';
import 'package:tribu/theme.dart';
import 'package:tribu/widgets/counter_badge.widget.dart';

class MainDrawer extends HookConsumerWidget {
  const MainDrawer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryTheme = ref.watch(primaryThemeProvider);
    final pageListNotifier = ref.watch(pageListProvider.notifier);

    return Theme(
      data: primaryTheme,
      child: Drawer(
        child: Column(
          children: [
            AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Image.asset('assets/logo.png', width: 32),
                  Text(
                    'Tribu',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                ],
              ),
              actions: [
                PopupMenuButton(
                  icon: Icon(MdiIcons.plus),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<dynamic>(
                      child: Text(S.of(context).createATribuAction),
                      onTap: () {
                        Navigator.of(context).pop();
                        pageListNotifier.push(
                          const MaterialPage(
                            key: ValueKey('CreateTribuPage'),
                            child: CreateTribuPage(),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem<dynamic>(
                      child: Text(S.of(context).joinATribuAction),
                      onTap: () {
                        Navigator.of(context).pop();
                        pageListNotifier.push(
                          const MaterialPage(
                            key: ValueKey('JoinTribuPage'),
                            child: JoinTribuPage(),
                          ),
                        );
                      },
                    )
                  ],
                )
              ],
            ),
            const Divider(
              height: 1,
            ),
            const TribuListSelector()
          ],
        ),
      ),
    );
  }
}

class TribuListSelector extends HookConsumerWidget {
  const TribuListSelector({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuList = ref.watch(tribuListProvider);
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: tribuList.length,
        itemBuilder: (context, index) {
          return TribuTile(tribuList[index]);
        },
      ),
    );
  }
}

class TribuTile extends HookConsumerWidget {
  const TribuTile(this.tribu, {super.key});
  final Tribu tribu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTribu = ref.watch(tribuSelectedProvider);

    final unreadCounter = ref.watch(unreadMessageCounterOfTribu(tribu.id!));
    return ListTile(
      selected: currentTribu == tribu,
      selectedTileColor: Colors.white10,
      title: Text(
        tribu.name,
        style: TextStyle(
          color: currentTribu == tribu
              ? Theme.of(context).colorScheme.secondary
              : null,
        ),
      ),
      onTap: () {
        ref.read(tribuIdSelectedProvider.notifier).setTribuId(tribu.id);
        Navigator.pop(context);
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unreadCounter > 0) CounterBadge(unreadCounter.toString()),
        ],
      ),
    );
  }
}
