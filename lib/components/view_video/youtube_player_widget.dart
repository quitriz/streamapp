import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import 'package:streamit_flutter/components/view_video/video_playback_handle.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../main.dart';
import '../../network/rest_apis.dart';
import '../../utils/constants.dart' hide PlayerState;
import '../../utils/resources/colors.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final int videoId;
  final String videoURL;
  final String videoThumbnailImage;
  final String watchedTime;
  final PostType videoType;
  final String videoURLType;
  final bool isTrailer;
  final isSlider;
  final VoidCallback? onTap;
  final VoidCallback? onVideoEnd;
  final ValueChanged<VideoPlaybackHandle>? onPlaybackHandleReady;

  YoutubePlayerWidget({
    Key? key,
    required this.videoURL,
    required this.watchedTime,
    required this.videoType,
    required this.videoURLType,
    required this.videoId,
    this.videoThumbnailImage = '',
    this.isTrailer = true,
    this.isSlider = false,
    this.onTap,
    this.onVideoEnd,
    this.onPlaybackHandleReady,
  }) : super(key: key);

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  YoutubePlayerController? youtubePlayerController;
  bool isPlayerReady = false;
  bool isMute = false;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();

    String videoId = widget.videoURL.getYouTubeId();
    if (videoId.isNotEmpty) {
      youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.watchedTime.isEmpty,
          hideThumbnail: !widget.isTrailer,
          disableDragSeek: widget.isTrailer,
          loop: widget.isTrailer && !widget.isSlider,
          forceHD: false,
          enableCaption: true,
          mute: widget.isTrailer,
          hideControls: widget.isTrailer,
        ),
      );
      youtubePlayerController!.addListener(() {
        if (isMute) {
          youtubePlayerController!.mute();
        }
      });

      initController();
    }
  }

  @override
  void didUpdateWidget(YoutubePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Handle watchedTime changes after initialization
    if (oldWidget.watchedTime != widget.watchedTime && widget.watchedTime.isNotEmpty && !widget.isTrailer && youtubePlayerController != null) {
      try {
        int watchedSeconds = int.parse(widget.watchedTime);
        if (watchedSeconds > 0) {
          afterBuildCreated(() {
            youtubePlayerController?.seekTo(Duration(seconds: watchedSeconds));
            youtubePlayerController?.play();
          });
        }
      } catch (e) {
        log('Error seeking to watchedTime in YouTube player: $e');
      }
    }
  }

  void initController() {
    if (youtubePlayerController != null) {
      if (widget.isTrailer) {
        youtubePlayerController?.mute();
        isMute = true;
      }
      widget.onPlaybackHandleReady?.call(
        VideoPlaybackHandle(
          pause: () {
            if (!mounted) return;
            youtubePlayerController?.pause();
          },
          resume: () {
            if (!mounted) return;
            if (youtubePlayerController != null && youtubePlayerController!.value.playerState != PlayerState.playing) {
              youtubePlayerController?.play();
            }
          },
        ),
      );

      if (widget.watchedTime.isNotEmpty && !widget.isTrailer && isFirstTime) {
        isFirstTime = false;
        try {
          int watchedSeconds = int.parse(widget.watchedTime);
          if (watchedSeconds > 0) {
            afterBuildCreated(() {
              youtubePlayerController?.seekTo(Duration(seconds: watchedSeconds));
              youtubePlayerController?.play();
            });
            // Also try after a delay as backup
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted && youtubePlayerController != null) {
                youtubePlayerController?.seekTo(Duration(seconds: watchedSeconds));
                youtubePlayerController?.play();
              }
            });
          }
        } catch (e) {
          log('YoutubePlayerWidget - Error parsing watchedTime: $e');
        }
      }
    }
  }

  Future<void> saveWatchTime() async {
    if (youtubePlayerController == null) return;
    if (widget.videoType == PostType.CHANNEL) return;

    try {
      final metadata = youtubePlayerController!.metadata;
      final value = youtubePlayerController!.value;

      if (metadata.duration.inSeconds <= 0) return;

      await saveVideoContinueWatch(
        postId: widget.videoId.validate().toInt(),
        watchedTotalTime: metadata.duration.inSeconds,
        watchedTime: value.position.inSeconds,
        postType: widget.videoType,
      ).then((value) {
        LiveStream().emit(RefreshHome);
      }).catchError(onError);
    } catch (e) {
      log('Error saving watch time: $e');
    }
  }

  void toggleMute() {
    isMute = !isMute;
    isMute ? youtubePlayerController?.mute() : youtubePlayerController?.unMute();
    setState(() {});
  }

  @override
  void dispose() {
    if (youtubePlayerController != null && youtubePlayerController!.value.playerState != PlayerState.ended && !widget.isTrailer && widget.videoType != PostType.CHANNEL) {
      // Save watch time even if paused (not just when playing)
      saveWatchTime();
    }
    youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (youtubePlayerController != null)
          YoutubePlayerBuilder(
            key: widget.key,
            onEnterFullScreen: () {
              appStore.setToFullScreen(true);
            },
            onExitFullScreen: () {
              appStore.setToFullScreen(false);
            },
            player: YoutubePlayer(
              controller: youtubePlayerController!,
              liveUIColor: colorPrimary,
              progressColors: ProgressBarColors(
                playedColor: colorPrimary,
                bufferedColor: colorPrimary.withValues(alpha: 0.2),
                backgroundColor: colorPrimary.withValues(alpha: 0.2),
                handleColor: colorPrimary,
              ),
              progressIndicatorColor: colorPrimary,
              onReady: () {
                isPlayerReady = true;
              },
              onEnded: (data) {
                if (widget.onVideoEnd != null) {
                  widget.onVideoEnd!.call();
                } else if (widget.isTrailer) {
                  youtubePlayerController?.reload();
                  youtubePlayerController?.mute();
                }
              },
            ),
            builder: (context, player) {
              return player;
            },
          ),
        if (widget.isTrailer && youtubePlayerController != null && !youtubePlayerController!.value.isControlsVisible)
          Positioned(
            right: 8,
            bottom: 8,
            child: InkWell(
              onTap: toggleMute,
              child: Icon(
                size: 18,
                isMute ? Icons.volume_off_outlined : Icons.volume_up_outlined,
              ),
            ),
          ),
      ],
    );
  }
}
