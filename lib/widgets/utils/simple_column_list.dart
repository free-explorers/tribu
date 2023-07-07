import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SimpleColumnList extends StatelessWidget {
  const SimpleColumnList({
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    super.key,
  });
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    final list = Iterable<int>.generate(itemCount).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list
          .map((idx) {
            return [
              itemBuilder(context, idx),
              if (idx != list.last && separatorBuilder != null)
                separatorBuilder!.call(context, idx)
            ];
          })
          .flattened
          .toList(),
    );
  }
}
