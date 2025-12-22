import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/coming_soon_badge.dart';
import 'package:streamit_flutter/components/continue_watching_bottomsheet.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/screens/live_tv/screens/channel_detail_screen.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/screens/tv_show/tv_show_detail_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class CommonListItemComponent extends StatelessWidget {
  final CommonDataListModel data;

  final bool isContinueWatch;
  final VoidCallback? callback;
  final VoidCallback? refresh;
  final bool isVerticalList;
  final bool isWatchList;
  final double? width;
  final VoidCallback? onTap;
  final bool isLandscape;
  final bool isLive;
  final bool isViewAll;
  final bool isForDownload;
  final ValueChanged<CommonDataListModel>? onDeleteTap;

  CommonListItemComponent({
    this.callback,
    this.isLandscape = false,
    required this.data,
    this.isContinueWatch = false,
    this.isVerticalList = false,
    this.isWatchList = false,
    this.width,
    this.refresh,
    this.isLive = false,
    this.onTap,
    this.isViewAll = false,
    this.isForDownload = false,
    this.onDeleteTap,
  });

  void _handleOnTap(BuildContext context) async {
    LiveStream().emit(PauseVideo);

    if (data.postType == PostType.EPISODE) {
      final parentShow = CommonDataListModel(id: data.id, postType: PostType.TV_SHOW, title: data.title);

      appStore.setTrailerVideoPlayer(false);
      await TvShowDetailScreen(showData: parentShow, isEpisode: true).launch(context).then((value) {
        if (isWatchList) refresh?.call();
      });
    } else if (data.postType == PostType.TV_SHOW) {
      appStore.setTrailerVideoPlayer(false);
      await TvShowDetailScreen(showData: data).launch(context).then((value) {
        if (isWatchList) refresh?.call();
      });
    } else if (data.postType == PostType.CHANNEL && !isContinueWatch) {
      appStore.setTrailerVideoPlayer(false);
      ChannelDetailScreen(channelId: data.id.validate()).launch(context);
    } else {
      appStore.setTrailerVideoPlayer(!isContinueWatch);
      await MovieDetailScreen(movieData: data).launch(context).then((value) {
        if (isWatchList) refresh?.call();
      });
    }
  }

  void likeUnlike(BuildContext context) async {
    if (!appStore.isLogging) {
      toast(language.pleaseLoginToSearch);
      return;
    }

    try {
      Map request = {
        'post_id': data.id.validate(),
        'user_id': getIntAsync(USER_ID),
        'post_type': data.postType == PostType.MOVIE
            ? ReviewConst.reviewTypeMovie
            : data.postType == PostType.TV_SHOW
                ? ReviewConst.reviewTypeTvShow
                : data.postType == PostType.EPISODE
                    ? ReviewConst.reviewTypeEpisode
                    : ReviewConst.reviewTypeVideo,
        'action': data.isLiked.validate() ? 'dislike' : 'like',
      };

      await likeMovie(request).then((value) {
        if (value.isAdded.validate()) {
          data.isLiked = !data.isLiked.validate();
          if (isContinueWatch) {
            refresh?.call();
          }
          toast(data.isLiked.validate() ? language.likedByYou : language.unLike);
        } else {
          toast(value.message.validate());
        }
      });
    } catch (e) {
      toast(e.toString());
    }
  }

  void removeFromContinueWatch(BuildContext context) async {
    if (!appStore.isLogging) {
      toast(language.pleaseLoginToSearch);
      return;
    }

    try {
      await deleteVideoContinueWatch(postId: data.id.validate(), postType: data.postType).then((value) {
        appStore.removeFromContinueWatchDataList(data);
        fragmentStore.removeFromContinueWatch(data);

        toast(language.successfullyRemovedFromContinue);

        refresh?.call();
      });
    } catch (e) {
      toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () async {
            _handleOnTap(context);
          },
      onLongPress: (isContinueWatch && data.postType == PostType.MOVIE || data.postType == PostType.VIDEO || data.postType == PostType.EPISODE)
          ? () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => ContinueWatchingBottomSheet(
                  data: data,
                  onViewDetails: () {
                    Navigator.pop(context);
                    _handleOnTap(context);
                  },
                  onDownload: () {
                    Navigator.pop(context);
                  },
                  onLikeUnlike: () {
                    Navigator.pop(context);
                    likeUnlike(context);
                  },
                  onRemove: () {
                    Navigator.pop(context);
                    removeFromContinueWatch(context);
                  },
                ),
              )
          : null,
      child: isLandscape ? continueWatchingCard(context) : _buildPortraitCard(context),
    );
  }

  Widget continueWatchingCard(BuildContext context) {
    if (!isContinueWatch) {
      return _buildDefaultLandscapeCard(context);
    }

    return SizedBox(
      width: 220,
      height: 125,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedImageWidget(
              url: data.image.validate().isNotEmpty ? data.image.validate() : appStore.sliderDefaultImage.validate(),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF0C0B11), Color(0x000C0B11)], stops: [0.041, 0.65]),
              ),
            ),
            if (data.watchedDuration != null)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            data.title.validate(),
                            style: boldTextStyle(size: 13, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        4.width,
                        Text(
                          formatWatchedTime(totalSeconds: data.watchedDuration!.watchedTotalTime.validate(), watchedSeconds: data.watchedDuration!.watchedTime.validate()),
                          style: secondaryTextStyle(size: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (data.watchedDuration != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearPercentIndicator(
                  animation: false,
                  lineHeight: 3,
                  percent: (data.watchedDuration!.watchedTimePercentage / 100).clamp(0.0, 1.0),
                  progressColor: colorPrimary,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  padding: EdgeInsets.zero,
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  removeFromContinueWatch(context);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(2)),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLandscapeCard(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width ?? context.width() / 2 - 22,
          height: context.height() * .12,
          decoration: boxDecorationDefault(
            boxShadow: [],
            borderRadius: radius(),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.mirror, colors: [Colors.transparent, Colors.black87]),
          ),
        ),
        Container(
          width: width ?? context.width() / 2 - 22,
          height: context.height() * .12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), spreadRadius: 0, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(defaultRadius),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: data.image.validate().isNotEmpty ? data.image.validate() : appStore.sliderDefaultImage.validate(),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (data.isUpcoming.validate() && !isLive) ComingSoonBadge(top: 6, left: 6, horizontalPadding: 8, verticalPadding: 4, borderRadius: 4),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.8), Colors.black.withValues(alpha: 0.6), Colors.black.withValues(alpha: 0.3), Colors.transparent],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Align(alignment: Alignment.bottomRight, child: LiveTagComponent()),
                  ),
                ).visible(isLive),
                if (isForDownload)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        onDeleteTap?.call(data);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(4)),
                        child: Icon(Icons.delete_outline, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (appStore.showItemName)
          Positioned(
            child: Text(data.title.validate(), style: primaryTextStyle(), textAlign: TextAlign.center),
            right: 8,
            left: 8,
            bottom: 8,
          ),
      ],
    );
  }

  Widget buildCombinedBadge({required String firstImage, required String secondImage, double size = 20}) {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        margin: EdgeInsets.only(right: 1, top: 1),
        width: size * 1.8,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: (size * 1.8) / 2,
                height: size,
                color: rentedColor,
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(firstImage, fit: BoxFit.cover),
              ),
              Container(
                width: (size * 1.8) / 2,
                height: size,
                color: subscriptionColor,
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(secondImage, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitCard(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: isViewAll ? 160 : 200,
          width: isVerticalList ? (isViewAll ? getViewAllWidth(context) : getWidth(context)) : 140,
          child: Stack(
            children: [
              SizedBox(
                height: isViewAll ? 160 : 200,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CachedImageWidget(
                      url: data.portraitImage.validate().isNotEmpty
                          ? data.portraitImage.validate()
                          : (data.image.validate().isNotEmpty ? data.image.validate() : appStore.sliderDefaultImage.validate()),
                      height: context.height() - 20,
                      width: context.width(),
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(radius_container),
                    if (data.isUpcoming.validate()) ComingSoonBadge(top: 6, left: 6),
                    if (isContinueWatch && data.watchedDuration != null)
                      LinearPercentIndicator(
                        animation: false,
                        lineHeight: 2,
                        percent: data.watchedDuration!.watchedTimePercentage.toInt() / 100,
                        progressColor: context.primaryColor,
                        backgroundColor: textColorThird,
                      ).paddingSymmetric(vertical: 8),
                    if (isContinueWatch && data.watchedDuration != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            callback?.call();
                          },
                          child: Icon(Icons.cancel, color: context.primaryColor, size: 20),
                        ).paddingSymmetric(horizontal: 8, vertical: 4),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Observer(
          builder: (_) => Container(
            height: isViewAll ? 160 : 200,
            width: isVerticalList ? (isViewAll ? getViewAllWidth(context) : getWidth(context)) : 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [...List<Color>.generate(20, (index) => Colors.black.withAlpha(index * 10))]),
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: itemTitle(context, parseHtmlString(data.title.validate()), fontSize: ts_small, textAlign: TextAlign.start),
            ),
          ).visible(appStore.showItemName),
        ),
        if (data.purchaseType == PurchaseType.anyone &&
            data.isRent.validate() &&
            appStore.subscriptionPlanId != data.requiredPlan.toString() &&
            data.userHasAccess == false &&
            coreStore.isMembershipEnabled)
          buildCombinedBadge(firstImage: rent_image, secondImage: subscription, size: 20),
        if (data.purchaseType == PurchaseType.plan &&
            data.isRent.validate() &&
            appStore.subscriptionPlanId != data.requiredPlan.toString() &&
            data.userHasAccess == false &&
            coreStore.isMembershipEnabled)
          buildCornerBadge(color: subscriptionColor, imageUrl: subscription, size: 20, top: 0, right: 0),
        if (data.purchaseType == PurchaseType.ppv && data.isRent == true && data.userHasAccess == false && coreStore.isMembershipEnabled)
          buildCornerBadge(color: rentedColor, imageUrl: rent_image, size: 20, top: 0, right: 0),
      ],
    );
  }

  Widget buildCornerBadge({required Color color, required String imageUrl, double size = 30, double? top, double? right, double? left}) {
    return Positioned(
      top: top,
      right: right ?? null,
      left: left ?? null,
      child: Container(
        width: size,
        height: size,
        decoration: (left == null || top == null)
            ? BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
              )
            : BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
              ),
        child: Center(child: SvgPicture.asset(imageUrl, width: 24, height: 24, fit: BoxFit.contain)),
      ),
    );
  }
}
