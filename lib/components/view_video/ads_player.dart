import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_flutter/components/view_video/ad_view_player.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/components/view_video/video_playback_handle.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';

import '../../main.dart';
import '../../models/auth/check_user_session_response.dart';
import '../../models/live_tv/live_channel_detail_model.dart';
import '../../network/rest_apis.dart';
import '../../utils/constants.dart';
import '../ad_components/ad_services.dart';
import '../ad_components/html_ad_widget.dart';
import 'custom_pod_player_overlays.dart';

class AdVideoPlayerWidget extends StatefulWidget {
  final String streamUrl;
  final AdConfiguration? adConfig;
  final String title;
  final VideoPlayerConfig playerConfig;
  final AdEventCallback? onAdEvent;
  final bool isLive;
  final PostType postType;
  final int? videoId;
  final String watchedTime;
  final ValueChanged<VideoPlaybackHandle>? onPlaybackHandleReady;

  const AdVideoPlayerWidget(
      {Key? key,
      required this.streamUrl,
      this.adConfig,
      required this.title,
      this.playerConfig = const VideoPlayerConfig(),
      this.onAdEvent,
      this.isLive = false,
      required this.postType,
      this.videoId,
      this.watchedTime = '',
      this.onPlaybackHandleReady})
      : super(key: key);

  @override
  State<AdVideoPlayerWidget> createState() => _AdVideoPlayerWidgetState();
}

class _AdVideoPlayerWidgetState extends State<AdVideoPlayerWidget> with VideoPlayerLifecycleMixin {
  late final PodPlayerController _streamController;
  List<Widget> overlayWidgets = [];

  PodPlayerController? _adController;
  bool _hasStreamController = false;

  late final AdStateNotifier _adStateNotifier;

  late final TimerService _timerService;

  bool _isFullscreen = false;

  bool _midRollTimerStarted = false;

  bool _postRollAdShown = false;

  bool _isVideoAdPlaying = false;

  bool _adsOnlyMode = false;

  bool _adsCompleted = false;

  Timer? _sessionValidationTimer;
  Timer? _fullscreenStateCheckerTimer;
  bool _hasSeekedToWatchedTime = false;

  bool get _requiresSessionValidation => widget.postType == PostType.MOVIE || widget.postType == PostType.VIDEO || widget.postType == PostType.CHANNEL || widget.postType == PostType.EPISODE;

  void _seekToWatchedTime() {
    if (_hasSeekedToWatchedTime || widget.watchedTime.isEmpty || widget.isLive) {
      return;
    }

    try {
      int watchedSeconds = int.parse(widget.watchedTime);
      if (watchedSeconds > 0 && _streamController.isInitialised) {
        if (_streamController.videoPlayerValue != null && _streamController.videoPlayerValue!.duration.inSeconds > 0) {
          _hasSeekedToWatchedTime = true;
          _streamController.videoSeekForward(Duration(seconds: watchedSeconds));
          _streamController.play();
        } else {
          int retries = 0;
          Timer? seekTimer;
          void trySeek() {
            if (_hasSeekedToWatchedTime || !mounted || !_streamController.isInitialised) {
              seekTimer?.cancel();
              return;
            }

            final videoValue = _streamController.videoPlayerValue;
            if (videoValue != null && videoValue.duration.inSeconds > 0) {
              _hasSeekedToWatchedTime = true;
              seekTimer?.cancel();
              try {
                _streamController.videoSeekForward(Duration(seconds: watchedSeconds));
                _streamController.play();
              } catch (e) {
                log('AdVideoPlayerWidget - Error seeking: $e');
              }
            } else {
              retries++;
              if (retries < 20) {
                seekTimer = Timer(Duration(milliseconds: 100), trySeek);
              } else {
                log('AdVideoPlayerWidget - Failed to seek after retries');
                seekTimer?.cancel();
              }
            }
          }

          Future.delayed(Duration(milliseconds: 100), trySeek);
        }
      }
    } catch (e) {
      log('AdVideoPlayerWidget - Error parsing watchedTime: $e');
    }
  }

  //endregion

//region Init
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _adsOnlyMode = widget.streamUrl.getURLType() == VideoType.typeYoutube;
    if (_adsOnlyMode) {
      _startAdsOnlyFlow();
    } else {
      _initializeStreamPlayer();
    }
  }

  void _initializeServices() {
    _adStateNotifier = AdStateNotifier();
    _timerService = TimerService();
    _adStateNotifier.addListener(_onAdStateChanged);
  }

  void _initializeStreamPlayer() {
    PerformanceMonitor.startTimer('stream_controller_init');

    _streamController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(widget.streamUrl),
      podPlayerConfig: PodPlayerConfig(
        autoPlay: false,
        isLooping: false,
      ),
    );
    _hasStreamController = true;

    registerController(_streamController);

      _streamController.initialise().then((_) {
      PerformanceMonitor.endTimer('stream_controller_init');
      if (mounted) {
        setState(() {});
        _playPreRollAdIfNeeded();
      }

      _streamController.addListener(_onStreamPlayerStateChanged);

      _isFullscreen = _streamController.isFullScreen;

        if (_requiresSessionValidation) {
        _startFullscreenStateChecker();
      }
        _notifyPlaybackHandle();
    }).catchError((error) {
      ErrorHandler.handlePlayerError(error, 'stream_controller_init');
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AdVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool sourceChanged = oldWidget.streamUrl != widget.streamUrl || oldWidget.postType != widget.postType || oldWidget.videoId != widget.videoId;
    if (!sourceChanged) return;

    // Clean up current controllers and timers
    _stopFullscreenStateChecker();
    _stopSessionValidationTimer();
    _disposeAdController();
    try {
      if (_hasStreamController) _streamController.dispose();
    } catch (e) {
      log('AdVideoPlayerWidget - Error disposing stream controller: $e');
    }

    // Reset state flags
    _hasStreamController = false;
    _adsCompleted = false;
    _midRollTimerStarted = false;
    _postRollAdShown = false;
    _isVideoAdPlaying = false;
    _adsOnlyMode = widget.streamUrl.getURLType() == VideoType.typeYoutube;
    _hasSeekedToWatchedTime = false;
    overlayWidgets.clear();

    // Reinitialize for new source
    if (_adsOnlyMode) {
      _startAdsOnlyFlow();
    } else {
      _initializeStreamPlayer();
    }
  }

  Future<void> _startAdsOnlyFlow() async {
    try {
      if (widget.adConfig?.adsType == AdTypeConst.vast) {
        final vastUrl = widget.adConfig?.vastUrl;
        if (vastUrl.validate().isNotEmpty) {
          final vastAdUrl = await AdService.parseVastAd(vastUrl!);
          if (vastAdUrl.validate().isNotEmpty) {
            await _playVastVideoAd(vastAdUrl!);
            return;
          }
        }
        setState(() {
          _adsCompleted = true;
        });
        return;
      }

      final preAds = widget.adConfig?.preRollAdsList ?? [];
      if (preAds.isNotEmpty) {
        await _playVideoAd(preAds.first, AdType.preRoll);
        return;
      }

      setState(() {
        _adsCompleted = true;
      });
    } catch (error) {
      ErrorHandler.handleAdError(error, null, widget.onAdEvent);
      setState(() {
        _adsCompleted = true;
      });
    }
  }

  //endregion

  Future<void> _initializeAdController(String videoUrl) async {
    try {
      PerformanceMonitor.startTimer('ad_controller_init');
      _adController = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(videoUrl),
        podPlayerConfig: PodPlayerConfig(autoPlay: true, isLooping: false),
      );
      registerController(_adController!);
      await _adController!.initialise();
      PerformanceMonitor.endTimer('ad_controller_init');
      Future.delayed(VideoPlayerConstants.adCheckInterval, () {
        if (mounted && _adController != null) {
          _adController!.play();
          _addAdControllerListener();
        }
      });
      _notifyPlaybackHandle();
    } catch (error) {
      ErrorHandler.handleAdError(error, _adStateNotifier.currentAd, widget.onAdEvent);
    }
  }
  void _notifyPlaybackHandle() {
    if (widget.onPlaybackHandleReady == null) return;
    widget.onPlaybackHandleReady!(
      VideoPlaybackHandle(
        pause: () {
          if (_streamController.isInitialised && _streamController.isVideoPlaying) {
            _streamController.pause();
          }
          if (_adController?.isInitialised == true && _adController!.isVideoPlaying) {
            _adController?.pause();
          }
        },
        resume: () {
          if (_streamController.isInitialised && !_streamController.isVideoPlaying) {
            _streamController.play();
          }
        },
      ),
    );
  }

//endregion

//region Ad State Change Handlers
  void _onAdStateChanged() {
    if (mounted) {
      setState(() {
        overlayWidgets.clear();
      });
    }
  }

  void _onStreamPlayerStateChanged() {
    try {
      if (_adsOnlyMode) return;
      final currentFullscreenState = _streamController.isFullScreen;

      if (_isFullscreen != currentFullscreenState) {
        setState(() {
          _isFullscreen = currentFullscreenState;
        });

        // Start/stop session validation timer based on fullscreen state
        if (currentFullscreenState) {
          _startSessionValidationTimer();
        } else {
          _stopSessionValidationTimer();
        }
      }

      // Seek to watchedTime when video starts playing (after ads if any)
      if (_streamController.isInitialised && _streamController.isVideoPlaying && !_hasSeekedToWatchedTime && !_isVideoAdPlaying && widget.watchedTime.isNotEmpty && !widget.isLive) {
        _seekToWatchedTime();
      }

      if (_streamController.isInitialised && _streamController.isVideoPlaying) {
        _startMidRollTimerIfNeeded();
      }

      /// Post-roll ad logic: show when last 10 seconds remain

      if (_streamController.isInitialised && !_postRollAdShown) {
        final position = _streamController.currentVideoPosition;

        final duration = _streamController.totalVideoLength;

        final remaining = duration - position;

        if (duration.inSeconds > 0 && remaining.inSeconds <= 10) {
          _postRollAdShown = true;

          _playPostRollAdIfNeeded();
        }
      } else if (_streamController.isInitialised) {}
    } catch (error) {
      ErrorHandler.handlePlayerError(error, 'stream_player_state_change');
    }
  }

  void _resetAdState() {
    _timerService.cancelAllTimers();
    _adStateNotifier.reset();
    _midRollTimerStarted = false;
  }

//endregion

//region Ad Playback Logic

  Future<void> _playVastVideoAd(String videoUrl) async {
    final vastAd = AdUnit(type: AdTypeConst.vast, videoUrl: videoUrl, skipEnabled: false);
    _startVideoAd(vastAd);
    await _initializeAdController(videoUrl);
  }

  Future<void> _handleVastAd() async {
    final vastUrl = widget.adConfig?.vastUrl;
    if (vastUrl.validate().isNotEmpty) {
      PerformanceMonitor.startTimer('vast_parsing');
      final vastAdUrl = await AdService.parseVastAd(vastUrl!);
      PerformanceMonitor.endTimer('vast_parsing');

      if (vastAdUrl != null) {
        await _playVastVideoAd(vastAdUrl);
        return;
      } else {}
    }
    _streamController.play();
    Future.delayed(const Duration(seconds: 3), _startMidRollTimerIfNeeded);
  }

  Future<void> _playVideoAd(AdUnit ad, AdType adType) async {
    _startVideoAd(ad);
    if (ad.videoUrl.validate().isNotEmpty) {
      await _initializeAdController(ad.videoUrl.validate());
    }
  }

  void _startVideoAd(AdUnit ad) {
    _adStateNotifier.startAd(ad);
    _notifyAdEvent(AdEventType.adStarted, ad);
    if (ad.canBeSkipped) {
      _startSkipTimer(ad);
    }
  }

  Future<void> _playPreRollAdIfNeeded() async {
    try {
      if (widget.adConfig?.adsType == AdTypeConst.vast) {
        await _handleVastAd();
        return;
      }

      final preAds = widget.adConfig?.preRollAdsList ?? [];
      if (preAds.isNotEmpty) {
        _streamController.pause();
        await _playVideoAd(preAds.first, AdType.preRoll);
      } else {
        _streamController.play();
        // Seek to watchedTime if no pre-roll ads
        if (widget.watchedTime.isNotEmpty && !widget.isLive) {
          Future.delayed(Duration(milliseconds: 500), () {
            _seekToWatchedTime();
          });
        }
        Future.delayed(const Duration(seconds: 3), _startMidRollTimerIfNeeded);
      }
    } catch (error) {
      ErrorHandler.handleAdError(error, null, widget.onAdEvent);
      _streamController.play();
    }
  }

  Future<void> _playMidRollAd(AdUnit ad) async {
    _adStateNotifier.setCurrentAd(ad);
    try {
      if (ad.isVideoAd) {
        _streamController.pause();
        _isVideoAdPlaying = true;
        await _playVideoAd(ad, AdType.midRoll);
      } else if (ad.isHtmlAd) {
        _handleHtmlAd(ad);
      } else {
        _streamController.play();
      }
    } catch (error) {
      ErrorHandler.handleAdError(error, ad, widget.onAdEvent);
      _streamController.play();
    }
  }

  void _startMidRollTimerIfNeeded() {
    if (_midRollTimerStarted) {
      return;
    }
    if (!AdService.shouldPlayMidRollAds(widget.adConfig)) {
      return;
    }
    final interval = widget.adConfig?.midRollInterval;
    _timerService.startMidRollTimer(interval!, _handleMidRollTick);
    _midRollTimerStarted = true;
  }

  void _handleMidRollTick() {
    final midRollAds = widget.adConfig?.midRollAdsList ?? [];
    if (_isVideoAdPlaying) {
      return;
    }

    if (_adStateNotifier.midRollIndex < midRollAds.length) {
      final ad = midRollAds[_adStateNotifier.midRollIndex];

      _playMidRollAd(ad);

      _adStateNotifier.incrementMidRollIndex();
    } else {
      if (_adController?.isVideoPlaying == false) {
        _timerService.cancelAllTimers();
      }
    }
  }

  Future<void> _playPostRollAdIfNeeded() async {
    final postAds = widget.adConfig?.postRollAdsList ?? [];

    if (widget.adConfig?.postRollAdsList != null) {}

    if (widget.adConfig?.postRollDisplay == true && postAds.isNotEmpty) {
      final ad = postAds.first;
      _adStateNotifier.setCurrentAd(ad);

      try {
        if (ad.isVideoAd) {
          _streamController.pause();
          await _playVideoAd(ad, AdType.postRoll);
        } else if (ad.isHtmlAd) {
          _handleHtmlAd(ad);
        } else {
          _streamController.play();
        }
      } catch (error) {
        ErrorHandler.handleAdError(error, ad, widget.onAdEvent);
        _streamController.play();
      }
    } else {}
  }

  Future<void> _finishVideoAd() async {
    _notifyAdEvent(AdEventType.adFinished, _adStateNotifier.currentAd);
    _disposeAdController();
    _resetAdState();
    _isVideoAdPlaying = false;
    if (_adsOnlyMode) {
      if (mounted) {
        setState(() {
          _adsCompleted = true;
        });
      }
      return;
    }
    if (_isFullscreen && !_streamController.isFullScreen) {
      _streamController.enableFullScreen();
    }
    _streamController.play();
    // Seek to watchedTime after pre-roll ad finishes
    if (widget.watchedTime.isNotEmpty && !widget.isLive) {
      Future.delayed(Duration(milliseconds: 500), () {
        _seekToWatchedTime();
      });
    }
  }

  bool _shouldShowAdPlayer() {
    return _adStateNotifier.isAdPlaying && _adController != null && _adStateNotifier.currentAd?.isVideoAd == true;
  }

//endregion

//region HTML Ad Handling

  void _handleHtmlAd(AdUnit ad) {
    if (ad.isOverlayAd) {
      _showHtmlOverlayAd(ad);
    } else {
      _showHtmlCompanionAd(ad);
    }
  }

  void _startHtmlAd(AdUnit ad) {
    _adStateNotifier.startAd(ad);
    _notifyAdEvent(AdEventType.adStarted, ad);
    if (ad.canBeSkipped) {
      _startSkipTimer(ad);
    }
  }

  void _showHtmlOverlayAd(AdUnit ad) {
    _startHtmlAd(ad);
  }

  void _showHtmlCompanionAd(AdUnit ad) {
    _startHtmlAd(ad);
    _streamController.play();
  }

  void _finishHtmlAd() {
    if (!_adStateNotifier.isAdPlaying) {
      return;
    }

    _notifyAdEvent(AdEventType.adFinished, _adStateNotifier.currentAd);
    _resetAdState();

    overlayWidgets.clear();

    if (_adStateNotifier.currentAd?.isOverlayAd == true) {
      if (!_streamController.isVideoPlaying) {
        _streamController.play();
      }
    }
  }

//endregion

//region Ad Skip Logic

  void _startSkipTimer(AdUnit ad) {
    if (!ad.canBeSkipped) return;

    final skipDuration = ad.skipDurationAsDuration;
    _adStateNotifier.startSkipCountdown(ad.skipDurationInSeconds);
    _timerService.startSkipTimer(skipDuration.inSeconds, _handleSkipTick);
  }

  void _handleSkipTick() {
    if (_adStateNotifier.adSkipCountdown <= 0) {
      _adStateNotifier.enableSkip();
    } else {
      _adStateNotifier.decrementSkipCountdown();
    }
  }

  void skipAd() {
    if (!_adStateNotifier.isSkippable) return;
    _notifyAdEvent(AdEventType.adSkipped, _adStateNotifier.currentAd);
    final currentAd = _adStateNotifier.currentAd;
    if (currentAd?.isVideoAd == true) {
      _disposeAdController();
      _finishVideoAd();
    } else {
      _finishHtmlAd();
    }
  }

//endregion

//region Ad Helper Methods
  List<Duration> _getAllAdBreaks() {
    if (_adsOnlyMode) return const [];
    return AdService.calculateAdBreaks(widget.adConfig, _streamController.totalVideoLength);
  }

  void _addAdControllerListener() {
    _adController!.addListener(() async {
      if (_isAdNearCompletion()) {
        await _finishVideoAd();
      }
    });
  }

  void _notifyAdEvent(AdEventType type, AdUnit? ad) {
    widget.onAdEvent?.call(type, ad);
  }

  bool _isAdNearCompletion() {
    if (_adController == null) return false;
    final position = _adController!.currentVideoPosition;
    final duration = _adController!.totalVideoLength;
    return position.isNearTo(duration, threshold: Duration(seconds: VideoPlayerConstants.adCompletionThreshold));
  }

//endregion

//region Session Validation Timer
  void _startFullscreenStateChecker() {
    _fullscreenStateCheckerTimer?.cancel();

    // Check every 2 seconds for fullscreen state changes
    _fullscreenStateCheckerTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted || !_streamController.isInitialised) {
        return;
      }

      final currentFullscreenState = _streamController.isFullScreen;

      if (_isFullscreen != currentFullscreenState) {
        _isFullscreen = currentFullscreenState;

        if (currentFullscreenState) {
          // Entered fullscreen
          _startSessionValidationTimer();
        } else {
          // Exited fullscreen
          _stopSessionValidationTimer();
        }
      }
    });
  }

  void _stopFullscreenStateChecker() {
    _fullscreenStateCheckerTimer?.cancel();
    _fullscreenStateCheckerTimer = null;
  }

  void _startSessionValidationTimer() {
    if (!_requiresSessionValidation) {
      return;
    }

    _stopSessionValidationTimer();

    // Get interval from constant (currently 1 minute for testing)
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

      // Use navigatorKey to get context since we're in fullscreen
      final context = navigatorKey.currentContext;
      if (context == null) {
        return;
      }

      // Check if still in fullscreen
      final isInFullScreen = appStore.hasInFullScreen;
      final controllerIsFullScreen = _streamController.isFullScreen;

      if (!isInFullScreen && !controllerIsFullScreen) {
        _stopSessionValidationTimer();
        return;
      }

      // Validate session - call API directly to bypass cache
      try {
        final CheckUserSessionResponse response = await checkUserSession();

        if (!response.isSuccess) {
          _stopSessionValidationTimer();

          // Exit fullscreen first
          if (mounted && _streamController.isFullScreen) {
            _streamController.disableFullScreen(context);
            appStore.setToFullScreen(false);
            // Wait a moment for fullscreen to exit
            await Future.delayed(Duration(milliseconds: 300));
          }

          // Stop/pause the video
          if (mounted && _streamController.isInitialised && _streamController.isVideoPlaying) {
            _streamController.pause();
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

  Future<void> saveWatchTime() async {
    if (widget.videoId == null) return;
    if (widget.postType == PostType.CHANNEL) return;
    if (widget.isLive) return;
    if (!_streamController.isInitialised) return;

    try {
      final videoPlayerValue = _streamController.videoPlayerValue;
      if (videoPlayerValue == null) return;

      final duration = videoPlayerValue.duration;
      final position = videoPlayerValue.position;

      if (duration.inSeconds <= 0) return;

      await saveVideoContinueWatch(
        postId: widget.videoId!,
        watchedTotalTime: duration.inSeconds,
        watchedTime: position.inSeconds,
        postType: widget.postType,
      ).then((value) {
        LiveStream().emit(RefreshHome);
      });
    } catch (e) {
      log('Error saving watch time: $e');
    }
  }

//endregion

//region Dispose
  void _disposeAdController() {
    _adController?.dispose();
    _adController = null;
  }

  @override
  void dispose() {
    _stopFullscreenStateChecker();
    _stopSessionValidationTimer();
    if (appStore.isLogging && widget.videoId != null) {
      // Save watch time before disposing
      saveWatchTime();
    }
    _adStateNotifier.removeListener(_onAdStateChanged);
    _adStateNotifier.dispose();
    _timerService.dispose();
    super.dispose();
  }

//endregion

//region Overlay Widgets

  Widget _buildOverlay(BuildContext context) {
    final videoValue = _streamController.videoPlayerValue;
    final position = videoValue?.position ?? Duration.zero;
    final duration = videoValue?.duration ?? const Duration(seconds: 1);
    final allAdBreaks = _getAllAdBreaks();

    overlayWidgets.clear();

    final overlayAd = _buildOverlayAd();
    final companionAd = _buildCompanionAd();
    if (overlayAd != null) overlayWidgets.add(overlayAd);
    if (companionAd != null) overlayWidgets.add(companionAd);
    if (_shouldShowAdPlayer() && context.orientation == Orientation.landscape) {
      return _buildAdView();
    }

    return CustomPodPlayerControlOverlay(
      position: position,
      duration: duration,
      adBreaks: allAdBreaks,
      isPlaying: _streamController.isVideoPlaying,
      overlayAd: Stack(children: overlayWidgets),
      onFullscreenToggle: () {
        if (_streamController.isFullScreen) {
          _streamController.disableFullScreen(context);
          _stopSessionValidationTimer();
          return;
        }

        if (_requiresSessionValidation) {
          ensureUserPlaybackAllowed(context).then((allowed) {
            if (!mounted || !allowed) return;
            _streamController.enableFullScreen();
            _startSessionValidationTimer();
          });
        } else {
          _streamController.enableFullScreen();
        }
      },
      onPlayPause: () {
        _streamController.isVideoPlaying ? _streamController.pause() : _streamController.play();
      },
      onSeek: widget.isLive ? (duration) {} : (duration) => _streamController.videoSeekTo(duration),
      onReplay10: widget.isLive
          ? null
          : () {
              final newPosition = Duration(seconds: (position.inSeconds - 10).clamp(0, duration.inSeconds));
              _streamController.videoSeekTo(newPosition);
            },
      onForward10: widget.isLive
          ? null
          : () {
              final newPosition = Duration(seconds: (position.inSeconds + 10).clamp(0, duration.inSeconds));
              _streamController.videoSeekTo(newPosition);
            },
      isLive: widget.isLive,
    );
  }

  Widget _buildAdView() {
    return AdViewPlayer(
      adState: _adStateNotifier,
      isFullscreen: _isFullscreen,
      adController: _adController,
      onSkip: skipAd,
    );
  }

  Widget? _buildOverlayAd() {
    final ad = _adStateNotifier.currentAd;

    if (_adStateNotifier.isAdPlaying && ad != null && ad.isOverlayAd) {
      final content = ad.content ?? '';
      if (content.trim().isEmpty) return null;

      return OverlayAd(
        content: content,
        isFullscreen: _isFullscreen,
        skipDuration: ad.skipDuration,
        onTimerComplete: () {
          _finishHtmlAd();
        },
      );
    }
    return null;
  }

  Widget? _buildCompanionAd() {
    final ad = _adStateNotifier.currentAd;

    if (_adStateNotifier.isAdPlaying && ad != null && ad.isCompanionAd) {
      final content = ad.content ?? '';
      if (content.trim().isEmpty) return null;

      return CompanionAd(
        content: content,
        isFullscreen: _isFullscreen,
        skipDuration: ad.skipDuration,
        onTimerComplete: () {
          _finishHtmlAd();
        },
      );
    }
    return null;
  }

//endregion

  @override
  Widget build(BuildContext context) {
    if (_adsOnlyMode) {
      if (_shouldShowAdPlayer() && !_adsCompleted) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: _buildAdView(),
        );
      }

      return VideoWidget(
        videoURL: widget.streamUrl,
        watchedTime: '',
        videoType: widget.postType,
        videoURLType: widget.streamUrl.getURLType(),
        videoId: 0,
        thumbnailImage: '',
        isTrailer: true,
        onPlaybackHandleReady: widget.onPlaybackHandleReady,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          KeyedSubtree(
            key: const ValueKey('stream'),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _shouldShowAdPlayer() ? 0.0 : 1.0,
              child: PodVideoPlayer(
                controller: _streamController,
                alwaysShowProgressBar: false,
                overlayBuilder: (options) => _buildOverlay(context),
              ),
            ),
          ),
          if (_shouldShowAdPlayer())
            Positioned.fill(
              child: _buildAdView(),
            ),
        ],
      ),
    );
  }
}
