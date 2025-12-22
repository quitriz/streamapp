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

class TvShowHeaderComponent extends StatefulWidget {
  final MovieData show;
  final bool? userHasAccess;
  final String? watchedTime;
  final VoidCallback? onPlayTrailer;
  final VoidCallback? onStreamShow;
  final bool isPip;

  const TvShowHeaderComponent({
    Key? key,
    required this.show,
    this.userHasAccess,
    this.watchedTime,
    this.onPlayTrailer,
    this.onStreamShow,
    this.isPip = false,
  }) : super(key: key);

  @override
  State<TvShowHeaderComponent> createState() => TvShowHeaderComponentState();
}

class TvShowHeaderComponentState extends State<TvShowHeaderComponent> {
  Timer? _trailerSequenceTimer;
  bool _showVideo = false;
  bool _trailerHasPlayed = false;
  VideoPlaybackHandle? _playbackHandle;

  bool get hasAccess => widget.userHasAccess ?? widget.show.userHasAccess.validate();
  bool get _isUpcoming => widget.show.isUpcoming.validate();

  @override
  void initState() {
    super.initState();
    if (widget.show.trailerLink.validate().isNotEmpty && !_trailerHasPlayed) {
      _startTrailerSequence();
    }
  }

  /// Pause video playback and cancel trailer sequence
  void pauseVideo() {
    _playbackHandle?.pause();
    _trailerSequenceTimer?.cancel();
    if (mounted) {
      setState(() {
        _showVideo = false;
      });
    }
    // Pause trailer video if playing
    appStore.setTrailerVideoPlayer(false);
  }

  void _registerPlaybackHandle(VideoPlaybackHandle handle) {
    _playbackHandle = handle;
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

  String get _showChoice => widget.show.choice.validate();

  String _showChoiceUrl() {
    if (_showChoice == movieChoiceURL ||
        _showChoice == videoChoiceURL ||
        _showChoice == episodeChoiceURL ||
        _showChoice == movieChoiceLiveStream ||
        _showChoice == videoChoiceLiveStream ||
        _showChoice == episodeChoiceLiveStream) {
      return widget.show.urlLink.validate().replaceAll(r'\/', '/');
    }
    return '';
  }

  String _showChoiceFile() {
    if (_showChoice == movieChoiceFile || _showChoice == videoChoiceFile || _showChoice == episodeChoiceFile) {
      return widget.show.file.validate();
    }
    return '';
  }

  String _showChoiceEmbed() {
    if (_showChoice == movieChoiceEmbed || _showChoice == videoChoiceEmbed || _showChoice == episodeChoiceEmbed) {
      return widget.show.embedContent.validate();
    }
    return '';
  }

  bool get _hasShowStreamSource => _showChoiceUrl().isNotEmpty || _showChoiceFile().isNotEmpty || _showChoiceEmbed().isNotEmpty;

  /// Check if content requires rent/subscription and user doesn't have access
  bool get _requiresPurchaseAndNoAccess {
    if (hasAccess) return false;

    // Check if content requires rent
    final requiresRent = widget.show.isRent == true && coreStore.isMembershipEnabled;

    // Check if content requires subscription
    final requiresSubscription = widget.show.requiredPlan.validate().isNotEmpty && widget.show.requiredPlan.toString() != appStore.subscriptionPlanId && coreStore.isMembershipEnabled;

    return requiresRent || requiresSubscription;
  }

  String _getStreamUrl() {
    final String url = _showChoiceUrl();
    if (url.isNotEmpty) return url;
    return _showChoiceFile();
  }

  String _episodeChoiceUrl(MovieData episode) {
    final String choice = episode.choice.validate();
    if (choice == episodeChoiceURL || choice == episodeChoiceLiveStream) {
      return episode.urlLink.validate().replaceAll(r'\/', '/');
    }
    return '';
  }

  String _episodeChoiceFile(MovieData episode) {
    final String choice = episode.choice.validate();
    if (choice == episodeChoiceFile) {
      final String episodeFile = episode.episodeFile.validate();
      if (episodeFile.isNotEmpty) return episodeFile;
      return episode.file.validate();
    }
    return '';
  }

  String _episodeChoiceEmbed(MovieData episode) {
    if (episode.choice.validate() == episodeChoiceEmbed) {
      return episode.embedContent.validate();
    }
    return '';
  }

  bool _hasEpisodeStreamSource(MovieData episode) => _episodeChoiceUrl(episode).isNotEmpty || _episodeChoiceFile(episode).isNotEmpty || _episodeChoiceEmbed(episode).isNotEmpty;

  String _episodeChoiceStreamUrl(MovieData episode) {
    final String url = _episodeChoiceUrl(episode);
    if (url.isNotEmpty) return url;
    return _episodeChoiceFile(episode);
  }

  Widget _buildTrailerThumbnailSequence() {
    return Stack(
      fit: StackFit.expand,
      children: [
        /// Background Image (always visible)
        CachedNetworkImage(
          imageUrl: widget.show.image.validate().isEmpty ? appStore.sliderDefaultImage.validate() : widget.show.image.validate(),
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => CachedImageWidget(url: appStore.sliderDefaultImage.validate(), fit: BoxFit.cover),
        ),

        /// Stacked Gradients for the exact visual effect
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

        /// Conditionally visible Video Player - plays only once
        if (_showVideo && !_trailerHasPlayed && widget.show.trailerLink.validate().isNotEmpty)
          VideoWidget(
            videoURL: widget.show.trailerLink.validate(),
            watchedTime: '',
            videoType: widget.show.postType ?? PostType.TV_SHOW,
            videoURLType: widget.show.trailerLinkType.validate(),
            videoId: widget.show.id.validate(),
            thumbnailImage: widget.show.image.validate().isEmpty ? appStore.sliderDefaultImage.validate() : widget.show.image.validate(),
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

  Widget _buildEpisodePlayer() {
    final episode = fragmentStore.selectedEpisode;
    if (episode == null) return _buildTrailerThumbnailSequence();

    if (_isUpcoming || episode.isUpcoming.validate()) {
      return _buildTrailerThumbnailSequence();
    }

    // Check if episode requires purchase and user doesn't have access
    final episodeHasAccess = episode.userHasAccess.validate();
    final episodeRequiresRent = episode.isRent == true && coreStore.isMembershipEnabled;
    final episodeRequiresSubscription = episode.requiredPlan.validate().isNotEmpty && episode.requiredPlan.toString() != appStore.subscriptionPlanId && coreStore.isMembershipEnabled;

    if (!episodeHasAccess && (episodeRequiresRent || episodeRequiresSubscription)) {
      return _buildTrailerThumbnailSequence();
    }

    final String streamUrl = _episodeChoiceStreamUrl(episode);
    if (episode.adConfiguration != null && streamUrl.isNotEmpty) {
      return AdVideoPlayerWidget(
        streamUrl: streamUrl,
        adConfig: episode.adConfiguration,
        title: episode.title.validate(),
        isLive: false,
        postType: PostType.EPISODE,
        videoId: episode.id.validate().toInt(),
        onPlaybackHandleReady: _registerPlaybackHandle,
      );
    }

    if (!_hasEpisodeStreamSource(episode)) return _buildTrailerThumbnailSequence();

    return VideoContentWidget(
      choice: episode.choice.validate(),
      image: episode.image.validate(),
      urlLink: _episodeChoiceUrl(episode),
      embedContent: _episodeChoiceEmbed(episode),
      fileLink: _episodeChoiceFile(episode),
      videoId: episode.id.validate().toString(),
      watchedTime: widget.watchedTime ?? '',
      title: episode.title.validate(),
      postType: PostType.EPISODE,
      onPlaybackHandleReady: _registerPlaybackHandle,
    );
  }

  Widget _buildVideoPlayer() {
    return Observer(
      builder: (context) {
        // If content requires purchase, user doesn't have access, or show is upcoming, only show trailer/thumbnail
        if (_requiresPurchaseAndNoAccess || _isUpcoming) {
          if (appStore.isTrailerVideoPlaying && widget.show.trailerLink.validate().isNotEmpty) {
            return VideoWidget(
              thumbnailImage: widget.show.image.validate(),
              videoURL: widget.show.trailerLink.validate(),
              videoURLType: widget.show.trailerLinkType.validate(),
              videoType: widget.show.postType ?? PostType.TV_SHOW,
              videoId: widget.show.id.validate(),
              isTrailer: true,
              watchedTime: '',
              onTap: widget.onPlayTrailer,
              onPlaybackHandleReady: _registerPlaybackHandle,
            );
          }
          return _buildTrailerThumbnailSequence();
        }

        if (fragmentStore.selectedEpisode != null && !appStore.isTrailerVideoPlaying) {
          return _buildEpisodePlayer();
        }
        if (appStore.isTrailerVideoPlaying && widget.show.trailerLink.validate().isNotEmpty) {
          return VideoWidget(
            thumbnailImage: widget.show.image.validate(),
            videoURL: widget.show.trailerLink.validate(),
            videoURLType: widget.show.trailerLinkType.validate(),
            videoType: widget.show.postType ?? PostType.TV_SHOW,
            videoId: widget.show.id.validate(),
            isTrailer: true,
            watchedTime: '',
            onTap: widget.onPlayTrailer,
            onPlaybackHandleReady: _registerPlaybackHandle,
          );
        }

        if (_hasShowStreamSource) {
          if (widget.show.adConfiguration != null && _getStreamUrl().isNotEmpty) {
            return AdVideoPlayerWidget(
              streamUrl: _getStreamUrl(),
              adConfig: widget.show.adConfiguration,
              title: widget.show.title.validate(),
              isLive: false,
              postType: widget.show.postType ?? PostType.TV_SHOW,
              videoId: widget.show.id.validate().toInt(),
              onPlaybackHandleReady: _registerPlaybackHandle,
            );
          }

          return VideoContentWidget(
            choice: _showChoice,
            image: widget.show.image.validate(),
            urlLink: _showChoiceUrl(),
            embedContent: _showChoiceEmbed(),
            fileLink: _showChoiceFile(),
            videoId: widget.show.id.validate().toString(),
            watchedTime: widget.watchedTime ?? '',
            title: widget.show.title.validate(),
            postType: widget.show.postType ?? PostType.TV_SHOW,
            onPlaybackHandleReady: _registerPlaybackHandle,
          );
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
      height: !appStore.showPIP && !appStore.hasInFullScreen && widget.isPip ? context.height() * 0.28 : context.height() * 0.28,
      width: context.width(),
      child: Stack(
        children: [
          _buildVideoPlayer(),
          if (!appStore.hasInFullScreen)
            IgnorePointer(
              ignoring: true,
              child: SizedBox(height: context.height() * 0.28),
            ),
        ],
      ),
    );
  }
}
