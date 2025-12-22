import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/screens/downloads/local_media_player_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/download_utils.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class GuestDownloadsScreen extends StatefulWidget {
  const GuestDownloadsScreen({super.key});

  @override
  State<GuestDownloadsScreen> createState() => _GuestDownloadsScreenState();
}

class _GuestDownloadsScreenState extends State<GuestDownloadsScreen> {
  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    _syncDownloadsFromStorage();
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  Future<void> _syncDownloadsFromStorage() async {
    final storedDownloads = getStringAsync(DOWNLOADED_DATA);
    List<DownloadData> parsedList = [];

    if (storedDownloads.isNotEmpty) {
      try {
        final decoded = jsonDecode(storedDownloads) as List<dynamic>;
        parsedList = decoded.map((e) => DownloadData.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        log('GuestDownloadsScreen: Failed to parse downloads - $e');
      }
    }

    appStore.downloadedItemList
      ..clear()
      ..addAll(parsedList);

    setState(() {});
  }

  Future<void> _playDownload(BuildContext context, DownloadData data) async {
    if (!await checkPermission()) return;
    LocalMediaPlayerScreen(data: data).launch(context);
  }

  Future<void> _deleteDownload(BuildContext context, DownloadData data) async {
    await addOrRemoveFromLocalStorage(data, isDelete: true);
    await _syncDownloadsFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(language.guestDownloads, style: boldTextStyle()),
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        elevation: 0,
      ),
      body: Observer(
        builder: (_) {
          final currentUserId = getIntAsync(USER_ID);
          final downloads = appStore.downloadedItemList.where((data) {
            final matchesUser = (data.userId ?? currentUserId) == currentUserId;
            final notDeleted = !(data.isDeleted ?? false);
            return matchesUser && notDeleted;
          }).toList();

          if (downloads.isEmpty) {
            return NoDataWidget(
              imageWidget: CachedImageWidget(url: ic_download, height: 80, width: 80, color: context.iconColor.withAlpha(80)),
              title: language.noDownloadsAvailable,
              subTitle: language.youHavenTDownloadedAny,
            ).center();
          }

          return RefreshIndicator(
            color: context.primaryColor,
            onRefresh: _syncDownloadsFromStorage,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: downloads.length,
              separatorBuilder: (_, __) => 16.height,
              itemBuilder: (context, index) {
                final download = downloads[index];
                final downloadId = download.id.validate().toString();
                final isDownloading = appStore.isVideoDownloading(downloadId);
                final isFailed = appStore.isDownloadFailed(downloadId);
                final progress = appStore.getDownloadProgress(downloadId) ?? 0;

                return Container(
                  decoration: BoxDecoration(
                    color: appBackground,
                    borderRadius: radius(12),
                    border: Border.all(color: context.dividerColor),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: CachedImageWidget(
                      url: download.image.validate().isNotEmpty ? download.image.validate() : appStore.sliderDefaultImage.validate(),
                      height: 56,
                      width: 56,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(8),
                    title: Text(
                      parseHtmlString(download.title.validate()),
                      style: boldTextStyle(size: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (download.duration.validate().isNotEmpty)
                          Text(
                            convertRuntimeToReadableFormat(download.duration.validate()),
                            style: secondaryTextStyle(),
                          ),
                        if (isDownloading) ...[
                          8.height,
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: context.dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
                          ),
                          4.height,
                          Text('${language.downloading} • $progress%', style: secondaryTextStyle(size: 12)),
                        ] else if (isFailed) ...[
                          8.height,
                          Text(language.downloadFailed, style: secondaryTextStyle(color: redColor, size: 12)),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: colorPrimary),
                      onPressed: () async {
                        await showConfirmDialogCustom(
                          context,
                          title: language.areYouSureYouWantToDeleteThisMovieFromDownloads,
                          onAccept: (_) async {
                            await _deleteDownload(context, download);
                          },
                          primaryColor: context.primaryColor,
                          positiveText: language.yes,
                          negativeText: language.no,
                          cancelable: true,
                        );
                      },
                    ),
                    onTap: () async {
                      if (isDownloading) return;
                      await _playDownload(context, download);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
