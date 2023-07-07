import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/config.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/tribu.model.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/text_field.dart';

class JoinTribuPage extends HookConsumerWidget {
  const JoinTribuPage({super.key, this.link});
  final Uri? link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuListNotifier = ref.watch(tribuListProvider.notifier);
    final tribuLinkController = useTextEditingController(
      text: link != null ? Uri.decodeFull(link.toString()) : null,
    );
    /* final pendingProfileAsync =
        ref.watch(tribuPendingProfileFamily(tribuLinkController.text));
    pendingProfileAsync.whenData((value) => null); */
    final memberNameController = useTextEditingController();
    final isLoading = useState(false);
    final tribuNotifier = useState<Tribu?>(null);
    final encryptionKeyNotifier = useState<String?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final pageListNotifier = ref.watch(pageListProvider.notifier);
    if (link != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).joinATribuAction)),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              TribuSubHeader(
                S.of(context).joinATribeLinkInstruction,
              ),
              const SizedBox(height: 16),
              TribuLinkField(
                controller: tribuLinkController,
                onTribuChange: ([tribu, encryptionKey]) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    tribuNotifier.value = tribu;
                    encryptionKeyNotifier.value = encryptionKey;
                  });
                },
              ),
              if (tribuNotifier.value != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TribuSubHeader(
                      S.of(context).youAreAboutToJoinTheTribu,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tribuNotifier.value!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
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
                                isLoading.value = true;
                                await tribuListNotifier.joinTribu(
                                  tribuNotifier.value!,
                                  encryptionKeyNotifier.value!,
                                  Profile(
                                    id: ref.read(currentUserProvider)!.uid,
                                    name: memberNameController.value.text,
                                    createdAt: DateTime.now(),
                                  ),
                                );
                                await ref
                                    .read(tribuIdSelectedProvider.notifier)
                                    .setTribuId(tribuNotifier.value!.id);
                                isLoading.value = false;
                                pageListNotifier.pop();
                              }
                            },
                      child: Text(S.of(context).joinTheTribu),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class TribuLinkField extends HookConsumerWidget {
  const TribuLinkField({super.key, this.controller, this.onTribuChange});
  final TextEditingController? controller;
  final void Function([Tribu?, String? key])? onTribuChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuListNotifier = ref.watch(tribuListProvider.notifier);
    final validatingNotifier = useState(false);
    final lastValueTestedNotifier = useState<String?>(null);
    final validationResultNotifier = useState<String?>(null);
    final isValidNotifier = useState(false);
    final formFieldKey = useMemoized(GlobalKey<FormFieldState>.new);
    final focusNode = useFocusNode();
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        TextFormField(
          key: formFieldKey,
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            filled: true,
            focusColor: Theme.of(context).colorScheme.secondary,
            prefixIcon: Icon(MdiIcons.link),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelText: S.of(context).pastAnInvitationLinkHere,
            suffixIcon: (isValidNotifier.value ? Icon(MdiIcons.check) : null),
          ),
          onChanged: (value) {
            formFieldKey.currentState!.validate();
          },
          validator: (value) {
            if (value == lastValueTestedNotifier.value) {
              return validationResultNotifier.value;
            }
            lastValueTestedNotifier.value = value;
            String? err;
            if (value == null || value.isEmpty) {
              err = S.of(context).thisFieldIsRequired;
            } else if (!value.contains(AppConfig.inviteLinkPrefix)) {
              err = S.of(context).theLinkIsNotRecognized;
            }

            if (err != null) {
              validationResultNotifier.value = err;
              if (isValidNotifier.value == true) {
                isValidNotifier.value = false;
                onTribuChange?.call();
              }
              return validationResultNotifier.value;
            } else {
              validatingNotifier.value = true;

              final keyReg = RegExp(r'key=(.*?)(&|$)');
              final match = keyReg.firstMatch(value!);
              if (match == null) {
                validationResultNotifier.value = S.of(context).linkIsInvalid;
                validatingNotifier.value = false;
                return null;
              }
              final group = match.group(1)!;
              final tribuId = group.substring(0, group.length - 44);
              final encryptionKey = group.substring(group.length - 44);
              tribuListNotifier.getTribu(tribuId).then((tribu) {
                final exist = tribu != null;
                var valid = exist;
                if (!exist) {
                  validationResultNotifier.value = S.of(context).linkIsInvalid;
                } else if (tribu.authorizedMemberList
                    .contains(ref.read(currentUserProvider)!.uid)) {
                  validationResultNotifier.value =
                      S.of(context).youAreAlreadyInTheTribu;
                  valid = false;
                } else {
                  validationResultNotifier.value = null;
                }
                if (isValidNotifier.value != valid) {
                  isValidNotifier.value = valid;
                  onTribuChange?.call(tribu, encryptionKey);
                  focusNode.unfocus();
                } else {
                  Form.of(context).validate();
                }
                validatingNotifier.value = false;
              });
              return null;
            }
          },
        ),
        if (validatingNotifier.value)
          Container(
            margin: const EdgeInsetsDirectional.only(end: 12),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }
}
