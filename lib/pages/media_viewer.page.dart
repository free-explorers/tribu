import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/data/storage.providers.dart';
import 'package:tribu/generated/l10n.dart';

class MediaViewerPage extends HookConsumerWidget {
  const MediaViewerPage(this.mediaList, this.initialeIndex, {super.key});
  final List<Media> mediaList;
  final int initialeIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController(initialPage: initialeIndex);
    /* final media = mediaList.elementAt(index);

    final file = useMemoized(() => File(
        '${ref.read(permanentDirectoryProvider).absolute.path}/${media.localPath}'));

    bool isVideo = media.mime.split('/').contains('video');

    late Widget widget;
    if (isVideo) {
      //widget = TribuVideoPlayer(media.localPath!);
    } else {
      widget = PhotoView(
        heroAttributes:
            PhotoViewHeroAttributes(tag: media.localPath ?? media.remoteUrl!),
        imageProvider: FileImage(file),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 5,
      );
    } */
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final media = mediaList.elementAt(pageController.page!.round());
              await ImageGallerySaver.saveFile(
                '${ref.read(permanentDirectoryProvider).absolute.path}/${media.localPath}',
              );
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  // ignore: use_build_context_synchronously
                  content: Text(S.of(context).imageSavedToGallery),
                ),
              );
            },
            icon: Icon(MdiIcons.contentSave),
          ),
          const SizedBox(width: 8)
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: mediaList.length,
        builder: (BuildContext context, index) {
          final media = mediaList.elementAt(index);
          return PhotoViewGalleryPageOptions(
            heroAttributes: PhotoViewHeroAttributes(
              tag: media.localPath ?? media.remoteUrl!,
            ),
            imageProvider: FileImage(
              File(
                '${ref.read(permanentDirectoryProvider).absolute.path}/${media.localPath}',
              ),
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 5,
          );
        },
        pageController: pageController,
      ),
    );
  }
}
