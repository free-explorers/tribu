import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/theme.dart';
import 'package:tribu/widgets/confirm_dialog.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/text_field.dart';
import 'package:tribu/widgets/utils/selectable_list.widget.dart';

class ProfileListPage extends HookConsumerWidget {
  const ProfileListPage({
    super.key,
    this.initialProfileIdSelectedList = const [],
    this.onSelectionConfirmed,
    this.onMultiSelectionConfirmed,
    this.filter,
    this.title,
    this.allowEmptySelection = true,
  });
  final List<String> initialProfileIdSelectedList;
  final void Function(String)? onSelectionConfirmed;
  final void Function(List<String>)? onMultiSelectionConfirmed;
  final bool Function(Profile)? filter;
  final bool allowEmptySelection;

  final String? title;

  ProfileListAction determineDefaultAction() {
    if (onSelectionConfirmed != null) return ProfileListAction.singleSelection;
    if (onMultiSelectionConfirmed != null) {
      return ProfileListAction.multiSelection;
    }
    return ProfileListAction.none;
  }

  List<Profile> filterProfileList(List<Profile> profileList) {
    return profileList.where(filter ?? (e) => true).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (onSelectionConfirmed != null && onMultiSelectionConfirmed != null) {
      throw Exception(
        "Can't use both onSelectionConfirmed and onMultiSelectionConfirmed callback",
      );
    }
    final currentAction = useState(determineDefaultAction());
    final tribuId = ref.watch(tribuIdSelectedProvider)!;
    final profileList = ref.watch(profileListProvider(tribuId));
    final filteredProfileListState = useState(filterProfileList(profileList));
    useEffect(
      () {
        filteredProfileListState.value = filterProfileList(profileList);
        return null;
      },
      [profileList],
    );
    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);
    final primaryTheme = ref.watch(primaryThemeProvider);
    final profileSelectedListState = useState(
      filteredProfileListState.value
          .where((profile) => initialProfileIdSelectedList.contains(profile.id))
          .toList(),
    );

    void resetProfilePage() {
      currentAction.value = ProfileListAction.none;
      profileSelectedListState.value = [];
    }

    return Theme(
      data: primaryTheme,
      child: () {
        final defaultBackButton = IconButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          icon: Icon(MdiIcons.close),
        );
        switch (currentAction.value) {
          case ProfileListAction.none:
            return Scaffold(
              appBar: AppBar(
                leading: defaultBackButton,
                title: Text(title ?? S.of(context).memberListTitle),
                actions: [
                  PopupMenuButton(
                    icon: Icon(MdiIcons.dotsVertical),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<Widget>(
                        child: ListTile(
                          leading: Icon(MdiIcons.accountMultiple),
                          title: Text(S.of(context).mergeProfilesAction),
                        ),
                        onTap: () {
                          currentAction.value = ProfileListAction.merge;
                        },
                      ),
                      PopupMenuItem<Widget>(
                        child: ListTile(
                          leading: Icon(MdiIcons.accountOff),
                          title: Text(S.of(context).removeProfilesAction),
                        ),
                        onTap: () {
                          currentAction.value = ProfileListAction.archive;
                        },
                      )
                    ],
                  ),
                  const SizedBox(width: 8)
                ],
              ),
              body: SelectableList<Profile>(
                filteredProfileListState.value,
                buildTile: (context, profile, index) => SelectableTile(
                  title: Text(profile.name),
                  leading: ProfileAvatar(profile),
                ),
                bottomPadding: 80,
              ),
              floatingActionButton: FloatingActionButton.extended(
                icon: Icon(MdiIcons.accountPlus),
                label: Text(S.of(context).addExternalMemberAction),
                onPressed: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return HookConsumer(
                        builder: (context, ref, widget) {
                          final memberNameController =
                              useTextEditingController();
                          final update =
                              useValueListenable(memberNameController);
                          final loading = useState(false);
                          return Theme(
                            data: primaryTheme,
                            child: AlertDialog(
                              title:
                                  Text(S.of(context).addExternalMemberAction),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(S.of(context).externalMemberBlaming),
                                  const SizedBox(height: 8),
                                  TribuSubHeader(
                                    S.of(context).howShouldWeCallHim,
                                  ),
                                  const SizedBox(height: 8),
                                  TribuTextField(
                                    controller: memberNameController,
                                    placeholder:
                                        S.of(context).memberNameFormPlaceholder,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return S
                                            .of(context)
                                            .memberNameFormError;
                                      }
                                      return null;
                                    },
                                  )
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop(),
                                  child: Text(S.of(context).cancelAction),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        primaryTheme.colorScheme.secondary,
                                  ),
                                  onPressed:
                                      update.text.isEmpty || loading.value
                                          ? null
                                          : () async {
                                              final navigator = Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              );
                                              loading.value = true;
                                              await profileListNotifier
                                                  .createExternalProfile(
                                                update.text,
                                              );
                                              navigator.pop();
                                            },
                                  child: Text(S.of(context).createAction),
                                ),
                                const SizedBox(
                                  width: 8,
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          case ProfileListAction.singleSelection:
            return Scaffold(
              appBar: AppBar(
                leading: defaultBackButton,
                title: Text(title ?? S.of(context).selectAProfileAction),
              ),
              body: SelectableList<Profile>(
                filteredProfileListState.value,
                buildTile: (context, profile, index) => SelectableTile(
                  title: Text(profile.name),
                  leading: ProfileAvatar(profile),
                ),
                mode: SelectionMode.single,
                onSelection: (profile) {
                  onSelectionConfirmed?.call(profile.id);
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            );
          case ProfileListAction.multiSelection:
            return Scaffold(
              appBar: AppBar(
                leading: defaultBackButton,
                title: Text(title ?? S.of(context).selectProfilesAction),
                actions: [
                  Row(
                    children: [
                      Icon(MdiIcons.checkAll),
                      Checkbox(
                        value: profileSelectedListState.value.isNotEmpty &&
                                profileSelectedListState.value.length <
                                    filteredProfileListState.value.length
                            ? null
                            : profileSelectedListState.value.isNotEmpty,
                        tristate: true,
                        onChanged: (value) {
                          if (value ?? false) {
                            profileSelectedListState.value =
                                filteredProfileListState.value;
                          } else {
                            profileSelectedListState.value = [];
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 24)
                ],
              ),
              body: SelectableList<Profile>(
                filteredProfileListState.value,
                itemSelectedList: profileSelectedListState.value,
                buildTile: (context, profile, index) => SelectableTile(
                  title: Text(profile.name),
                  leading: ProfileAvatar(profile),
                ),
                mode: SelectionMode.multi,
                onMultiSelection: (profileSelectedList) =>
                    profileSelectedListState.value = profileSelectedList,
                bottomPadding: 80,
              ),
              floatingActionButton: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: profileSelectedListState.value.isEmpty &&
                        !allowEmptySelection
                    ? 0.5
                    : 1,
                child: FloatingActionButton.extended(
                  label: Text(S.of(context).selectionAction),
                  disabledElevation: 0,
                  onPressed: profileSelectedListState.value.isEmpty &&
                          !allowEmptySelection
                      ? null
                      : () {
                          onMultiSelectionConfirmed?.call(
                            profileSelectedListState.value
                                .map((e) => e.id)
                                .toList(),
                          );
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                ),
              ),
            );
          case ProfileListAction.merge:
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: resetProfilePage,
                  icon: Icon(MdiIcons.arrowLeft),
                ),
                title: Text(title ?? S.of(context).mergeProfilesAction),
              ),
              body: SelectableList<Profile>(
                filteredProfileListState.value,
                itemSelectedList: profileSelectedListState.value,
                buildTile: (context, profile, index) => SelectableTile(
                  title: Text(profile.name),
                  leading: ProfileAvatar(profile),
                ),
                mode: SelectionMode.multi,
                onMultiSelection: (profileSelectedList) =>
                    profileSelectedListState.value = profileSelectedList,
                bottomPadding: 80,
              ),
              floatingActionButton: Builder(
                builder: (context) {
                  final disabled = profileSelectedListState.value.length < 2;
                  return FloatingActionButton.extended(
                    label: Text(S.of(context).selectionAction),
                    backgroundColor:
                        disabled ? primaryTheme.cardTheme.color : null,
                    foregroundColor:
                        disabled ? primaryTheme.disabledColor : null,
                    disabledElevation: 1,
                    onPressed: !disabled
                        ? () {
                            showDialog<dynamic>(
                              context: context,
                              builder: (context) {
                                return HookConsumer(
                                  builder: (context, ref, widget) {
                                    final loading = useState(false);
                                    return Theme(
                                      data: primaryTheme,
                                      child: AlertDialog(
                                        title: Text(
                                          S.of(context).profileToKeepAction,
                                        ),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: SelectableList<Profile>(
                                            profileSelectedListState.value,
                                            buildTile: (
                                              context,
                                              profile,
                                              index,
                                            ) =>
                                                SelectableTile(
                                              title: Text(profile.name),
                                              leading: ProfileAvatar(profile),
                                            ),
                                            mode: loading.value
                                                ? SelectionMode.none
                                                : SelectionMode.single,
                                            shrinkWrap: true,
                                            onSelection:
                                                (profileSelected) async {
                                              loading.value = true;
                                              final navigator = Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              );
                                              await Future.wait(
                                                profileSelectedListState.value
                                                    .where(
                                                      (element) =>
                                                          element !=
                                                          profileSelected,
                                                    )
                                                    .map(
                                                      (profileToMerge) =>
                                                          profileListNotifier
                                                              .updateProfile(
                                                        profileToMerge.copyWith(
                                                          mergedInto:
                                                              profileSelected
                                                                  .id,
                                                        ),
                                                      ),
                                                    ),
                                              );
                                              navigator.pop();
                                              resetProfilePage();
                                            },
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.only(top: 16),
                                        actionsPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop,
                                            child: Text(
                                              S.of(context).cancelAction,
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                        : null,
                  );
                },
              ),
            );
          case ProfileListAction.archive:
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: resetProfilePage,
                  icon: Icon(MdiIcons.arrowLeft),
                ),
                title: Text(title ?? S.of(context).removeProfilesAction),
              ),
              body: SelectableList<Profile>(
                filteredProfileListState.value,
                itemSelectedList: profileSelectedListState.value,
                buildTile: (context, profile, index) => SelectableTile(
                  title: Text(profile.name),
                  leading: ProfileAvatar(profile),
                ),
                mode: SelectionMode.multi,
                onMultiSelection: (profileSelectedList) =>
                    profileSelectedListState.value = profileSelectedList,
                bottomPadding: 80,
              ),
              floatingActionButton: Builder(
                builder: (context) {
                  final disabled = profileSelectedListState.value.isEmpty;

                  return FloatingActionButton.extended(
                    backgroundColor:
                        disabled ? primaryTheme.cardTheme.color : null,
                    foregroundColor:
                        disabled ? primaryTheme.disabledColor : null,
                    disabledElevation: 1,
                    label: Text(S.of(context).selectionAction),
                    onPressed: disabled
                        ? null
                        : () {
                            showDialog<dynamic>(
                              context: context,
                              builder: (context) => ConfirmDialog(() async {
                                await Future.wait(
                                  profileSelectedListState.value.map(
                                    (profileToMerge) =>
                                        profileListNotifier.updateProfile(
                                      profileToMerge.copyWith(
                                        disabled: true,
                                      ),
                                    ),
                                  ),
                                );
                                resetProfilePage();
                              }),
                            );
                          },
                  );
                },
              ),
            );
        }
      }(),
    );
  }
}

enum ProfileListAction { none, singleSelection, multiSelection, merge, archive }
