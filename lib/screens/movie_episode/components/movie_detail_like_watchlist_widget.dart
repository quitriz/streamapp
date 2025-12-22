import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/view_video/custom_controllers.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/playlist/components/playlist_list_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/download_utils.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

// ignore: must_be_immutable
class MovieDetailLikeWatchListWidget extends StatefulWidget {
  static String tag = '/LikeWatchlistWidget';

  final VoidCallback? onAction;
  final int postId;
  bool? isInWatchList;
  bool? isLiked;
  int? likes;
  final PostType postType;
  final String? videoName;
  final String? videoLink;
  final String? shareUrl;
  final String? videoImage;
  final String? videoDescription;
  final String? videoDuration;
  final bool? userHasAccess;
  final bool? isTrailerVideoPlaying;
  final VoidCallback? onDownloadStarted;
  final VoidCallback? onDownloadFinished;
  final bool? isUpcoming;
  final VoidCallback? onPauseVideo;

  MovieDetailLikeWatchListWidget({
    this.onAction,
    required this.postId,
    this.isInWatchList,
    this.isLiked,
    this.likes,
    required this.postType,
    this.videoName,
    this.videoLink,
    this.shareUrl,
    this.videoImage,
    this.videoDescription,
    this.videoDuration,
    this.userHasAccess,
    this.isTrailerVideoPlaying,
    this.onDownloadStarted,
    this.onDownloadFinished,
    this.isUpcoming,
    this.onPauseVideo,
  });

  @override
  MovieDetailLikeWatchListWidgetState createState() => MovieDetailLikeWatchListWidgetState();
}

class MovieDetailLikeWatchListWidgetState extends State<MovieDetailLikeWatchListWidget> with WidgetsBindingObserver {
  late String downloadDirPath;
  final ReceivePort _port = ReceivePort();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    init();
    _syncAppStoreWithLocalStorage();
    DownloadManager.initializeDownloadManager();
  }

  Future<void> _syncAppStoreWithLocalStorage() async {
    List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList() : [];

    appStore.downloadedItemList.clear();
    appStore.downloadedItemList.addAll(list);
  }

  Future<void> init() async {
    List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList() : [];

    bool matchedDownload = false;
    if (list.isNotEmpty) {
      for (var i in list) {
        if (i.title == widget.videoName) {
          final exists = await checkDownloadedFileExists(widget.videoName ?? '');
          if (exists) {
            appStore.setMovieDetailDownloadCompleted(widget.postId.toString());
            appStore.setMovieDetailDownloadData(widget.postId.toString(), i);
            matchedDownload = true;
          } else {
            log('DEBUG: File does not exist for ${widget.videoName}');
          }
          break;
        }
      }
    }

    if (!matchedDownload) {
      appStore.clearMovieDetailDownloadState(widget.postId.toString());
    }

    if (widget.isLiked != null) {
      appStore.setMovieLikeState(widget.postId.toString(), widget.isLiked!);
    }
    if (widget.likes != null) {
      appStore.setMovieLikeCount(widget.postId.toString(), widget.likes!);
    }
    if (widget.isInWatchList != null) {
      appStore.setMovieWatchlistState(widget.postId.toString(), widget.isInWatchList!);
    }
  }

  _bindBackgroundIsolate() async {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    } else {
      _port.listen((message) {
        String taskId = message[0];
        int status = message[1];
        int progress = message[2];

        if (status == 2) {
          // Downloading
          appStore.setMovieDetailDownloadProgress(widget.postId.toString(), progress);
          appStore.setMovieDetailDownloadTaskId(widget.postId.toString(), taskId);
        } else if (status == 3) {
          // Completed
          log('DEBUG: Download status is complete (3)');
          onDownloadComplete();
        } else if (status == 4) {
          // Failed
          log('DEBUG: Download status is failed (4)');
          onDownloadFailed();
        }
      });
      await FlutterDownloader.registerCallback(DownloadManager.downloadCallback);
    }
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  Future<void> startDownload({required String url}) async {
    final postIdStr = widget.postId.toString();

    // Guard check: if already downloading (and not from our onTap handler), return
    // Since we set downloading state in onTap handler, we expect it to be true here
    // This check prevents duplicate calls if somehow startDownload is called from elsewhere
    if (appStore.isMovieDetailDownloading(postIdStr)) {
      // State is already set from onTap handler, so we can proceed
      // Just need to reset other states and ensure progress is set
      appStore.resetMovieDetailDownloadState(postIdStr);
      appStore.setMovieDetailDownloadState(postIdStr, true);
      appStore.setMovieDetailDownloadProgress(postIdStr, 0);
    } else {
      // This shouldn't happen if called from onTap handler, but handle it as fallback
      appStore.setMovieDetailDownloadState(postIdStr, true);
      appStore.resetMovieDetailDownloadState(postIdStr);
      appStore.setMovieDetailDownloadState(postIdStr, true);
      appStore.setMovieDetailDownloadProgress(postIdStr, 0);
    }

    widget.onDownloadStarted?.call();

    try {
      String? taskId = await downloadVideo(
        url: url,
        fileName: widget.videoName ?? 'video_${widget.postId}',
        showNotification: true,
        openFileFromNotification: true,
      );

      if (taskId != null) {
        log('File: ${widget.videoName}.mp4');
        downloadDirPath = await getDownloadDirectory();
        log('Location: $downloadDirPath');

        appStore.setMovieDetailDownloadTaskId(widget.postId.toString(), taskId);

        await pollDownloadStatus(
          taskId: taskId,
          onProgress: (progress) {
            appStore.setMovieDetailDownloadProgress(widget.postId.toString(), progress);
          },
          onComplete: onDownloadComplete,
          onFailed: onDownloadFailed,
        );
      } else {
        onDownloadFailed();
        toast('Failed to start download', print: true);
      }
    } catch (e) {
      log('Download error: $e');
      onDownloadFailed();
      toast('Download failed: ${e.toString()}', print: true);
    } finally {
      widget.onDownloadFinished?.call();
    }
  }

  void onDownloadComplete() {
    log('DEBUG: Download completed for ${widget.videoName}');

    appStore.setMovieDetailDownloadCompleted(widget.postId.toString());

    DownloadData data = createDownloadData(
      postId: widget.postId,
      title: widget.videoName,
      image: widget.videoImage,
      description: widget.videoDescription,
      duration: widget.videoDuration,
      filePath: '$downloadDirPath/${widget.videoName}.mp4',
    );

    log('DEBUG: Adding to local storage - Title: ${data.title}, Path: ${data.filePath}');

    addOrRemoveFromLocalStorage(data);
    appStore.setMovieDetailDownloadData(widget.postId.toString(), data);

    if (!appStore.downloadedItemList.any((item) => item.id == data.id)) {
      appStore.downloadedItemList.add(data);
      log('DEBUG: Added to appStore downloadedItemList. New count: ${appStore.downloadedItemList.length}');
    }

    toast('Download completed successfully');
  }

  void onDownloadFailed() {
    appStore.setMovieDetailDownloadFailed(widget.postId.toString());
  }

  Future<void> watchlistClick() async {
    if (!mIsLoggedIn) {
      // Pause video before navigating to sign in
      widget.onPauseVideo?.call();
      appStore.setTrailerVideoPlayer(false);
      SignInScreen().launch(context);
      return;
    }
    Map req = {
      'post_id': widget.postId.validate(),
      'user_id': getIntAsync(USER_ID),
      'post_type': widget.postType == PostType.MOVIE
          ? 'movie'
          : widget.postType == PostType.TV_SHOW
              ? 'tv_show'
              : 'video',
      'action': appStore.isMovieInWatchlist(widget.postId.toString()) ? 'remove' : 'add',
    };

    appStore.toggleMovieWatchlist(widget.postId.toString());

    await watchlistMovie(req).then((value) {
      toast(value.isAdded! ? language.movieAddedToYourWatchlist : language.movieRemovedFromYourWatchlist);
    }).catchError((e) {
      appStore.revertMovieWatchlist(widget.postId.toString());
      toast(e.toString());
    });
  }

  Future<void> likeClick() async {
    if (!mIsLoggedIn) {
      // Pause video before navigating to sign in
      widget.onPauseVideo?.call();
      appStore.setTrailerVideoPlayer(false);
      SignInScreen().launch(context);
      return;
    }

    Map req = {
      'post_id': widget.postId.validate(),
      'post_type': widget.postType == PostType.MOVIE
          ? 'movie'
          : widget.postType == PostType.TV_SHOW
              ? 'tv_show'
              : 'video'
    };

    appStore.toggleMovieLike(widget.postId.toString());

    await likeMovie(req).then((res) {}).catchError((e) {
      appStore.revertMovieLike(widget.postId.toString());
      toast(e.toString());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _unbindBackgroundIsolate();
    DownloadManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                if (!widget.isUpcoming.validate())
                  DecoratedBox(
                    decoration:
                        BoxDecoration(border: Border.all(color: appStore.isMovieLiked(widget.postId.toString()) ? context.primaryColor : borderColor), shape: BoxShape.circle),
                    child: InkWell(
                      onTap: () {
                        likeClick();
                      },
                      child: CachedImageWidget(url: ic_like, color: appStore.isMovieLiked(widget.postId.toString()) ? context.primaryColor : rememberMeColor, width: 24, height: 24, fit: BoxFit.cover),
                    ).paddingAll(8),
                  ),
                if (!widget.isUpcoming.validate()) 8.width,
                DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(color: appStore.isMovieInWatchlist(widget.postId.toString()) ? context.primaryColor : borderColor), shape: BoxShape.circle),
                  child: InkWell(
                    onTap: () {
                      watchlistClick();
                    },
                    child: CachedImageWidget(
                        url: appStore.isMovieInWatchlist(widget.postId.toString()) ? ic_check : ic_plus,
                        color: appStore.isMovieInWatchlist(widget.postId.toString()) ? context.primaryColor : rememberMeColor,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover),
                  ).paddingAll(8),
                ),
                8.width,
                DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(color: borderColor), shape: BoxShape.circle),
                  child: InkWell(
                    onTap: (() async {
                      await shareMovieOrEpisode(widget.shareUrl.validate());
                    }),
                    child: CachedImageWidget(url: ic_share, color: rememberMeColor, width: 24, height: 24, fit: BoxFit.cover),
                  ).paddingAll(8),
                ),
                8.width,
                if (!widget.isUpcoming.validate())
                  DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(color: borderColor), shape: BoxShape.circle),
                    child: CastIconWidget(
                      videoURL: widget.videoLink.validate(),
                      videoTitle: widget.videoName.validate(),
                      videoImage: widget.videoImage.validate(),
                    ),
                  ),
                if (!widget.isUpcoming.validate()) 8.width,
                if (widget.postType != PostType.TV_SHOW && !widget.isUpcoming.validate() && coreStore.shouldShowPlaylist)
                  DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(color: borderColor), shape: BoxShape.circle),
                    child: InkWell(
                      onTap: () {
                        if (appStore.isLogging) {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: radiusCircular(defaultRadius + 8), topLeft: radiusCircular(defaultRadius + 8))),
                            builder: (dialogContext) {
                              return PlaylistListWidget(
                                playlistType: widget.postType == PostType.MOVIE
                                    ? playlistMovie
                                    : widget.postType == PostType.EPISODE
                                        ? playlistEpisodes
                                        : playlistVideo,
                                postId: widget.postId.validate(),
                              );
                            },
                          );
                        } else {
                          // Pause video before navigating to sign in
                          widget.onPauseVideo?.call();
                          appStore.setTrailerVideoPlayer(false);
                          SignInScreen().launch(context);
                        }
                      },
                      child: Icon(Icons.library_add_outlined, color: rememberMeColor, size: 24),
                    ).paddingAll(8),
                  ),
                if (widget.postType != PostType.TV_SHOW && !widget.isUpcoming.validate() && coreStore.shouldShowPlaylist) 8.width,
                if (_shouldShowDownloadButton())
                  DecoratedBox(
                    decoration: BoxDecoration(border: Border.all(color: borderColor), shape: BoxShape.circle),
                    child: InkWell(
                      onTap: appStore.isMovieDetailDownloading(widget.postId.toString())
                          ? null
                          : () async {
                              final postIdStr = widget.postId.toString();

                              // Handle delete case (when download is completed)
                              if (appStore.isMovieDetailDownloadCompleted(postIdStr)) {
                                DownloadData? data = appStore.getMovieDetailDownloadData(postIdStr);
                                if (data != null) {
                                  await addOrRemoveFromLocalStorage(data, isDelete: true);
                                  appStore.clearMovieDetailDownloadState(postIdStr);
                                }
                                return;
                              }

                              // Handle download cases - set state immediately to prevent multiple taps
                              bool shouldDownload = false;
                              if (!appStore.isMovieDetailDownloadCompleted(postIdStr) && !appStore.isMovieDetailDownloading(postIdStr)) {
                                shouldDownload = true;
                              } else if (appStore.isMovieDetailDownloadFailed(postIdStr) && !appStore.isMovieDetailDownloading(postIdStr)) {
                                shouldDownload = true;
                              }

                              if (shouldDownload) {
                                // Set downloading state immediately before any validation to prevent multiple taps
                                appStore.setMovieDetailDownloadState(postIdStr, true);

                                // Now do validation checks
                                if (!_canInitiateDownload()) {
                                  // Reset state if validation fails
                                  appStore.setMovieDetailDownloadFailed(postIdStr);
                                  // Pause video before navigating to sign in
                                  widget.onPauseVideo?.call();
                                  appStore.setTrailerVideoPlayer(false);
                                  SignInScreen().launch(context);
                                  return;
                                }

                                await startDownload(url: widget.videoLink.validate());
                              }
                            },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            appStore.isMovieDetailDownloadCompleted(widget.postId.toString())
                                ? Icons.delete
                                : appStore.isMovieDetailDownloading(widget.postId.toString())
                                    ? Icons.downloading
                                    : appStore.isMovieDetailDownloadFailed(widget.postId.toString())
                                        ? Icons.refresh
                                        : Icons.download_outlined,
                            color: appStore.isMovieDetailDownloading(widget.postId.toString()) ? Colors.grey : textColorSecondary,
                            size: 20,
                          ),
                          if (appStore.isMovieDetailDownloading(widget.postId.toString()))
                            Builder(
                              builder: (context) {
                                int? progress = appStore.getMovieDetailDownloadProgress(widget.postId.toString());
                                if (progress != null)
                                  return SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(value: progress / 100, strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(textColorSecondary)),
                                  );
                                return SizedBox.shrink();
                              },
                            ),
                        ],
                      ),
                    ).paddingAll(8),
                  ),
              ],
            ),
          ),
          6.height,
          if (!widget.isUpcoming.validate() && appStore.getMovieLikeCount(widget.postId.toString()) > 0)
            Text('${buildLikeCountText(appStore.getMovieLikeCount(widget.postId.toString()))}', style: secondaryTextStyle()).paddingSymmetric(horizontal: 8),
        ],
      ),
    );
  }

  bool _shouldShowDownloadButton() {
    if (!coreStore.allowDownload) return false;
    if (widget.isUpcoming.validate()) return false;
    if (!widget.userHasAccess.validate()) return false;
    if (widget.videoLink.validate().isEmpty) return false;
    return appStore.isLogging || coreStore.allowGuestDownload;
  }

  bool _canInitiateDownload() {
    if (!coreStore.allowDownload) return false;
    if (appStore.isLogging) return true;
    return coreStore.allowGuestDownload;
  }
}
