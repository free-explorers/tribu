import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/event/event.model.dart';

class EventScaffold extends HookConsumerWidget {
  const EventScaffold({
    required this.event,
    required this.pageTitle,
    required this.body,
    this.floatingActionButton,
    this.pageIcon,
    super.key,
  });
  final Event event;
  final String pageTitle;
  final Icon? pageIcon;
  final Widget body;
  final Widget? floatingActionButton;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = Card(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 24,
          ),
          IconTheme.merge(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                ),
                if (pageIcon != null) ...[
                  pageIcon!,
                  const SizedBox(
                    width: 16,
                  )
                ],
                Text(
                  pageTitle,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          body,
        ],
      ),
    );

    final scrollList = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(
                8,
              ),
              child: card,
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: scrollList,
      floatingActionButton: floatingActionButton,
    );
  }
}
