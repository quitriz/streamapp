import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/view_video/video_player_widget.dart';
import 'package:streamit_flutter/components/view_video/video_playback_handle.dart';
import 'package:streamit_flutter/components/view_video/webview_content_widget.dart';
import 'package:streamit_flutter/components/view_video/youtube_player_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';

class VideoWidget extends StatelessWidget {
  final String videoURL;
  final String? watchedTime;
  final PostType videoType;
  final String? videoURLType;
  final int videoId;
  final String thumbnailImage;
  final VoidCallback? onTap;
  final bool isSlider;
  final bool isTrailer;
  final String? embedContent;
  final VoidCallback? onVideoEnd;
  final ValueChanged<VideoPlaybackHandle>? onPlaybackHandleReady;

  VideoWidget({
    Key? key,
    required this.videoURL,
    this.watchedTime,
    required this.videoType,
    this.videoURLType,
    required this.videoId,
    this.onTap,
    this.isSlider = false,
    required this.thumbnailImage,
    required this.isTrailer,
    this.embedContent,
    this.onVideoEnd,
    this.onPlaybackHandleReady,
  }) : super(key: key);

  bool _isValidHttpUrl(String url) {
    final value = url.validate().trim();
    return value.startsWith('http://') || value.startsWith('https://');
  }

  bool _isValidTrailerUrl() {
    final url = videoURL.validate().trim();
    final type = videoURLType.validate().toLowerCase();

    if (url.isEmpty) return false;

    if (type == VideoType.typeYoutube) {
      return url.getYouTubeId().isNotEmpty;
    }

    if (type == VideoType.typeVimeo) {
      return url.getVimeoVideoId.validate().isNotEmpty;
    }

    if (type == VideoType.typeFile) {
      return true;
    }

    return _isValidHttpUrl(url);
  }

  bool _shouldShowThumbnail() {
    if (embedContent != null && embedContent!.isNotEmpty) return false;

    if (videoURL.validate().isEmpty || videoURLType.validate().isEmpty) return true;
    if (isTrailer && !_isValidTrailerUrl()) return true;
    return false;
  }

  String? _extractEmbedUrl(String embedContent) {
    final RegExp srcRegex = RegExp(r'src\s*=\s*["\x27]([^"\x27]+)["\x27]', caseSensitive: false);
    final match = srcRegex.firstMatch(embedContent);
    return match?.group(1);
  }

  Widget _buildErrorFallback(BuildContext context, Size cardSize) {
    return Container(
      width: cardSize.width,
      height: cardSize.height,
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  videoType == PostType.CHANNEL ? Icons.live_tv : Icons.play_circle_outline,
                  color: Colors.white54,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  language.videoUnavailableMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() {
      onTap?.call();
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("state------${state}");
    if (state == AppLifecycleState.paused && appStore.hasInFullScreen) {
      enterPiPMode();
    }
  }
  @override
  Widget build(BuildContext context) {
    var width = context.width();
    final Size cardSize = Size(width, appStore.hasInFullScreen ? context.height() : context.height() * 0.3);
    return Container(
      width: cardSize.width,
      height: cardSize.height,
      decoration: boxDecorationDefault(
        color: context.cardColor,
        boxShadow: [],
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            context.scaffoldBackgroundColor.withValues(alpha: 0.3),
          ],
          stops: [0.3, 1.0],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          tileMode: TileMode.mirror,
        ),
      ),
      child: _shouldShowThumbnail()
          ? Stack(
        children: [
          CachedImageWidget(
            url: thumbnailImage.validate(),
            width: cardSize.width,
            height: cardSize.height,
            fit: BoxFit.cover,
          ).onTap(
                () {
              onTap?.call();
            },
          ),
        ],
      )
          : _buildVideoPlayer(context, cardSize),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, Size cardSize) {
    if (embedContent != null && embedContent!.isNotEmpty) {
      return _buildEmbedPlayer(context, cardSize);
    }

    if (videoType == PostType.CHANNEL) {
      return _buildLiveStreamPlayer(context, cardSize);
    }

    return _buildRegularVideoPlayer(context, cardSize);
  }

  Widget _buildEmbedPlayer(BuildContext context, Size cardSize) {
    final embedUrl = _extractEmbedUrl(embedContent!);

    if (embedUrl == null || embedUrl.isEmpty) {
      log('Failed to extract URL from embed content: $embedContent');
      return _buildErrorFallback(context, cardSize);
    }

    log('Extracted embed URL: $embedUrl');

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        onTap?.call();
      },
      child: WebViewContentWidget(
        uri: Uri.parse(embedUrl),
        autoPlayVideo: !isTrailer,
      ),
    );
  }

  Widget _buildLiveStreamPlayer(BuildContext context, Size cardSize) {
    final url = videoURL.validate();
    if (url.isEmpty || (!url.contains('.m3u8') && !url.contains('hls') && videoURLType.validate().toLowerCase() != VideoType.typeHLS) || !_isValidHttpUrl(url)) {
      log('Invalid live stream URL or type: $videoURL, Type: $videoURLType');
      return _buildErrorFallback(context, cardSize);
    }

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        onTap?.call();
      },
      child: VideoPlayerWidget(
        key: ValueKey('live-$videoId-$videoURL'),
        videoURL: videoURL.validate(),
        watchedTime: '',
        videoType: videoType,
        videoURLType: videoURLType.validate(),
        videoId: videoId,
        videoThumbnailImage: thumbnailImage,
        isTrailer: false,
        isFromDashboard: isSlider,
        onVideoEnd: onVideoEnd,
        onPlaybackHandleReady: onPlaybackHandleReady,
      ),
    );
  }

  Widget _buildRegularVideoPlayer(BuildContext context, Size cardSize) {
    if (videoURLType.validate().toLowerCase() == VideoType.typeYoutube) {
      // For PostType.VIDEO with YouTube URLs, always show controls (isTrailer = false)
      // For PostType.MOVIE trailers, hide controls (isTrailer = true)
      final bool isTrailerForYouTube = videoType == PostType.VIDEO ? false : isTrailer;
      
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          onTap?.call();
        },
        child: YoutubePlayerWidget(
          videoURL: videoURL.validate(),
          watchedTime: watchedTime.validate(),
          videoType: videoType,
          videoURLType: videoURLType.validate(),
          videoId: videoId,
          videoThumbnailImage: thumbnailImage,
          isTrailer: isTrailerForYouTube,
          isSlider: isSlider,
          onVideoEnd: onVideoEnd, // Pass callback
          onPlaybackHandleReady: onPlaybackHandleReady,
        ),
      );
    } else if (videoURLType.validate().toLowerCase() == VideoType.typeVimeo) {
      if (videoURL.getVimeoVideoId.validate().isEmpty) {
        return Stack(
          children: [
            CachedImageWidget(
              url: thumbnailImage.validate(),
              width: cardSize.width,
              height: cardSize.height,
              fit: BoxFit.cover,
            ).onTap(() {
              onTap?.call();
            }),
          ],
        );
      }
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          onTap?.call();
        },
        child: WebViewContentWidget(
          uri: Uri.parse('https://player.vimeo.com/video/${videoURL.getVimeoVideoId}'),
          autoPlayVideo: isTrailer,
        ),
      );
    } else {
      if (isTrailer && !_isValidHttpUrl(videoURL.validate())) {
        return Stack(
          children: [
            CachedImageWidget(
              url: thumbnailImage.validate(),
              width: cardSize.width,
              height: cardSize.height,
              fit: BoxFit.cover,
            ).onTap(() {
              onTap?.call();
            }),
          ],
        );
      }
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          onTap?.call();
        },
        child: VideoPlayerWidget(
          key: ValueKey('regular-$videoId-$videoURL'),
          videoURL: videoURL.validate(),
          watchedTime: watchedTime.validate(),
          videoType: videoType,
          videoURLType: videoURLType.validate(),
          videoId: videoId,
          videoThumbnailImage: thumbnailImage,
          isTrailer: isTrailer,
          isFromDashboard: isSlider,
          onVideoEnd: onVideoEnd, // Pass callback
          onPlaybackHandleReady: onPlaybackHandleReady,
        ),
      );
    }
  }
}