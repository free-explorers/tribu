import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TribuAvatar extends HookConsumerWidget {
  const TribuAvatar({super.key, this.color, this.text = '', this.radius = 40});
  final Color? color;
  final String text;
  final double radius;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: radius,
      child: CircleAvatar(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          child: Transform.scale(
            scale: radius / 40,
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),),
    );
  }
}
