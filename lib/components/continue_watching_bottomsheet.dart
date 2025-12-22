import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ContinueWatchingBottomSheet extends StatelessWidget {
  final CommonDataListModel data;
  final bool isFileDownloaded;
  final bool isDownloading;
  final bool downloadedFailed;
  final int? progress;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDownload;
  final VoidCallback? onLikeUnlike;
  final VoidCallback? onRemove;

  const ContinueWatchingBottomSheet({
    required this.data,
    this.isFileDownloaded = false,
    this.isDownloading = false,
    this.downloadedFailed = false,
    this.progress,
    this.onViewDetails,
    this.onDownload,
    this.onLikeUnlike,
    this.onRemove,
    Key? key,
  }) : super(key: key);

  String getDownloadText() {
    if (isFileDownloaded) {
      return language.downloaded;
    } else if (isDownloading) {
      return progress != null ? '${language.downloading} ... $progress%' : '${language.downloading} ...';
    } else if (downloadedFailed) {
      return '${language.downloadFailed} - ${language.retry}';
    } else {
      switch (data.postType) {
        case PostType.MOVIE:
          return language.downloadMovie;
        case PostType.EPISODE:
          return language.downloadEpisode;
        case PostType.VIDEO:
          return language.downloadVideo;
        default:
          return language.download;
      }
    }
  }

  Widget bottomSheetOption({required IconData icon, required String title, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            16.width,
            Expanded(child: Text(title, style: primaryTextStyle(color: Colors.white, size: 16))),
          ],
        ),
      ),
    );
  }

  Widget buildDownloadOption() {
    IconData icon;
    Color iconColor = Colors.white70;

    if (isFileDownloaded) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isDownloading) {
      icon = Icons.download;
      iconColor = colorPrimary;
    } else if (downloadedFailed) {
      icon = Icons.error;
      iconColor = Colors.red;
    } else {
      icon = Icons.download_outlined;
    }

    return InkWell(
      onTap: isFileDownloaded ? null : onDownload,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (isDownloading && progress != null)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress! / 100,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                ),
              )
            else
              Icon(icon, color: iconColor, size: 24),
            16.width,
            Expanded(
              child: Text(getDownloadText(), style: primaryTextStyle(color: Colors.white, size: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
          ),
          16.height,
          Text(
            data.title.validate(),
            style: boldTextStyle(size: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: 20),
          24.height,
          bottomSheetOption(icon: Icons.info_outline, title: language.viewDetails, onTap: onViewDetails),
          if (data.file.validate().isNotEmpty) buildDownloadOption(),
          bottomSheetOption(icon: data.isLiked.validate() ? Icons.favorite : Icons.favorite_border, title: data.isLiked.validate() ? language.unLike : language.like, onTap: onLikeUnlike),
          bottomSheetOption(icon: Icons.cancel_outlined, title: language.remove, onTap: onRemove),
          16.height,
        ],
      ),
    );
  }
}
