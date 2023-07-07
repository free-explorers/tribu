import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/data/media/media_in_transition.model.dart';
import 'package:tribu/data/tribu/message/message.providers.dart';
import 'package:tribu/data/tribu/tribu.providers.dart';
import 'package:tribu/widgets/media/media_image.dart';

class MediaThumbnail extends HookConsumerWidget {
  const MediaThumbnail(this.messageId, this.media, {super.key, this.onTap});
  final String messageId;
  final Media media;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribuId = ref.watch(tribuIdSelectedProvider);
    final mediaInTransition = ref.watch(
      mediaManagerProvider(tribuId!)
          .select((value) => value[media.remoteUrl ?? media.localPath]),
    );
    final messageMapNotifier = ref.watch(messageMapProvider(tribuId).notifier);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mediaInTransition == null && media.localPath == null) {
          messageMapNotifier.downloadMediaForMessage(messageId, media);
        }
      });

      return null;
    });

    Widget? statusWidget;
    switch (mediaInTransition?.status) {
      case MediaTransitionStatus.processing:
      case MediaTransitionStatus.downloading:
      case MediaTransitionStatus.uploading:
        statusWidget = CircularProgressIndicator(
          value: mediaInTransition!.progress > 0.0
              ? mediaInTransition.progress / 100
              : null,
          color: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
        break;
      case MediaTransitionStatus.error:
        statusWidget = Icon(
          MdiIcons.closeCircle,
          color: Colors.red.withOpacity(0.8),
        );
        break;

      case MediaTransitionStatus.done:
/*         statusWidget = Icon(
          MdiIcons.checkCircle,
          color: Colors.white.withOpacity(0.6),
        );
        break; */
      case null:
        break;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = media.additionalData?['width'] as int? ?? 32;
            final height = media.additionalData?['height'] as int? ?? 32;

            return Container(
              constraints: BoxConstraints(
                maxHeight: height.toDouble(),
                maxWidth: width.toDouble(),
              ),
              child: AspectRatio(
                aspectRatio: width / height,
                child: Hero(
                  tag: media.localPath ?? media.remoteUrl!,
                  child: MediaImage(media),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: SizedBox(
            width: 24,
            height: 24,
            child: statusWidget,
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
            ),
          ),
        )
      ],
    );
  }
}
