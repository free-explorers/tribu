import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/data/tribu/profile/profile.providers.dart';
import 'package:tribu/data/tribu/profile/profile_list.notifier.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/theme.dart';
import 'package:tribu/widgets/confirm_dialog.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';
import 'package:tribu/widgets/sub_header.dart';
import 'package:tribu/widgets/text_field.dart';
import 'package:tribu/widgets/utils/selectable_list.widget.dart';
import 'package:tribu/widgets/utils/simple_column_list.dart';

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
    final profileListNotifier =
        ref.watch(profileListProvider(tribuId).notifier);
    final filteredProfileListState = useState(filterProfileList(profileList));
    useEffect(
      () {
        filteredProfileListState.value = (initialProfileIdSelectedList
                .map(profileListNotifier.getProfile)
                .toSet()
              ..addAll(filterProfileList(profileList)))
            .toList();
        return null;
      },
      [profileList],
    );

    final primaryTheme = ref.watch(primaryThemeProvider);
    final profileSelectedListState = useState(
      initialProfileIdSelectedList.map(profileListNotifier.getProfile).toList(),
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
            return NoneActionProfileList(
              currentAction: currentAction,
              defaultBackButton: defaultBackButton,
              filteredProfileListState: filteredProfileListState,
              primaryTheme: primaryTheme,
              profileListNotifier: profileListNotifier,
              title: title,
            );
          case ProfileListAction.singleSelection:
            return SingleActionProfileList(
              defaultBackButton: defaultBackButton,
              filteredProfileListState: filteredProfileListState,
              title: title,
              onSelectionConfirmed: onSelectionConfirmed,
            );
          case ProfileListAction.multiSelection:
            return MultiActionProfileList(
              allowEmptySelection: allowEmptySelection,
              defaultBackButton: defaultBackButton,
              filteredProfileListState: filteredProfileListState,
              profileSelectedListState: profileSelectedListState,
              title: title,
              onMultiSelectionConfirmed: onMultiSelectionConfirmed,
            );
          case ProfileListAction.merge:
            return MergeActionProfileList(
              allowEmptySelection: allowEmptySelection,
              filteredProfileListState: filteredProfileListState,
              primaryTheme: primaryTheme,
              profileListNotifier: profileListNotifier,
              profileSelectedListState: profileSelectedListState,
              resetProfilePage: resetProfilePage,
            );
          case ProfileListAction.archive:
            return ArchiveActionProfileList(
              allowEmptySelection: allowEmptySelection,
              filteredProfileListState: filteredProfileListState,
              primaryTheme: primaryTheme,
              profileListNotifier: profileListNotifier,
              profileSelectedListState: profileSelectedListState,
              resetProfilePage: resetProfilePage,
            );
          case ProfileListAction.viewAll:
            return ViewAllActionProfileList(
              filteredProfileListState: filteredProfileListState,
              profileSelectedListState: profileSelectedListState,
              allowEmptySelection: allowEmptySelection,
              resetProfilePage: resetProfilePage,
              primaryTheme: primaryTheme,
              profileListNotifier: profileListNotifier,
            );
        }
      }(),
    );
  }
}

enum ProfileListAction {
  none,
  singleSelection,
  multiSelection,
  merge,
  archive,
  viewAll
}

class NoneActionProfileList extends StatelessWidget {
  const NoneActionProfileList({
    required this.defaultBackButton,
    required this.title,
    required this.currentAction,
    required this.filteredProfileListState,
    required this.primaryTheme,
    required this.profileListNotifier,
    super.key,
  });
  final ProfileListNotifier profileListNotifier;
  final Widget defaultBackButton;

  final String? title;
  final ValueNotifier<ProfileListAction> currentAction;
  final ValueNotifier<List<Profile>> filteredProfileListState;
  final ThemeData primaryTheme;

  @override
  Widget build(BuildContext context) {
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
              ),
              PopupMenuItem<Widget>(
                child: ListTile(
                  leading: Icon(MdiIcons.accountEye),
                  title: Text(S.of(context).viewAllProfilesAction),
                ),
                onTap: () {
                  currentAction.value = ProfileListAction.viewAll;
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
                  final memberNameController = useTextEditingController();
                  final update = useValueListenable(memberNameController);
                  final loading = useState(false);
                  return Theme(
                    data: primaryTheme,
                    child: AlertDialog(
                      title: Text(S.of(context).addExternalMemberAction),
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
                                return S.of(context).memberNameFormError;
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
                            backgroundColor: primaryTheme.colorScheme.secondary,
                          ),
                          onPressed: update.text.isEmpty || loading.value
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
  }
}

class SingleActionProfileList extends StatelessWidget {
  const SingleActionProfileList({
    required this.defaultBackButton,
    required this.title,
    required this.filteredProfileListState,
    super.key,
    this.onSelectionConfirmed,
  });
  final Widget defaultBackButton;

  final String? title;
  final ValueNotifier<List<Profile>> filteredProfileListState;
  final void Function(String)? onSelectionConfirmed;

  @override
  Widget build(BuildContext context) {
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
  }
}

class MultiActionProfileList extends StatelessWidget {
  const MultiActionProfileList({
    required this.defaultBackButton,
    required this.title,
    required this.filteredProfileListState,
    required this.profileSelectedListState,
    required this.allowEmptySelection,
    super.key,
    this.onMultiSelectionConfirmed,
  });
  final Widget defaultBackButton;

  final String? title;
  final ValueNotifier<List<Profile>> filteredProfileListState;
  final void Function(List<String>)? onMultiSelectionConfirmed;
  final ValueNotifier<List<Profile>> profileSelectedListState;
  final bool allowEmptySelection;

  @override
  Widget build(BuildContext context) {
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
        opacity: profileSelectedListState.value.isEmpty && !allowEmptySelection
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
                    profileSelectedListState.value.map((e) => e.id).toList(),
                  );
                  Navigator.of(context, rootNavigator: true).pop();
                },
        ),
      ),
    );
  }
}

class MergeActionProfileList extends StatelessWidget {
  const MergeActionProfileList({
    required this.filteredProfileListState,
    required this.profileSelectedListState,
    required this.allowEmptySelection,
    required this.resetProfilePage,
    required this.primaryTheme,
    required this.profileListNotifier,
    super.key,
  });

  final ValueNotifier<List<Profile>> filteredProfileListState;
  final ValueNotifier<List<Profile>> profileSelectedListState;
  final bool allowEmptySelection;
  final void Function() resetProfilePage;
  final ThemeData primaryTheme;
  final ProfileListNotifier profileListNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: resetProfilePage,
          icon: Icon(MdiIcons.arrowLeft),
        ),
        title: Text(S.of(context).mergeProfilesAction),
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
            backgroundColor: disabled ? primaryTheme.cardTheme.color : null,
            foregroundColor: disabled ? primaryTheme.disabledColor : null,
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
                                    onSelection: (profileSelected) async {
                                      loading.value = true;
                                      final navigator = Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      );
                                      await Future.wait(
                                        profileSelectedListState.value
                                            .where(
                                              (element) =>
                                                  element != profileSelected,
                                            )
                                            .map(
                                              (profileToMerge) =>
                                                  profileListNotifier
                                                      .updateProfile(
                                                profileToMerge.copyWith(
                                                  mergedInto:
                                                      profileSelected.id,
                                                ),
                                              ),
                                            ),
                                      );
                                      navigator.pop();
                                      resetProfilePage();
                                    },
                                  ),
                                ),
                                contentPadding: const EdgeInsets.only(top: 16),
                                actionsPadding: const EdgeInsets.symmetric(
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
  }
}

class ArchiveActionProfileList extends StatelessWidget {
  const ArchiveActionProfileList({
    required this.filteredProfileListState,
    required this.profileSelectedListState,
    required this.allowEmptySelection,
    required this.resetProfilePage,
    required this.primaryTheme,
    required this.profileListNotifier,
    super.key,
  });

  final ValueNotifier<List<Profile>> filteredProfileListState;
  final ValueNotifier<List<Profile>> profileSelectedListState;
  final bool allowEmptySelection;
  final void Function() resetProfilePage;
  final ThemeData primaryTheme;
  final ProfileListNotifier profileListNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: resetProfilePage,
          icon: Icon(MdiIcons.arrowLeft),
        ),
        title: Text(S.of(context).removeProfilesAction),
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
            backgroundColor: disabled ? primaryTheme.cardTheme.color : null,
            foregroundColor: disabled ? primaryTheme.disabledColor : null,
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
}

class ViewAllActionProfileList extends StatelessWidget {
  const ViewAllActionProfileList({
    required this.filteredProfileListState,
    required this.profileSelectedListState,
    required this.allowEmptySelection,
    required this.resetProfilePage,
    required this.primaryTheme,
    required this.profileListNotifier,
    super.key,
  });

  final ValueNotifier<List<Profile>> filteredProfileListState;
  final ValueNotifier<List<Profile>> profileSelectedListState;
  final bool allowEmptySelection;
  final void Function() resetProfilePage;
  final ThemeData primaryTheme;
  final ProfileListNotifier profileListNotifier;

  @override
  Widget build(BuildContext context) {
    final mergedIntoMap = <String, List<Profile>>{};
    final allProfileButMergedIntoList = <Profile>[];
    for (final profile in profileListNotifier.allProfileMapById.values) {
      if (profile.mergedInto != null) {
        if (!mergedIntoMap.containsKey(profile.mergedInto)) {
          mergedIntoMap[profile.mergedInto!] = [profile];
        } else {
          mergedIntoMap[profile.mergedInto!]!.add(profile);
        }
      } else {
        allProfileButMergedIntoList.add(profile);
      }
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: resetProfilePage,
          icon: Icon(MdiIcons.arrowLeft),
        ),
        title: Text(S.of(context).viewAllProfilesAction),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        itemCount: allProfileButMergedIntoList.length,
        separatorBuilder: (context, index) => const SizedBox(
          height: 8,
        ),
        itemBuilder: (context, index) {
          final profile = allProfileButMergedIntoList.elementAt(index);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: profile.disabled ?? false ? 1 : 0.6,
                child: Card(
                  child: ListTile(
                    leading: profile.disabled ?? false
                        ? Icon(MdiIcons.eyeOff)
                        : ProfileAvatar(profile),
                    title: Text(profile.name),
                    onTap: profile.disabled ?? false
                        ? () => showDialog<dynamic>(
                              context: context,
                              builder: (context) => ConfirmDialog(
                                () async {
                                  await profileListNotifier.updateProfile(
                                    profile.copyWith(
                                      disabled: null,
                                    ),
                                  );
                                },
                                title: S
                                    .of(context)
                                    .unArchiveProfileConfirmationAction,
                              ),
                            )
                        : null,
                  ),
                ),
              ),
              if (mergedIntoMap.containsKey(profile.id)) ...[
                const SizedBox(
                  height: 8,
                ),
                SimpleColumnList(
                  itemCount: mergedIntoMap[profile.id]!.length,
                  separatorBuilder: (p0, p1) => const SizedBox(
                    height: 8,
                  ),
                  itemBuilder: (context, index) {
                    final mergedProfile =
                        mergedIntoMap[profile.id]!.elementAt(index);
                    return Row(
                      children: [
                        const SizedBox(
                          width: 16,
                        ),
                        Icon(MdiIcons.arrowUpLeft),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              title: Text(mergedProfile.name),
                              onTap: () => showDialog<dynamic>(
                                context: context,
                                builder: (context) => ConfirmDialog(
                                  () async {
                                    await profileListNotifier.updateProfile(
                                      mergedProfile.copyWith(
                                        mergedInto: null,
                                      ),
                                    );
                                  },
                                  title:
                                      S.of(context).unmergeConfirmationAction,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              ]
            ],
          );
        },
      ),
    );
  }
}
