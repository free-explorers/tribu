import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/text_field.dart';

class PermanentEventForm extends HookConsumerWidget {
  const PermanentEventForm({super.key, this.event, this.onChanged});
  final PermanentEvent? event;
  final void Function(PermanentEvent event, {required bool isValid})? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Title Field
    final titleTextController = useTextEditingController(text: event?.title);
    final titleFocusNode = useFocusNode();
    final eventEncryptionKey =
        useState(encrypt.Key.fromSecureRandom(32).base64);

    void whenChanged() {
      onChanged?.call(
        event != null
            ? event!.copyWith(title: titleTextController.value.text)
            : PermanentEvent(
                title: titleTextController.value.text,
                toolIdList: [],
                createdAt: DateTime.now(),
                encryptionKey: eventEncryptionKey.value,
              ),
        isValid: titleTextController.value.text.isNotEmpty,
      );
    }

    return Form(
      key: formKey,
      onChanged: whenChanged,
      child: Column(
        children: [
          // Title
          TribuTextTheme(
            child: TextFormField(
              textInputAction: TextInputAction.next,
              controller: titleTextController,
              focusNode: titleFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).thisFieldIsRequired;
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                focusColor: Theme.of(context).colorScheme.secondary,
                labelText: S.of(context).titlePlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
