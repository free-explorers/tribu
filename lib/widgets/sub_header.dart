import 'package:flutter/material.dart';

class TribuSubHeader extends StatelessWidget {
  const TribuSubHeader(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: color),
      ),
    );
  }
}
