import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class WebVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool autoPlay;
  final bool loop;
  final bool muted;

  const WebVideoPlayer({
    super.key,
    required this.videoPath,
    this.autoPlay = true,
    this.loop = true,
    this.muted = true,
  });

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late html.VideoElement _videoElement;
  String _viewId = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _viewId = 'video-${DateTime.now().millisecondsSinceEpoch}';

    // For Flutter web, assets are served from assets/ directory
    String webVideoPath = widget.videoPath.startsWith('assets/')
        ? 'assets/${widget.videoPath}'
        : widget.videoPath;

    _videoElement = html.VideoElement()
      ..src = webVideoPath
      ..autoplay = widget.autoPlay
      ..loop = widget.loop
      ..muted = widget.muted
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.border = 'none'
      ..onLoadedData.listen((_) {
        print('Video loaded successfully');
      })
      ..onError.listen((error) {
        print('Video error: $error');
      });

    // Register the video element
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _videoElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewId,
    );
  }

  @override
  void dispose() {
    _videoElement.remove();
    super.dispose();
  }
}
