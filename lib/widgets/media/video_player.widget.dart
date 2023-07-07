/* import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class TribuVideoPlayer extends StatefulWidget {
  final String path;
  const TribuVideoPlayer(this.path, {Key? key}) : super(key: key);

  @override
  State<TribuVideoPlayer> createState() => _TribuVideoPlayerState();
}

class _TribuVideoPlayerState extends State<TribuVideoPlayer> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    print('before');
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        print('after');

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: true,
          looping: true,
        );
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Chewie(
            controller: _chewieController,
          )
        : Container();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }
}
 */