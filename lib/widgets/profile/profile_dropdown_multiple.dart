import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/pages/with_tribu/profile_list/profile_list.page.dart';

class ProfileDropdown extends HookConsumerWidget {
  const ProfileDropdown({
    super.key,
    this.initialValue = const [],
    this.onMultiSelectionChange,
    this.filter,
    this.onSelectionChange,
    this.decoration,
    this.allowEmptySelection = true,
  });
  final List<String> initialValue;
  final void Function(String)? onSelectionChange;
  final void Function(List<String>)? onMultiSelectionChange;
  final bool Function(Profile)? filter;
  final InputDecoration? decoration;
  final bool allowEmptySelection;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (onSelectionChange != null && onMultiSelectionChange != null) {
      throw "Can't use both onSelectionChange and onMultiSelectionChange callback";
    }
    if (onSelectionChange == null && onMultiSelectionChange == null) {
      throw 'onSelectionChange or onMultiSelectionChange callback need to pe specified';
    }
    final tribuId = ref.watch(tribuIdSelectedProvider)!;
    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);

    String buildValue(List<String> selectedProfileIdList) {
      return selectedProfileIdList.length > 1 &&
              selectedProfileIdList.length ==
                  profileListNotifier.value.where(filter ?? (e) => true).length
          ? S.of(context).everyone
          : selectedProfileIdList
              .map((e) => profileListNotifier.getProfile(e).name)
              .join(', ');
    }

    final focusNode = useFocusNode();
    final textController =
        useTextEditingController(text: buildValue(initialValue));

    final currentValue = useState(initialValue);

    focusNode.canRequestFocus = false;

    useEffect(() {
      void cb() {
        if (focusNode.hasFocus) {
          focusNode.unfocus();
          textController.selection =
              const TextSelection(baseOffset: 0, extentOffset: 0);
        }
      }

      focusNode.addListener(cb);

      return () {
        focusNode.removeListener(cb);
      };
    });

    final pageListNotifier = ref.watch(pageListProvider.notifier);
    final finalDecoration =
        decoration ?? InputDecoration(suffixIcon: Icon(MdiIcons.formDropdown));
    return TextFormField(
      decoration: finalDecoration.copyWith(suffixIcon: Icon(MdiIcons.menuDown)),
      focusNode: focusNode,
      controller: textController,
      onTap: () {
        pageListNotifier.push(
          MaterialPage(
            key: const ValueKey('profileListPage'),
            child: ProfileListPage(
              title: finalDecoration.labelText,
              initialProfileIdSelectedList: currentValue.value,
              filter: filter,
              onSelectionConfirmed: onSelectionChange == null
                  ? null
                  : (profileIdSelected) {
                      currentValue.value = [profileIdSelected].toList();
                      textController.text = buildValue(currentValue.value);
                      onSelectionChange?.call(profileIdSelected);
                    },
              onMultiSelectionConfirmed: onMultiSelectionChange == null
                  ? null
                  : (profileIdSelectedList) {
                      currentValue.value = profileIdSelectedList;
                      textController.text = buildValue(currentValue.value);
                      onMultiSelectionChange?.call(profileIdSelectedList);
                    },
              allowEmptySelection: allowEmptySelection,
            ),
          ),
        );
        focusNode.unfocus();
        textController.selection =
            const TextSelection(baseOffset: 0, extentOffset: 0);
      },
    );
  }
}
