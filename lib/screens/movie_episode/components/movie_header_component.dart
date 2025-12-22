import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/view_video/ads_player.dart';
import 'package:streamit_flutter/components/view_video/video_content_widget.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/components/view_video/video_playback_handle.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/utils/constants.dart';

class MovieDetailHeaderComponent extends StatefulWidget {
  final MovieData movie;
  final bool? userHasAccess;
  final String? watchedTime;
  final VoidCallback? onPlayTrailer;
  final VoidCallback? onStreamShow;
  final MovieData? selectedEpisode;

  const MovieDetailHeaderComponent({
    Key? key,
    required this.movie,
    this.userHasAccess,
    this.watchedTime,
    this.onPlayTrailer,
    this.onStreamShow,
    this.selectedEpisode,
  }) : super(key: key);

  @override
  State<MovieDetailHeaderComponent> createState() => MovieDetailHeaderComponentState();
}

class MovieDetailHeaderComponentState extends State<MovieDetailHeaderComponent> {
  Timer? _trailerSequenceTimer;
  bool _showVideo = false;
  bool _trailerHasPlayed = false;
  VideoPlaybackHandle? _playbackHandle;
  bool get _isUpcoming => widget.movie.isUpcoming.validate();

  @override
  void initState() {
    super.initState();
    // Skip trailer sequence for PostType.VIDEO since videos don't have trailers
    if (widget.movie.postType != PostType.VIDEO && 
        widget.movie.trailerLink.validate().isNotEmpty && 
        !_trailerHasPlayed) {
      _startTrailerSequence();
    }
  }

  void _startTrailerSequence() {
    _trailerSequenceTimer?.cancel();
    _showVideo = false;
    _trailerSequenceTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_trailerHasPlayed) {
        setState(() {
          _showVideo = true;
        });
      }
    });
  }

  void pauseVideo() {
    _playbackHandle?.pause();
    _trailerSequenceTimer?.cancel();
    if (mounted) {
      setState(() {
        _showVideo = false;
      });
    }
  }

  void _registerPlaybackHandle(VideoPlaybackHandle handle) {
    _playbackHandle = handle;
  }

  String get _movieChoice => widget.movie.choice.validate();

  String _movieChoiceUrl() {
    if (_movieChoice == movieChoiceURL ||
        _movieChoice == videoChoiceURL ||
        _movieChoice == movieChoiceLiveStream ||
        _movieChoice == videoChoiceLiveStream) {
      return widget.movie.urlLink.validate().replaceAll(r'\/', '/');
    }
    return '';
  }

  String _movieChoiceFile() {
    if (_movieChoice == movieChoiceFile || _movieChoice == videoChoiceFile) {
      return widget.movie.file.validate();
    }
    return '';
  }

  String _movieChoiceEmbed() {
    if (_movieChoice == movieChoiceEmbed || _movieChoice == videoChoiceEmbed) {
      return widget.movie.embedContent.validate();
    }
    return '';
  }

  String _getMovieStreamUrl() {
    final String url = _movieChoiceUrl();
    if (url.isNotEmpty) return url;
    return _movieChoiceFile();
  }

  bool get _hasMovieStreamSource =>
      _movieChoiceUrl().isNotEmpty || _movieChoiceFile().isNotEmpty || _movieChoiceEmbed().isNotEmpty;

  /// Check if content requires rent/subscription and user doesn't have access
  bool get _requiresPurchaseAndNoAccess {
    final hasAccess = widget.userHasAccess ?? widget.movie.userHasAccess.validate();
    if (hasAccess) return false;

    // Check if content requires rent
    final requiresRent = widget.movie.isRent == true && coreStore.isMembershipEnabled;
    
    // Check if content requires subscription
    final requiresSubscription = widget.movie.requiredPlan.validate().isNotEmpty && 
        widget.movie.requiredPlan.toString() != appStore.subscriptionPlanId &&
        coreStore.isMembershipEnabled;

    return requiresRent || requiresSubscription;
  }

  Widget _buildTrailerThumbnailSequence() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.movie.image.validate().isEmpty ? appStore.sliderDefaultImage.validate() : widget.movie.image.validate(),
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => CachedImageWidget(url: appStore.sliderDefaultImage.validate(), fit: BoxFit.cover),
        ),

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              stops: [0.0, 0.6],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.black.withAlpha(204), Colors.transparent],
              center: Alignment.bottomLeft,
              radius: 1.2,
              stops: const [0.0, 0.9],
            ),
          ),
        ),

        if (_showVideo && !_trailerHasPlayed && widget.movie.trailerLink.validate().isNotEmpty)
          VideoWidget(
            videoURL: widget.movie.trailerLink.validate(),
            watchedTime: '',
            videoType: widget.movie.postType ?? PostType.MOVIE,
            videoURLType: widget.movie.trailerLinkType.validate(),
            videoId: widget.movie.id.validate(),
            thumbnailImage: widget.movie.image.validate().isEmpty ? appStore.sliderDefaultImage.validate() : widget.movie.image.validate(),
            isTrailer: true,
            isSlider: true,
            onTap: widget.onPlayTrailer,
            onVideoEnd: () {
              if (mounted) {
                setState(() {
                  _showVideo = false;
                  _trailerHasPlayed = true;
                });
                _trailerSequenceTimer?.cancel();
              }
            },
            onPlaybackHandleReady: _registerPlaybackHandle,
          ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return Observer(
      builder: (context) {
        // If content requires purchase, user doesn't have access, or movie is upcoming, only show trailer/thumbnail
        if (_requiresPurchaseAndNoAccess || _isUpcoming) {
          if (appStore.isTrailerVideoPlaying && widget.movie.trailerLink.validate().isNotEmpty) {
            return VideoWidget(
              thumbnailImage: widget.movie.image.validate(),
              videoURL: widget.movie.trailerLink.validate(),
              videoURLType: widget.movie.trailerLinkType.validate(),
              videoType: widget.movie.postType ?? PostType.MOVIE,
              videoId: widget.movie.id.validate(),
              isTrailer: true,
              watchedTime: '',
              onTap: widget.onPlayTrailer,
              onPlaybackHandleReady: _registerPlaybackHandle,
            );
          }
          return _buildTrailerThumbnailSequence();
        }

        if (widget.movie.postType == PostType.VIDEO) {
          if (!appStore.isTrailerVideoPlaying && _hasMovieStreamSource) {
            if (widget.movie.adConfiguration != null && _getMovieStreamUrl().isNotEmpty) {
              return AdVideoPlayerWidget(
                streamUrl: _getMovieStreamUrl(),
                adConfig: widget.movie.adConfiguration,
                title: widget.movie.title.validate(),
                isLive: false,
                postType: widget.movie.postType ?? PostType.VIDEO,
                videoId: widget.movie.id.validate().toInt(),
                watchedTime: widget.watchedTime ?? '',
                onPlaybackHandleReady: _registerPlaybackHandle,
              );
            } else {
              return VideoContentWidget(
                choice: _movieChoice,
                image: widget.movie.image.validate(),
                urlLink: _movieChoiceUrl(),
                embedContent: _movieChoiceEmbed(),
                fileLink: _movieChoiceFile(),
                videoId: widget.movie.id.validate().toString(),
                watchedTime: widget.watchedTime ?? '',
                title: widget.movie.title.validate(),
                postType: widget.movie.postType ?? PostType.VIDEO,
                onPlaybackHandleReady: _registerPlaybackHandle,
              );
            }
          }
          // Always show thumbnail for PostType.VIDEO initially
          return _buildTrailerThumbnailSequence();
        }

        // For other post types (MOVIE, etc.), handle trailers and video content normally
        if (appStore.isTrailerVideoPlaying && widget.movie.trailerLink.validate().isNotEmpty) {
          return VideoWidget(
            thumbnailImage: widget.movie.image.validate(),
            videoURL: widget.movie.trailerLink.validate(),
            videoURLType: widget.movie.trailerLinkType.validate(),
            videoType: widget.movie.postType ?? PostType.MOVIE,
            videoId: widget.movie.id.validate(),
            isTrailer: true,
            watchedTime: '',
            onTap: widget.onPlayTrailer,
            onPlaybackHandleReady: _registerPlaybackHandle,
          );
        }

        if (_hasMovieStreamSource) {
          if (widget.movie.adConfiguration != null && _getMovieStreamUrl().isNotEmpty) {
            return AdVideoPlayerWidget(
              streamUrl: _getMovieStreamUrl(),
              adConfig: widget.movie.adConfiguration,
              title: widget.movie.title.validate(),
              isLive: false,
              postType: widget.movie.postType ?? PostType.MOVIE,
              videoId: widget.movie.id.validate().toInt(),
              watchedTime: widget.watchedTime ?? '',
              onPlaybackHandleReady: _registerPlaybackHandle,
            );
          } else {
            return VideoContentWidget(
              choice: _movieChoice,
              image: widget.movie.image.validate(),
              urlLink: _movieChoiceUrl(),
              embedContent: _movieChoiceEmbed(),
              fileLink: _movieChoiceFile(),
              videoId: widget.movie.id.validate().toString(),
              watchedTime: widget.watchedTime ?? '',
              title: widget.movie.title.validate(),
              postType: widget.movie.postType ?? PostType.MOVIE,
              onPlaybackHandleReady: _registerPlaybackHandle,
            );
          }
        }

        return _buildTrailerThumbnailSequence();
      },
    );
  }

  @override
  void dispose() {
    pauseVideo();
    _playbackHandle = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: !appStore.showPIP && !appStore.hasInFullScreen ? context.height() * 0.26 : context.height(),
      width: context.width(),
      child: Stack(
        children: [
          _buildVideoPlayer(),
          if (!appStore.hasInFullScreen)
            IgnorePointer(
              ignoring: true,
              child: SizedBox(height: context.height() * 0.26),
            ),
        ],
      ),
    );
  }
}
