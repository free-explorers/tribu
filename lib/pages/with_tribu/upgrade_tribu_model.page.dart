import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/data_model.manager.dart';
import 'package:tribu/theme.dart';

class UpgradeTribuModelPage extends HookConsumerWidget {
  const UpgradeTribuModelPage({
    required this.tribuId,
    required this.modelVersion,
    super.key,
  });
  final String tribuId;
  final int modelVersion;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryTheme = ref.watch(primaryThemeProvider);
    final responsivePadding = MediaQuery.of(context).size.width / 10;
    useEffect(() {
      final cb = migrationFrom[modelVersion];
      if (cb != null) {
        cb(tribuId);
      }
      return null;
    });
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          MdiIcons.packageUp,
                          size: 64,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 24),
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    Text(
                      'Upgrading your Tribu to the latest version',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
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
