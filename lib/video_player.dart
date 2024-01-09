import 'package:cached_video_player_test/video_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController networkController;
  VideoPlayerController? fileController;

  @override
  void initState() {
    super.initState();
    networkController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl),)
      ..initialize().then((_) {
        setState(() {});
      });
    _cacheVideo();
  }

  Future<void> _cacheVideo() async {
    try {
      final filePath = await downloadAndCacheVideo(widget.videoUrl);
      if (mounted) {
        fileController = VideoPlayerController.file(File(filePath))
          ..initialize().then((_) {
            if (mounted) {
              // Dispose the network controller and play from file
              networkController.dispose();
              setState(() {
                fileController!.play();
              });
            }
          });
      }
    } catch (e) {
      // Handle errors in caching
      print('Error caching video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 50.0,
            maxHeight: 500.0,
            minWidth: 50.0,
            maxWidth: 300.0,
          ),
          child: _buildVideoPlayer(),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Use fileController if available and initialized, else use networkController
    final controller = fileController?.value.isInitialized == true ? fileController : networkController;
    return controller!.value.isInitialized
        ? AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    )
        : const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    networkController.dispose();
    fileController?.dispose();
    super.dispose();
  }
}
