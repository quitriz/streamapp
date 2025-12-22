import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/coming_soon_badge.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/playlist/components/playlist_list_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/download_utils.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

enum EpisodeStatus { none, loading, downloaded }

class EpisodeItemComponent extends StatefulWidget {
  final MovieData episode;
  final VoidCallback? onTap;
  final EpisodeStatus status;
  final int episodeIndex;
  final bool isSelected;
  final bool showDownloadIcon;

  const EpisodeItemComponent({Key? key, required this.episode, this.onTap, this.status = EpisodeStatus.none, required this.episodeIndex, this.isSelected = false, this.showDownloadIcon = false})
      : super(key: key);

  @override
  State<EpisodeItemComponent> createState() => _EpisodeItemComponentState();
}

class _EpisodeItemComponentState extends State<EpisodeItemComponent> {
  String? downloadTaskId;
  String? downloadDirPath;
  DownloadData? data;

  @override
  void initState() {
    super.initState();
    DownloadManager.initializeDownloadManager();
    _syncEpisodeReminderState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDownloadState();
    });
  }

  @override
  void didUpdateWidget(covariant EpisodeItemComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episode.id != widget.episode.id || oldWidget.episode.isRemind != widget.episode.isRemind) {
      _syncEpisodeReminderState();
    }
  }

  Future<void> _initDownloadState() async {
    try {
      List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList() : [];

      bool matchedDownload = false;
      if (list.isNotEmpty) {
        for (var i in list) {
          if (i.title == widget.episode.title) {
            final exists = await checkDownloadedFileExists(widget.episode.title.validate());
            if (exists) {
              final episodeId = widget.episode.id.validate().toString();
              appStore.setDownloadCompleted(episodeId);
              appStore.setDownloadData(episodeId, i);
              data = i;
              matchedDownload = true;
            }
            break;
          }
        }
      }

      if (!matchedDownload) {
        final episodeId = widget.episode.id.validate().toString();
        appStore.clearDownloadProgress(episodeId);
      }
    } catch (e) {
      log('Episode init download state error: $e');
    }
  }

  void _syncEpisodeReminderState() {
    final episodeId = widget.episode.id.validate();
    final defaultState = widget.episode.isRemind.validate();
    final hasState = fragmentStore.episodeReminderStates.containsKey(episodeId);
    if (!hasState || fragmentStore.getEpisodeReminderState(episodeId) != defaultState) {
      fragmentStore.setEpisodeReminderState(episodeId, defaultState);
    }
  }

  Future<void> _handleRemindMeTap() async {
    final episodeId = widget.episode.id.validate();
    final currentState = fragmentStore.getEpisodeReminderState(episodeId, fallback: widget.episode.isRemind.validate());

    await handleRemindMeWithOptimisticUI(
      context: context,
      contentId: episodeId,
      postType: ReviewConst.reviewTypeEpisode,
      onOptimisticUpdate: () {
        fragmentStore.setEpisodeReminderState(episodeId, !currentState);
      },
      onRollback: () {
        fragmentStore.setEpisodeReminderState(episodeId, currentState);
      },
    );
  }

  Future<void> _startDownload() async {
    final episodeId = widget.episode.id.validate().toString();

    // Guard check: if already downloading (and progress is not 0, meaning it's a real download in progress), return
    // We allow progress of 0 because we just set it in _onDownloadIconTap to prevent multiple taps
    final currentProgress = appStore.getDownloadProgress(episodeId);
    if (currentProgress != null && currentProgress > 0) {
      return;
    }

    final fileUrl = _normalizedEpisodeFile();

    if (fileUrl.isEmpty) {
      // Reset state if file URL is empty
      appStore.clearDownloadProgress(episodeId);
      toast(redirectionUrlNotFound);
      return;
    }

    // Progress is already set to 0 in _onDownloadIconTap, so we don't need to set it again

    try {
      downloadTaskId = await downloadVideo(
        url: fileUrl,
        fileName: widget.episode.title.validate(),
        showNotification: true,
        openFileFromNotification: true,
      );

      if (downloadTaskId != null) {
        downloadDirPath = await getDownloadDirectory();
        appStore.setDownloadTaskId(episodeId, downloadTaskId!);

        await pollDownloadStatus(
          taskId: downloadTaskId!,
          onProgress: (p) {
            appStore.setDownloadProgress(episodeId, p);
          },
          onComplete: () => _onDownloadComplete(episodeId),
          onFailed: () => _onDownloadFailed(episodeId),
        );
      } else {
        _onDownloadFailed(episodeId);
        toast('Failed to start download', print: true);
      }
    } catch (e) {
      log('Episode download error: $e');
      _onDownloadFailed(episodeId);
      toast('Download failed: ${e.toString()}', print: true);
    }
  }

  void _onDownloadComplete(String episodeId) {
    data = createDownloadData(
      postId: widget.episode.id.validate(),
      title: widget.episode.title.validate(),
      image: widget.episode.image.validate(),
      description: widget.episode.description.validate(),
      duration: widget.episode.runTime.validate(),
      filePath: '${downloadDirPath.validate()}/${widget.episode.title.validate()}.mp4',
    );

    appStore.setDownloadCompleted(episodeId);
    appStore.setDownloadData(episodeId, data!);
    addOrRemoveFromLocalStorage(data!);
    toast(language.downloadCompleteSuccessfully);
  }

  void _onDownloadFailed(String episodeId) {
    appStore.setDownloadFailed(episodeId);
  }

  Future<void> _onDownloadIconTap() async {
    final episodeId = widget.episode.id.validate().toString();
    final isDownloaded = appStore.isDownloadCompleted(episodeId);
    final isDownloading = appStore.isVideoDownloading(episodeId);
    final isFailed = appStore.isDownloadFailed(episodeId);

    // Handle delete case (when download is completed)
    if (isDownloaded) {
      final downloadData = appStore.getDownloadData(episodeId);
      if (downloadData != null) {
        addOrRemoveFromLocalStorage(downloadData, isDelete: true);
        appStore.clearDownloadProgress(episodeId);
      }
      return;
    }

    // Handle download cases - set state immediately to prevent multiple taps
    bool shouldDownload = false;
    if (!isDownloaded && !isDownloading) {
      shouldDownload = true;
    } else if (isFailed && !isDownloading) {
      shouldDownload = true;
    }

    if (shouldDownload) {
      // Set downloading state immediately before any validation
      appStore.setDownloadProgress(episodeId, 0);

      if (!widget.episode.userHasAccess.validate()) {
        appStore.clearDownloadProgress(episodeId);
        return;
      }

      if (!coreStore.allowDownload) {
        // Reset state if validation fails
        appStore.clearDownloadProgress(episodeId);
        toast('Downloads are currently disabled');
        return;
      }

      if (!appStore.isLogging && !coreStore.allowGuestDownload) {
        // Reset state if validation fails
        appStore.clearDownloadProgress(episodeId);
        SignInScreen().launch(context);
        return;
      }

      await _startDownload();
    }
  }

  Widget _buildDownloadImageIcon() {
    final episodeId = widget.episode.id.validate().toString();
    final isDownloaded = appStore.isDownloadCompleted(episodeId);
    final isDownloading = appStore.isVideoDownloading(episodeId);

    String iconAsset = isDownloaded ? ic_downloaded : (isDownloading ? ic_download_progress : ic_download);

    return CachedImageWidget(url: iconAsset, width: 20, height: 20, fit: BoxFit.cover).onTap(() async {
      if (!isDownloading) await _onDownloadIconTap();
    });
  }

  String _normalizedEpisodeFile() {
    return widget.episode.episodeFile.validate().replaceAll(r'\/', '/').trim();
  }

  bool _shouldShowDownloadIcon() {
    final bool hasDownloadFile = widget.showDownloadIcon;
    final bool downloadsEnabled = coreStore.allowDownload;
    final bool isUpcoming = widget.episode.isUpcoming.validate();
    final bool canDownloadAsGuestOrLoggedIn = appStore.isLogging || coreStore.allowGuestDownload;
    final canShow = hasDownloadFile && downloadsEnabled && !isUpcoming && canDownloadAsGuestOrLoggedIn;
    return canShow;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        // Access MobX observables for tracking
        final episodeId = widget.episode.id.validate();
        final expandedStates = fragmentStore.episodeExpandedStates;
        final isExpanded = expandedStates[episodeId] ?? false;

        return InkWell(
          onTap: () {
            if (widget.onTap == null) return;

            if (widget.episode.isUpcoming.validate()) {
              return;
            }

            final hasAccess = widget.episode.userHasAccess.validate();
            if (!appStore.isLogging && !hasAccess) {
              SignInScreen().launch(context);
              return;
            }

            widget.onTap!.call();
          },
          child: Container(
            decoration: BoxDecoration(
              border: widget.isSelected ? Border.all(color: context.primaryColor, width: 2) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Container(
                  height: 94,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appBackground,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CachedImageWidget(
                            url: widget.episode.thumbnailImage.validate().isEmpty ? appStore.sliderDefaultImage.validate() : widget.episode.thumbnailImage.validate(),
                            height: 62,
                            width: 100,
                            fit: BoxFit.cover,
                          ).cornerRadiusWithClipRRect(8),
                          if (widget.episode.isUpcoming.validate())
                            ComingSoonBadge(
                              top: 4,
                              left: 4,
                              iconSize: 10,
                              textSize: 9,
                              horizontalPadding: 4,
                              verticalPadding: 2,
                            ),
                        ],
                      ),
                      16.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.episode.title.validate(),
                              style: boldTextStyle(size: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            4.height,
                            Text(
                              'E${widget.episodeIndex + 1} ${widget.episode.releaseDate?.isNotEmpty ?? false ? "• ${widget.episode.releaseDate}" : ''}',
                              style: secondaryTextStyle(size: 12),
                            ),
                          ],
                        ),
                      ),
                      16.width,
                      !widget.episode.isUpcoming.validate()
                          ? Icon(Icons.library_add_outlined, color: textColorSecondary).onTap(() {
                              if (appStore.isLogging) {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: radiusCircular(defaultRadius + 8), topLeft: radiusCircular(defaultRadius + 8))),
                                  builder: (dialogContext) {
                                    return PlaylistListWidget(
                                      playlistType: playlistEpisodes,
                                      postId: widget.episode.id.validate(),
                                    );
                                  },
                                );
                              } else {
                                SignInScreen().launch(context);
                              }
                            })
                          : InkWell(
                              onTap: () async {
                                try {
                                  await _handleRemindMeTap();
                                } catch (e) {
                                  log('Remind me error: $e');
                                }
                              },
                              child: Observer(
                                builder: (_) {
                                  final isRemind = fragmentStore.getEpisodeReminderState(widget.episode.id.validate(), fallback: widget.episode.isRemind.validate());
                                  final icon = isRemind ? ic_check : ic_notification;
                                  return CachedImageWidget(url: icon, width: 20, height: 20, fit: BoxFit.cover, color: iconColor);
                                },
                              ),
                            ),
                      8.width,
                      _buildDownloadImageIcon().visible(_shouldShowDownloadIcon()),
                      8.width,
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            //TODO: use mobx to update the expanded state
                            fragmentStore.setEpisodeExpanded(widget.episode.id.validate(), !isExpanded);
                          });
                        },
                        child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: iconColor),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: Container(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: appBackground, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4))),
                    child: ReadMoreText(
                      widget.episode.description.validate(),
                      style: secondaryTextStyle(size: 12),
                      trimLines: 2,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: ' ...${language.readMore}',
                      trimExpandedText: '  ${language.readLess}',
                    ),
                  ),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ).paddingSymmetric(horizontal: 16, vertical: 8);
      },
    );
  }
}
