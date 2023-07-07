import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/media/media.model.dart';
import 'package:tribu/widgets/media/media_thumbnail.dart';

class MediaListViewer extends HookConsumerWidget {
  const MediaListViewer(
    this.messageId,
    this.mediaList, {
    super.key,
    this.onMediaTap,
  });
  final String messageId;
  final List<Media> mediaList;
  final void Function(int index)? onMediaTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaList.length == 1) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: MediaThumbnail(
          messageId,
          mediaList.elementAt(0),
          onTap: () => onMediaTap?.call(0),
        ),
      );
    } else if (mediaList.length < 4) {
      return Row(
        children: mediaList
            .map((e) => getGridThumbnail(mediaList.indexOf(e)))
            .toList(),
      );
    } else if (mediaList.length == 4) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [getGridThumbnail(0), getGridThumbnail(1)]),
          Row(
            children: [getGridThumbnail(2), getGridThumbnail(3)],
          )
        ],
      );
    } else if (mediaList.length == 5) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [getGridThumbnail(0), getGridThumbnail(1)]),
          Row(
            children: [
              getGridThumbnail(2),
              getGridThumbnail(3),
              getGridThumbnail(4)
            ],
          )
        ],
      );
    } else {
      final rowList = <Widget>[];
      for (var i = 0; i < (mediaList.length / 3).ceil(); i++) {
        final widgetList = <Widget>[];
        for (var y = 0; y < min(mediaList.length - 3 * i, 3); y++) {
          widgetList.add(getGridThumbnail(i * 3 + y));
        }
        rowList.add(
          Row(
            children: widgetList,
          ),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: rowList,
      );
    }

/*     if (mediaList.length == 1) {
      return Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: MediaThumbnail(messageId, mediaList.elementAt(0)));
    } else {
      int crossAxisCount = 3;

      List<QuiltedGridTile> pattern = const [
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 1)
      ];
      QuiltedGridRepeatPattern repeatPattern =
          QuiltedGridRepeatPattern.inverted;
      if ((mediaList.length / 3) % 1 != 0) {
        if ((mediaList.length / 2) % 1 == 0) {
          crossAxisCount = 2;
          pattern = const [
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 1),
          ];
        } else if ((mediaList.length / 5) % 1 == 0) {
          crossAxisCount = 6;
          pattern = const [
            QuiltedGridTile(3, 3),
            QuiltedGridTile(3, 3),
            QuiltedGridTile(2, 2),
            QuiltedGridTile(2, 2),
            QuiltedGridTile(2, 2)
          ];
        }
      }
      return GridView.custom(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          repeatPattern: repeatPattern,
          pattern: pattern,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
            (context, index) =>
                MediaThumbnail(messageId, mediaList.elementAt(index)),
            childCount: mediaList.length),
      );
    } */
  }

  Widget getGridThumbnail(int index) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: MediaThumbnail(
          messageId,
          mediaList.elementAt(index),
          onTap: () => onMediaTap?.call(index),
        ),
      ),
    );
  }

  dynamic determineBestColumnCount(int length) {
    if (length < 4) return length;
    if (length == 4) return 2;
    return 3;
  }

  void getBestSettings(int length) {}
}
