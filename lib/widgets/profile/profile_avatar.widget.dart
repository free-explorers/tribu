import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tribu/data/tribu/profile/profile.model.dart';
import 'package:tribu/widgets/tribu_avatar.dart';

const colors = [
  Color(0xFF50180D),
  Color(0xFF9F2E16),
  Color(0xFFCE6361),
  Color(0xFFD77847),
  Color(0xFF889B37),
  Color(0xFFA68F40),
  Color(0xFF9F7413),
  Color(0xFF585530),
  Color(0xFF415BA5),
  Color(0xFF087491),
  Color(0xFF549ABA),
  Color(0xFF52A28B),
  Color(0xFFD15528),
  Color(0xFFC94758),
  Color(0xFFDB2751),
  Color(0xFFE02F28),
  Color(0xFFFF5800),
  Color(0xFFE3B900),
  Color(0xFF3B8F4A),
  Color(0xFF296133),
  Color(0xFF5C6925),
  Color(0xFF728D49),
  Color(0xFF55B500),
  Color(0xFF3F87D4),
  Color(0xFF6980FF),
  Color(0xFF678583),
  Color(0xFF4545DE),
  Color(0xFF997EC4)
];

const icons = [
  'assets/avatar_icons/0.png',
  'assets/avatar_icons/1.png',
  'assets/avatar_icons/2.png',
  'assets/avatar_icons/3.png',
  'assets/avatar_icons/4.png',
  'assets/avatar_icons/5.png',
  'assets/avatar_icons/6.png',
  'assets/avatar_icons/7.png',
  'assets/avatar_icons/8.png',
];

class ProfileAvatar extends HookConsumerWidget {
  const ProfileAvatar(this.profile, {super.key, this.radius = 40});
  final Profile profile;
  final double radius;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rng = Random(profile.id.hashCode);
    return TribuAvatar(
        color: colors[rng.nextInt(colors.length)],
        text: profile.name.substring(0, min(2, profile.name.length)),
        radius: radius,);
  }
}
