import 'dart:io';
import 'dart:typed_data';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as image_dart;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/data/storage.providers.dart';

class MediaImage extends HookConsumerWidget {
  const MediaImage(this.media, {super.key});
  final Media media;

  Image getBlurhashWidget(Uint8List bytes) {
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.red,
        child: Icon(MdiIcons.image),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blurhashBytes = ref.watch(blurhashImageProvider(media));
    final animationController =
        useAnimationController(duration: const Duration(milliseconds: 100));
    final animation = useMemoized(
      () => CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    final directory = ref.watch(permanentDirectoryProvider);
    if (media.localPath == null) {
      return getBlurhashWidget(blurhashBytes);
    }
    return Image(
      image: FileImage(File('${directory.absolute.path}/${media.localPath!}')),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          getBlurhashWidget(blurhashBytes),
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        if (frame != null) {
          animationController.forward();
        }

        return Stack(
          fit: StackFit.passthrough,
          children: [
            getBlurhashWidget(blurhashBytes),
            if (frame != null)
              FadeTransition(
                opacity: animation,
                child: child,
              )
          ],
        );
      },
    );
  }
}

final blurhashImageProvider = Provider.family<Uint8List, Media>((ref, media) {
  final blurHash = media.additionalData!['blurhash'];
  final width = media.additionalData!['width'] as int? ?? 32;
  final height = media.additionalData!['height'] as int? ?? 32;
  final aspectRatio = width / height;
  final image = BlurHash.decode(blurHash as String).toImage(
    32,
    (32 * aspectRatio).round(),
  );
  return Uint8List.fromList(image_dart.encodeJpg(image));
});
