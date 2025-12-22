import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/view_video/video_playback_handle.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MovieURLWidget extends StatelessWidget {
  static String tag = '/MovieURLWidget';

  final String? url;
  final String? title;
  final String? image;
  final String videoId;
  final String videoDuration;

  final String videoURLType;
  final String watchedTime;
  final VoidCallback? videoCompletedCallback;

  final PostType postType;
  final ValueChanged<VideoPlaybackHandle>? onPlaybackHandleReady;

  const MovieURLWidget(
    this.url, {
    super.key,
    this.title,
    this.image,
    required this.videoId,
    required this.videoDuration,
    this.videoCompletedCallback,
    required this.videoURLType,
    required this.watchedTime,
    required this.postType,
    this.onPlaybackHandleReady,
  });

  bool get isYoutubeUrl => true;

  bool get isMovieFromGoogleDriveLink => url.validate().startsWith("https://drive.google.com");

  @override
  Widget build(BuildContext context) {
    return isYoutubeUrl || url.validate().isLiveURL || url.validate().isVideoPlayerFile
        ? VideoWidget(
            videoURL: url.validate(),
            watchedTime: watchedTime,
            videoType: postType,
            videoURLType: videoURLType.validate(),
            videoId: videoId.toInt(),
            thumbnailImage: image.validate(),
            isTrailer: false,
            onPlaybackHandleReady: onPlaybackHandleReady,
          )
        : isMovieFromGoogleDriveLink
            ? SizedBox(
                width: context.width(),
                height: appStore.hasInFullScreen ? context.height() : context.height() * 0.3,
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.dataFromString(movieEmbedCode, mimeType: "text/html")),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          if (appStore.hasInFullScreen) {
                            appStore.setToFullScreen(false);
                          } else {
                            appStore.setToFullScreen(true);
                          }
                        },
                        icon: Icon(appStore.hasInFullScreen ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (appStore.hasInFullScreen) {
                          appStore.setToFullScreen(false);
                        } else {
                          appStore.setPIPOn(false);
                          finish(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              )
            : SizedBox(
                width: context.width(),
                height: 200,
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.parse(url.validate())),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          if (appStore.hasInFullScreen) {
                            appStore.setToFullScreen(false);
                          } else {
                            appStore.setToFullScreen(true);
                          }
                        },
                        icon: Icon(appStore.hasInFullScreen ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (appStore.hasInFullScreen) {
                          appStore.setToFullScreen(false);
                        } else {
                          appStore.setPIPOn(false);
                          finish(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              );
  }

  String get movieEmbedCode => '''<html>
      <head>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
      </head>
      <body style="background-color: #000000;">
        <iframe></iframe>
      </body>
      <script>
        \$(function(){
        \$('iframe').attr('src','${url.validate()}');
        \$('iframe').css('border','none');
        \$('iframe').attr('width','100%');
        \$('iframe').attr('height','100%');
        \$(document).ready(function(){
              \$(".ndfHFb-c4YZDc-Wrql6b").hide();
            });
        });
      </script>
    </html> ''';
}
