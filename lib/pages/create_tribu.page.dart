import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/text_field.dart';

class CreateTribuPage extends HookConsumerWidget {
  const CreateTribuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final tribuListNotifier = ref.watch(tribuListProvider.notifier);
    final tribuNameController = useTextEditingController();
    final memberNameController = useTextEditingController();
    final pageListNotifier = ref.watch(pageListProvider.notifier);
    final isLoading = useState(false);
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).createATribuAction)),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              TribuSubHeader(S.of(context).tribeNameInstruction),
              const SizedBox(height: 8),
              TribuTextField(
                controller: tribuNameController,
                placeholder: S.of(context).tribuNameFormPlaceholder,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).tribuNameFormError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TribuSubHeader(
                S.of(context).howShouldWeCallYou,
              ),
              const SizedBox(height: 8),
              TribuTextField(
                controller: memberNameController,
                placeholder: S.of(context).memberNameFormPlaceholder,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).memberNameFormError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        final valid = formKey.currentState!.validate();
                        if (valid) {
                          formKey.currentState!.save();
                          isLoading.value = true;
                          final newTribu = await tribuListNotifier.createTribu(
                            tribuNameController.text,
                            memberNameController.text,
                          );
                          await ref
                              .read(tribuIdSelectedProvider.notifier)
                              .setTribuId(newTribu.id);

                          isLoading.value = false;
                          pageListNotifier.pop();
                        }
                      },
                child: Text(S.of(context).createTheTribuAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
