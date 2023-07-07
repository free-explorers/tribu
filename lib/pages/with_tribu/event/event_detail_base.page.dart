import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';

abstract class EventDetailBase extends HookConsumerWidget {
  const EventDetailBase({
    required this.eventId,
    this.pageTitle = '',
    super.key,
  });
  final String eventId;
  final String pageTitle;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.read(tribuIdSelectedProvider)!;

    final event = ref
        .watch(eventListProvider(tribuId))
        .firstWhere((element) => element.id == eventId);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                buildTitle(event, context, ref),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: buildBody(event, context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String buildTitle(Event event, BuildContext context, WidgetRef ref) {
    return pageTitle;
  }

  Widget buildBody(Event event, BuildContext context, WidgetRef ref);
}
