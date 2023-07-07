import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/create_tribu.page.dart';
import 'package:tribu/pages/join_tribu.page.dart';
import 'package:tribu/theme.dart';

class WithoutTribuPage extends HookConsumerWidget {
  const WithoutTribuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryTheme = ref.watch(primaryThemeProvider);
    final pageListNotifier = ref.watch(pageListProvider.notifier);

    return Theme(
      data: primaryTheme,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(48),
                child: Image.asset('assets/logo_large.png'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(0, 48)),
                ),
                child: Text(S.of(context).createATribuAction.toUpperCase()),
                onPressed: () async {
                  pageListNotifier.push(
                    const MaterialPage(
                      key: ValueKey('CreateTribuPage'),
                      child: CreateTribuPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(0, 48)),
                ),
                child: Text(S.of(context).joinATribuAction.toUpperCase()),
                onPressed: () async {
                  pageListNotifier.push(
                    const MaterialPage(
                      key: ValueKey('JoinTribuPage'),
                      child: JoinTribuPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
