import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/widgets/profile/profile_viewer.widget.dart';

class ProfileListViewer extends HookConsumerWidget {
  const ProfileListViewer({required this.profileList, super.key});
  final List<Profile> profileList;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: profileList.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: 8,
      ),
      itemBuilder: (context, index) {
        return ProfileViewer(profileList[index]);
      },
    );
  }
}
