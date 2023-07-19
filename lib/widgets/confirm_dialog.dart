import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/theme.dart';

class ConfirmDialog extends HookConsumerWidget {
  const ConfirmDialog(this.onConfirmed, {this.title, super.key});
  final Future<dynamic> Function() onConfirmed;
  final String? title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryTheme = ref.watch(primaryThemeProvider);
    final loading = useState(false);
    final navigator = Navigator.of(context, rootNavigator: true);
    Future<void> onSubmitted() async {
      loading.value = true;
      await onConfirmed();
      loading.value = false;
      navigator.pop();
    }

    return Theme(
      data: primaryTheme,
      child: AlertDialog(
        title: Text(title ?? S.of(context).confirmDialogTitle),
        actions: [
          TextButton(
            child: Text(S.of(context).cancelAction),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: loading.value == true ? null : onSubmitted,
            child: Text(
              S.of(context).confirmAction,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          )
        ],
      ),
    );
  }
}
