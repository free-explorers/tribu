import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/theme.dart';
import 'package:tribu/utils/color.dart';
import 'package:tribu/widgets/utils/expandable.widget.dart';

class ExpandableCard extends HookConsumerWidget {
  const ExpandableCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
    this.expanded = false,
    this.onExpansionChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool expanded;
  final void Function({required bool isExpanded})? onExpansionChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpandedState = useState(expanded);
    useEffect(
      () {
        isExpandedState.value = expanded;
        return null;
      },
      [expanded],
    );

    return Card(
      color: lighten(tribuBlue),
      elevation: isExpandedState.value ? 4 : null,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            title: Text(title),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            onTap: isExpandedState.value
                ? null
                : () {
                    isExpandedState.value = !isExpandedState.value;
                    onExpansionChanged?.call(isExpanded: isExpandedState.value);
                  },
          ),
          TribuExpandable(
            isExpanded: isExpandedState.value,
            collapsed: Container(),
            expanded: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }
}
