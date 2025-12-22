import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import 'package:streamit_flutter/components/view_video/video_playback_handle.dart';

import '../../config.dart';
import '../../main.dart';
import '../../models/auth/check_user_session_response.dart';
import '../../network/rest_apis.dart';
import '../../utils/common.dart';
import '../../utils/constants.dart';
import '../../utils/resources/colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final int videoId;
  final String videoURL;
  final String videoThumbnailImage;
  final String watchedTime;
  final PostType videoType;
  final String videoURLType;
  final bool isTrailer;
  final bool isFromDashboard;
  final VoidCallback? onVideoEnd;
  final ValueChanged<VideoPlaybackHandle>? onPlaybackHandleReady;

  const VideoPlayerWidget({
    Key? key,
    required this.videoURL,
    required this.watchedTime,
    required this.videoType,
    required this.videoURLType,
    required this.videoId,
    this.videoThumbnailImage = '',
    this.isTrailer = true,
    this.isFromDashboard = false,
    this.onVideoEnd,
    this.onPlaybackHandleReady,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late PodPlayerController podPlayerController;
  bool isMute = false;
  bool isFirstTime = true;
  bool _isCallbackSent = false;
  Timer? _sessionValidationTimer;
  Timer? _fullscreenStateCheckerTimer;
  bool _wasInFullScreen = false;

  void _startFullscreenStateChecker() {
    _fullscreenStateCheckerTimer?.cancel();

    _fullscreenStateCheckerTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted || !podPlayerController.isInitialised) {
        return;
      }

      final currentFullscreenState = podPlayerController.isFullScreen;

      if (_wasInFullScreen != currentFullscreenState) {
        _wasInFullScreen = currentFullscreenState;

        if (currentFullscreenState) {
          _startSessionValidationTimer();
        } else {
          _stopSessionValidationTimer();
        }
      }
    });
  }

  void _stopFullscreenStateChecker() {
    _fullscreenStateCheckerTimer?.cancel();
    _fullscreenStateCheckerTimer = null;
  }

  bool get _requiresSessionValidation => widget.videoType == PostType.MOVIE || widget.videoType == PostType.VIDEO || widget.videoType == PostType.CHANNEL || widget.videoType == PostType.EPISODE;

  void _seekToWatchedTime(int watchedSeconds) {
    if (podPlayerController.isInitialised && podPlayerController.videoPlayerValue != null && podPlayerController.videoPlayerValue!.duration.inSeconds > 0) {
      podPlayerController.videoSeekForward(Duration(seconds: watchedSeconds));
      podPlayerController.play();
      return;
    }

    bool seekCompleted = false;
    void seekListener() {
      if (seekCompleted || !mounted || !podPlayerController.isInitialised) {
        return;
      }

      final videoValue = podPlayerController.videoPlayerValue;
      if (videoValue != null && videoValue.duration.inSeconds > 0) {
        seekCompleted = true;
        podPlayerController.removeListener(seekListener);
        try {
          podPlayerController.videoSeekForward(Duration(seconds: watchedSeconds));
          podPlayerController.play();
        } catch (e) {
          log('Error seeking: $e');
        }
      }
    }

    podPlayerController.addListener(seekListener);

    // Also try after a delay as backup
    Future.delayed(Duration(milliseconds: 500), () {
      if (!seekCompleted && mounted && podPlayerController.isInitialised) {
        final videoValue = podPlayerController.videoPlayerValue;
        if (videoValue != null && videoValue.duration.inSeconds > 0) {
          seekCompleted = true;
          podPlayerController.removeListener(seekListener);
          try {
            podPlayerController.videoSeekForward(Duration(seconds: watchedSeconds));
            podPlayerController.play();
          } catch (e) {
            log('Backup seek error: $e');
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoType == PostType.CHANNEL) {
      _initializeLiveStreamPlayer();
    } else {
      _initializeRegularPlayer();
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle watchedTime changes after initialization
    if (oldWidget.watchedTime != widget.watchedTime && widget.watchedTime.isNotEmpty && !widget.isTrailer && widget.videoType != PostType.CHANNEL && podPlayerController.isInitialised) {
      try {
        int watchedSeconds = int.parse(widget.watchedTime);
        if (watchedSeconds > 0) {
          _seekToWatchedTime(watchedSeconds);
        }
      } catch (e) {
        log('Error parsing watchedTime in didUpdateWidget: $e');
      }
    }
  }

  void _videoPlayerListener() {
    if (podPlayerController.isInitialised && !_isCallbackSent) {
      final position = podPlayerController.videoPlayerValue?.position;
      final duration = podPlayerController.videoPlayerValue?.duration;
      if (position != null && duration != null && duration.inMilliseconds > 0 && position >= duration) {
        _isCallbackSent = true;
        widget.onVideoEnd?.call();
      }
    }

    // Check for fullscreen state changes
    if (_requiresSessionValidation && podPlayerController.isInitialised) {
      final currentFullscreenState = podPlayerController.isFullScreen;
      if (_wasInFullScreen != currentFullscreenState) {
        _wasInFullScreen = currentFullscreenState;

        if (currentFullscreenState) {
          _startSessionValidationTimer();
        } else {
          _stopSessionValidationTimer();
        }
      }
    }
  }

  void _initializeLiveStreamPlayer() {
    final podPlayerConfig = PodPlayerConfig(
      autoPlay: widget.watchedTime.isEmpty,
      wakelockEnabled: true,
      isLooping: false,
      forcedVideoFocus: true,
    );

    final headers = <String, String>{
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Origin': mDomainUrl,
      'Referer': mDomainUrl,
      'Connection': 'keep-alive',
    };

    podPlayerController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        widget.videoURL,
        httpHeaders: headers,
      ),
      podPlayerConfig: podPlayerConfig,
    );

    _initializePlayerWithErrorHandling();
  }

  void _initializeRegularPlayer() {
    podPlayerController = PodPlayerController(
      playVideoFrom: widget.videoURL.getPlatformVideo(),
      podPlayerConfig: PodPlayerConfig(
        autoPlay: widget.watchedTime.isEmpty,
        wakelockEnabled: true,
        isLooping: widget.isTrailer && !widget.isFromDashboard,
        forcedVideoFocus: true,
      ),
    );

    _initializePlayerWithErrorHandling();
  }

  void _notifyPlaybackHandle() {
    if (widget.onPlaybackHandleReady == null) return;
    widget.onPlaybackHandleReady!(
      VideoPlaybackHandle(
        pause: () {
          if (!mounted) return;
          if (podPlayerController.isInitialised && podPlayerController.isVideoPlaying) {
            podPlayerController.pause();
          }
        },
        resume: () {
          if (!mounted) return;
          if (podPlayerController.isInitialised && !podPlayerController.isVideoPlaying) {
            podPlayerController.play();
          }
        },
      ),
    );
  }

  Future<void> _initializePlayerWithErrorHandling() async {
    try {
      await podPlayerController.initialise();
      _notifyPlaybackHandle();

      if (widget.isTrailer) {
        podPlayerController.mute();
        isMute = true;
      }

      podPlayerController.addListener(_videoPlayerListener);

      _wasInFullScreen = podPlayerController.isFullScreen;

      if (widget.watchedTime.isNotEmpty && !widget.isTrailer && isFirstTime && widget.videoType != PostType.CHANNEL) {
        isFirstTime = false;
        try {
          int watchedSeconds = int.parse(widget.watchedTime);
          if (watchedSeconds > 0) {
            // Wait for video metadata to be loaded before seeking
            _seekToWatchedTime(watchedSeconds);
          }
        } catch (e) {
          podPlayerController.pause();
        }
      } else {
        log('VideoPlayerWidget - Skipping seek. watchedTime: ${widget.watchedTime}, isTrailer: ${widget.isTrailer}, isFirstTime: $isFirstTime, videoType: ${widget.videoType}');
      }

      if (mounted) {
        setState(() {});
      }

      if (_requiresSessionValidation) {
        _startFullscreenStateChecker();
      }
    } catch (e) {
      if (widget.videoType == PostType.CHANNEL) {
        _tryAlternativeLiveStreamInit();
      } else {
        _showErrorMessage('Failed to load video. Please try again.');
      }
    }
  }

  Future<void> _tryAlternativeLiveStreamInit() async {
    try {
      podPlayerController.dispose();
      final minimalHeaders = <String, String>{
        'User-Agent': 'ExoPlayer/2.18.1',
        'Accept': 'application/vnd.apple.mpegurl,*/*',
      };

      final newController = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(
          widget.videoURL,
          httpHeaders: minimalHeaders,
        ),
        podPlayerConfig: PodPlayerConfig(
          autoPlay: true,
          wakelockEnabled: true,
          isLooping: false,
          forcedVideoFocus: true,
        ),
      );

      setState(() {
        podPlayerController = newController;
      });

      await podPlayerController.initialise();

      if (mounted) {
        setState(() {});
      }

      // Add listener for fullscreen detection
      podPlayerController.addListener(_videoPlayerListener);
    } catch (e) {
      _showErrorMessage(language.liveStreamErrorMessage);
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> saveWatchTime() async {
    if (widget.videoType == PostType.CHANNEL) return;
    if (!podPlayerController.isInitialised) return;

    try {
      final videoPlayerValue = podPlayerController.videoPlayerValue;
      if (videoPlayerValue == null) return;

      final duration = videoPlayerValue.duration;
      final position = videoPlayerValue.position;

      if (duration.inSeconds <= 0) return;

      await saveVideoContinueWatch(
        postId: widget.videoId.validate().toInt(),
        watchedTotalTime: duration.inSeconds,
        watchedTime: position.inSeconds,
        postType: widget.videoType,
      ).then((value) {
        LiveStream().emit(RefreshHome);
      });
    } catch (e) {
      log('Error saving watch time: $e');
    }
  }

  void _startSessionValidationTimer() {
    if (!_requiresSessionValidation) {
      return;
    }

    _stopSessionValidationTimer();

    final minutes = int.tryParse(kPlaybackSessionValidationIntervalMinutes);
    if (minutes == null || minutes <= 0) {
      return;
    }

    final interval = Duration(minutes: minutes);

    _sessionValidationTimer = Timer.periodic(interval, (timer) async {
      if (!mounted) {
        _stopSessionValidationTimer();
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null) {
        return;
      }

      final isInFullScreen = appStore.hasInFullScreen;
      final controllerIsFullScreen = podPlayerController.isFullScreen;

      if (!isInFullScreen && !controllerIsFullScreen) {
        _stopSessionValidationTimer();
        return;
      }

      try {
        final CheckUserSessionResponse response = await checkUserSession();

        if (!response.isSuccess) {
          _stopSessionValidationTimer();

          // Exit fullscreen first
          if (mounted && podPlayerController.isFullScreen) {
            podPlayerController.disableFullScreen(context);
            appStore.setToFullScreen(false);
            // Wait a moment for fullscreen to exit
            await Future.delayed(Duration(milliseconds: 300));
          }

          // Stop/pause the video
          if (mounted && podPlayerController.isInitialised && podPlayerController.isVideoPlaying) {
            podPlayerController.pause();
            // Wait a moment for video to stop
            await Future.delayed(Duration(milliseconds: 200));
          }

          // Now show the dialog
          await handlePlaybackSessionFailure(context, response);
        }
      } catch (e) {
        _stopSessionValidationTimer();
      }
    });
  }

  void _stopSessionValidationTimer() {
    _sessionValidationTimer?.cancel();
    _sessionValidationTimer = null;
  }

  @override
  void dispose() {
    _stopFullscreenStateChecker();
    _stopSessionValidationTimer();
    if (appStore.isLogging && !widget.isTrailer && widget.videoType != PostType.CHANNEL) {
      // Save watch time before disposing the controller
      saveWatchTime();
    }
    if (widget.onVideoEnd != null) {
      podPlayerController.removeListener(_videoPlayerListener);
    } else {
      podPlayerController.removeListener(_videoPlayerListener);
    }
    podPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: context.scaffoldBackgroundColor,
            ),
            primaryColor: Colors.white,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: PodVideoPlayer(
                alwaysShowProgressBar: false,
                controller: podPlayerController,
                frameAspectRatio: 16 / 9,
                videoAspectRatio: 16 / 9,
                videoThumbnail: widget.videoThumbnailImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.videoThumbnailImage),
                        fit: BoxFit.cover,
                      )
                    : null,
                onVideoError: () {
                  return Container(
                    height: appStore.showPIP ? 110 : 200,
                    width: context.width(),
                    decoration: boxDecorationDefault(
                      color: context.scaffoldBackgroundColor,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 34, color: white),
                        10.height,
                        Text(
                          language.videoNotFound,
                          style: boldTextStyle(size: 16, color: white),
                        ),
                      ],
                    ),
                  );
                },
                onLoading: (context) {
                  return LoaderWidget();
                },
                podProgressBarConfig: PodProgressBarConfig(
                  circleHandlerColor: colorPrimary,
                  backgroundColor: context.scaffoldBackgroundColor,
                  playingBarColor: colorPrimary,
                  bufferedBarColor: colorPrimary,
                  circleHandlerRadius: 6,
                  height: 2.6,
                  alwaysVisibleCircleHandler: false,
                  padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                ),
                onToggleFullScreen: (isFullScreen) async {
                  _wasInFullScreen = isFullScreen;

                  if (isFullScreen && _requiresSessionValidation) {
                    final allowed = await ensureUserPlaybackAllowed(context);
                    if (!mounted || !allowed) {
                      appStore.setToFullScreen(false);
                      _wasInFullScreen = false;
                      if (podPlayerController.isFullScreen) {
                        podPlayerController.disableFullScreen(context);
                      }
                      return;
                    }
                    _startSessionValidationTimer();
                  } else {
                    _stopSessionValidationTimer();
                  }

                  if (isFullScreen) {
                    setOrientationLandscape();
                  } else {
                    setOrientationPortrait();
                  }
                  appStore.setToFullScreen(isFullScreen);
                },
              ),
            ),
          ),
        ),
        if (widget.videoType == PostType.CHANNEL)
          Positioned(
            right: 0,
            top: 24,
            child: LiveTagComponent(),
          ),
        if (widget.isTrailer && widget.videoType != PostType.CHANNEL && podPlayerController.isInitialised)
          Positioned(
            right: 8,
            bottom: 8,
            child: IconButton(
              onPressed: () {
                isMute = !isMute;
                isMute ? podPlayerController.mute() : podPlayerController.unMute();
                setState(() {});
              },
              icon: Icon(
                size: 18,
                isMute ? Icons.volume_off_outlined : Icons.volume_down_rounded,
              ),
            ),
          ),
      ],
    );
  }
}
