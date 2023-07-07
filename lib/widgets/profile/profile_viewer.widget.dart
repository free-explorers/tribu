import 'package:flutter/material.dart';

import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/widgets/profile/profile_avatar.widget.dart';

class ProfileViewer extends StatelessWidget {
  const ProfileViewer(this.profile, {super.key});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(20)),),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(profile),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Text(
              profile.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
