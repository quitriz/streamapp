import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/components/item_horizontal_list.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/notification_reminder_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/downloads/local_media_player_screen.dart';
import 'package:streamit_flutter/screens/home/view_all_continue_watchings_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/screens/reminder/view_all_reminder_list_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/edit_profile_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/notification_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/settings_screen.dart';
import 'package:streamit_flutter/screens/watchlist/watchlist_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/download_utils.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';
import '../components/common_action_bottom_sheet.dart';
import '../network/user_agent_utils.dart';

class ProfileFragment extends StatefulWidget {
  static String tag = '/ProfileFragment';

  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  @override
  void initState() {
    super.initState();
    // Pause dashboard video when navigating to profile
    appStore.setDashboardShowVideo(false);
    appStore.resetDashboardVideoState();
    if (appStore.isLogging) getNotificationCount();
    getUserData();
  }

  void getUserData() async {
    appStore.setLoading(true);
    fragmentStore.setUserName('${getStringAsync(NAME)} ${getStringAsync(LAST_NAME)}');
    fragmentStore.setUserEmail(getStringAsync(USER_EMAIL));

    List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList() : [];
    appStore.downloadedItemList.clear();
    appStore.downloadedItemList.addAll(list);

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        fragmentStore.setDownloadsLoading(false);
      }
    });

    getMemberShip();
    getContinueList();
    getRandomWatchlistItems();
    fetchReminderList();

    appStore.setLoading(false);
  }

  Future<void> refreshData() async {
    fragmentStore.setUserName('${getStringAsync(NAME)} ${getStringAsync(LAST_NAME)}');
    fragmentStore.setUserEmail(getStringAsync(USER_EMAIL));

    List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList() : [];
    appStore.downloadedItemList.clear();
    appStore.downloadedItemList.addAll(list);

    getMemberShip();
    getContinueList(showLoading: false);
    getRandomWatchlistItems(showLoading: false);
    fetchReminderList(showLoading: false);
  }

  Future<void> getMemberShip() async {
    fragmentStore.setMembershipLoading(true);

    await getMembershipLevelForUser(userId: getIntAsync(USER_ID)).then((value) {
      if (value != null && value != false) {
        fragmentStore.setHasMembership(true);
      } else {
        fragmentStore.setHasMembership(false);
        // Clear subscription plan fields when membership is cancelled/not available
        appStore.setSubscriptionPlanId("");
        appStore.setSubscriptionPlanStartDate("");
        appStore.setSubscriptionPlanExpDate("");
        appStore.setSubscriptionPlanStatus("");
        appStore.setSubscriptionPlanName("");
        appStore.setSubscriptionPlanAmount("");
      }
    }).catchError((e) {
      fragmentStore.setHasMembership(false);
      log("Membership fetch error: $e");
      // Clear subscription plan fields on error as well
      appStore.setSubscriptionPlanId("");
      appStore.setSubscriptionPlanStartDate("");
      appStore.setSubscriptionPlanExpDate("");
      appStore.setSubscriptionPlanStatus("");
      appStore.setSubscriptionPlanName("");
      appStore.setSubscriptionPlanAmount("");
    }).whenComplete(() {
      fragmentStore.setMembershipLoading(false);
      appStore.setLoading(false);
    });
  }

  ///Fetch ReminderList API
  Future<void> fetchReminderList({bool showLoading = true}) async {
    if (showLoading) fragmentStore.setReminderListLoading(true);

    await getReminderList().then((value) {
      if (value.reminderList != null) {
        fragmentStore.setReminderList(value.reminderList!);
      }
    }).catchError((e) {
      log("Error fetching reminder list: ${e.toString()}");
    }).whenComplete(() {
      if (showLoading) fragmentStore.setReminderListLoading(false);
    });
  }

  Future<void> getContinueList({bool showLoading = true}) async {
    if (showLoading) fragmentStore.setContinueWatchLoading(true);

    await getVideoContinueWatch(
      continueWatchList: fragmentStore.continueWatch,
      page: 1,
      lastPageCallback: (p0) {},
    ).then((v) {
      if (showLoading) fragmentStore.setContinueWatchLoading(false);
    }).catchError((e) {
      if (showLoading) fragmentStore.setContinueWatchLoading(false);
    });
  }

  Future<List<CommonDataListModel>> getList() async {
    getWatchList(page: fragmentStore.mPage).then((value) {
      fragmentStore.setLastPage(value.length != postPerPage);
      if (fragmentStore.mPage == 1) fragmentStore.clearWatchList();

      fragmentStore.setWatchList([...fragmentStore.watchList, ...value]);

      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });

    return fragmentStore.watchList.validate();
  }

  Future<void> getRandomWatchlistItems({bool showLoading = true}) async {
    if (!appStore.isLogging) return;
    if (showLoading) fragmentStore.setWatchListLoading(true);
    List<CommonDataListModel> allWatchlistItems = [];

    try {
      List<CommonDataListModel> movies = await getWatchList(page: 1, postType: ReviewConst.reviewTypeMovie);
      List<CommonDataListModel> tvShows = await getWatchList(page: 1, postType: ReviewConst.reviewTypeTvShow);
      List<CommonDataListModel> videos = await getWatchList(page: 1, postType: ReviewConst.reviewTypeVideo);

      allWatchlistItems.addAll(movies);
      allWatchlistItems.addAll(tvShows);
      allWatchlistItems.addAll(videos);

      allWatchlistItems.shuffle();

      fragmentStore.setRandomWatchList(allWatchlistItems.take(10).toList());

      if (showLoading) fragmentStore.setWatchListLoading(false);
    } catch (e) {
      if (showLoading) fragmentStore.setWatchListLoading(false);
      log("Error getting random watchlist items: ${e.toString()}");
    }
  }

  Future<void> getNotificationCount() async {
    await notificationCount().then((data) {
      fragmentStore.setNotification(data.totalNotificationCount.validate());
    });
  }

  CommonDataListModel downloadDataToCommonData(DownloadData downloadData) {
    return CommonDataListModel(
      id: downloadData.id,
      title: downloadData.title,
      image: downloadData.image,
      portraitImage: downloadData.image,
      postType: downloadData.postType ?? PostType.NONE,
    );
  }

  CommonDataListModel reminderDataToCommonData(ReminderList reminderData) {
    return CommonDataListModel(id: reminderData.id, title: reminderData.title, image: reminderData.image, postType: reminderData.postType!);
  }

  Widget buildShimmerHorizontalList({required bool isLandscape, bool isContinueWatch = false, EdgeInsets? padding, int itemCount = 5}) {
    return Container(
      width: context.width(),
      alignment: Alignment.centerLeft,
      child: HorizontalList(
        itemCount: itemCount,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return CommonListItemShimmer(
            isLandscape: isLandscape,
            isContinueWatch: isContinueWatch,
          );
        },
      ),
    );
  }

  Widget shimmer(double height, double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade600,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserAgentUtils.generateUserAgent();
    return Observer(
      builder: (_) {
        return Scaffold(
          backgroundColor: cardColor,
          appBar: AppBar(
            backgroundColor: appBackground,
            surfaceTintColor: appBackground,
            automaticallyImplyLeading: false,
            elevation: 0,
            leading: CachedImageWidget(url: appLogo, height: 30, width: 30, fit: BoxFit.cover).paddingOnly(left: 16),
            systemOverlayStyle: defaultSystemUiOverlayStyle(context, color: Colors.transparent),
            actions: [
              Stack(
                fit: StackFit.loose,
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationScreen()),
                        ).then((_) {
                          getNotificationCount();
                        });
                      },
                      child: CachedImageWidget(url: ic_notification, width: 20, height: 20, color: iconColor)),
                  if (fragmentStore.notification > 0)
                    Positioned(
                      right: -2,
                      top: -6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                        child: Text(fragmentStore.notification.toString(), style: secondaryTextStyle(size: 6, color: Colors.white)),
                        decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              8.width,
              IconButton(
                onPressed: () {
                  SettingsScreen().launch(context);
                },
                icon: CachedImageWidget(url: ic_settings, color: iconColor, height: 20, width: 20, fit: BoxFit.cover),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (appStore.isLogging) getNotificationCount();
              refreshData();
              return await 2.seconds.delay;
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /// Membership Section
                      if (appStore.isLogging && coreStore.isMembershipEnabled)
                        Observer(
                          builder: (_) {
                            if (fragmentStore.isMembershipLoading) {
                              return Container(
                                width: context.width(),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  border: Border.symmetric(horizontal: BorderSide(color: subscriptionColor, width: 0.7)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// Left shimmer column
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [shimmer(20, 100), 6.height, shimmer(14, 150)],
                                    ),

                                    /// Right shimmer buttons area
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: shimmer(20, 80)),
                                        8.width,
                                        Flexible(child: shimmer(20, 80)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }

                            final bool isFreePlan = appStore.subscriptionPlanName.validate().isEmpty || appStore.subscriptionPlanName.toLowerCase() == "${language.free}".toLowerCase();

                            return Container(
                              width: context.width(),
                              decoration: BoxDecoration(
                                color: cardColor,
                                border: Border.symmetric(horizontal: BorderSide(color: subscriptionColor, width: 0.7)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: isFreePlan ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                                children: [
                                  /// --- Left side text ---
                                  Column(
                                    crossAxisAlignment: isFreePlan ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appStore.subscriptionPlanName.validate().isNotEmpty ? appStore.subscriptionPlanName.validate() : language.free,
                                        style: boldTextStyle(
                                          size: isFreePlan ? (textSecondarySizeGlobal.toInt() + 2) : textSecondarySizeGlobal.toInt(),
                                          fontFamily: GoogleFonts.roboto().fontFamily,
                                        ),
                                      ),
                                      if (appStore.subscriptionPlanExpDate.isNotEmpty)
                                        Text(
                                          "${language.expiringOn} ${appStore.subscriptionPlanExpDate}",
                                          style: secondaryTextStyle(
                                            size: 12,
                                            fontFamily: GoogleFonts.roboto().fontFamily,
                                          ),
                                        ),
                                    ],
                                  ),

                                  /// --- Right side buttons ---
                                  Row(
                                    children: [
                                      if (appStore.subscriptionPlanName.toLowerCase() != "${language.free}" && appStore.subscriptionPlanName.isNotEmpty)
                                        AppButton(
                                          height: 30,
                                          color: appBackground,
                                          text: language.cancel,
                                          textStyle: primaryTextStyle(),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          onTap: () => showCancelSubscriptionBottomSheet(context),
                                        ),
                                      if (appStore.subscriptionPlanName.toLowerCase() != "${language.free}" && appStore.subscriptionPlanName.isNotEmpty) 8.width,
                                      AppButton(
                                        height: 30,
                                        color: context.primaryColor,
                                        text: appStore.subscriptionPlanId.isNotEmpty ? language.upgrade : language.subscribe,

                                        textStyle: primaryTextStyle(),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        onTap: () {
                                          MembershipPlansScreen(selectedPlanId: appStore.subscriptionPlanId).launch(context).then((v) {
                                            if (v ?? false) getMemberShip();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      16.height,

                      /// Profile Section
                      Text(language.profile, style: boldTextStyle(size: textPrimarySizeGlobal.toInt(), fontFamily: GoogleFonts.roboto().fontFamily)).paddingSymmetric(horizontal: 16),
                      Observer(
                        builder: (_) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          padding: EdgeInsets.only(top: spacing_standard_new, bottom: spacing_standard_new),
                          decoration: BoxDecoration(color: appBackground, borderRadius: BorderRadius.all(Radius.circular(6))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CachedImageWidget(url: appStore.userProfileImage.validate(), height: 50, width: 50, circle: true, fit: BoxFit.cover).paddingSymmetric(horizontal: 8),
                              8.width.visible(appStore.userProfileImage!.isNotEmpty),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${appStore.userFirstName} ${appStore.userLastName}', style: boldTextStyle(size: textPrimarySizeGlobal.toInt(), fontFamily: GoogleFonts.roboto().fontFamily)),
                                  Text(appStore.userEmail.validate(), style: secondaryTextStyle(fontFamily: GoogleFonts.roboto().fontFamily, size: textSecondarySizeGlobal.toInt())),
                                ],
                              ).expand(),
                              InkWell(
                                onTap: () {
                                  EditProfileScreen().launch(context);
                                },
                                child: CachedImageWidget(url: ic_edit, height: 16, width: 16, color: context.iconColor, fit: BoxFit.cover),
                              ).paddingSymmetric(horizontal: 16),
                            ],
                          ),
                        ).visible(appStore.isLogging),
                      ),

                      /// Downloaded List Section
                      if (appStore.isLogging && (fragmentStore.isDownloadsLoading || appStore.downloadedItemList.isNotEmpty))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            headingWidViewAll(
                              context,
                              language.downloads,
                              showViewMore: appStore.downloadedItemList.length > 3,
                              callback: () async {},
                            ),
                            if (fragmentStore.isDownloadsLoading)
                              buildShimmerHorizontalList(
                                isLandscape: true,
                                isContinueWatch: true,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: 3,
                              )
                            else if (appStore.downloadedItemList.isNotEmpty)
                              ItemHorizontalList(
                                appStore.downloadedItemList.where((data) => data.userId == getIntAsync(USER_ID) && !data.isDeleted.validate()).map((data) => downloadDataToCommonData(data)).toList(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                isLandscape: true,
                                isForDownload: true,
                                onDeleteTap: (CommonDataListModel commonData) async {
                                  DownloadData? downloadData = appStore.downloadedItemList.firstWhere(
                                    (data) => data.id == commonData.id && data.title == commonData.title,
                                  );

                                  await showConfirmDialogCustom(
                                    context,
                                    primaryColor: colorPrimary,
                                    cancelable: false,
                                    onCancel: (c) {
                                      finish(c);
                                    },
                                    title: language.areYouSureYouWantToDeleteThisMovieFromDownloads,
                                    onAccept: (_) async {
                                      try {
                                        addOrRemoveFromLocalStorage(downloadData, isDelete: true);
                                        finish(context);
                                      } catch (e) {
                                        finish(context);
                                        log("Error : ${e.toString()}");
                                      }
                                    },
                                  );
                                },
                                onItemTap: (CommonDataListModel commonData) async {
                                  DownloadData? downloadData = appStore.downloadedItemList.firstWhere(
                                    (data) => data.id == commonData.id && data.title == commonData.title,
                                  );
                                  if (await checkPermission()) {
                                    LocalMediaPlayerScreen(data: downloadData).launch(context);
                                  }
                                },
                              ),
                            16.height,
                          ],
                        ),

                      /// Content List Section
                      if (appStore.isLogging)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Continue Watching Section
                            if (fragmentStore.continueWatch.isNotEmpty)
                              headingWidViewAll(
                                context,

                                language.continueWatching + " ${language.forText}" + ' ${appStore.userFirstName.capitalizeFirstLetter()}',
                                showViewMore: fragmentStore.continueWatch.validate().length > 4,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                callback: () async {
                                  ViewAllContinueWatchingScreen().launch(context);
                                },
                              ),
                            if (fragmentStore.isContinueWatchLoading)
                              buildShimmerHorizontalList(
                                isLandscape: true,
                                isContinueWatch: true,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: 3,
                              )
                            else if (fragmentStore.continueWatch.isNotEmpty)
                              ItemHorizontalList(
                                fragmentStore.continueWatch.validate(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                isContinueWatch: true,
                                isLandscape: true,
                                refreshContinueWatchList: () async {
                                  await getContinueList();
                                },
                              ),
                            16.height,

                            ///Watchlist Section
                            if (fragmentStore.randomWatchList.isNotEmpty)
                              headingWidViewAll(
                                context,
                                language.watchList,
                                showViewMore: fragmentStore.randomWatchList.validate().length > 3,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                callback: () async {
                                  WatchlistScreen().launch(context);
                                },
                              ),
                            if (fragmentStore.isWatchListLoading)
                              buildShimmerHorizontalList(
                                isLandscape: false,
                                isContinueWatch: false,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: 4,
                              )
                            else if (fragmentStore.randomWatchList.isNotEmpty)
                              ItemHorizontalList(
                                fragmentStore.randomWatchList.validate(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                isLandscape: false,
                                refreshContinueWatchList: () async {
                                  await getRandomWatchlistItems();
                                },
                              ),
                            16.height,

                            ///Reminders Section
                            if (fragmentStore.reminderList.isNotEmpty)
                              headingWidViewAll(
                                context,
                                '${language.yourReminders}',
                                showViewMore: fragmentStore.reminderList.validate().length > 3,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                callback: () async {
                                  ViewAllReminderListScreen().launch(context);
                                },
                              ),
                            if (fragmentStore.isReminderListLoading)
                              buildShimmerHorizontalList(
                                isLandscape: false,
                                isContinueWatch: false,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: 4,
                              )
                            else if (fragmentStore.reminderList.isNotEmpty)
                              ItemHorizontalList(
                                fragmentStore.reminderList.map((e) => reminderDataToCommonData(e)).toList(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                isLandscape: false,
                              ),
                          ],
                        ),
                      16.height,
                    ],
                  ),
                ),
                Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCancelSubscriptionBottomSheet(BuildContext context) {
    showCommonActionBottomSheet(
      context: context,
      title: '${language.areYouSureAbout}',
      subtitle: "${language.thisActionWillTerminate}",
      icon: cancelSub,
      positiveText: language.cancel,
      applyIconColor: false,
      negativeText: '${language.keepSubscription}',
      positiveOnTap: () async {
        finish(context);
        if (appStore.subscriptionPlanStatus == userPlanStatus) {
          appStore.setLoading(true);
          try {
            await cancelMembershipLevel(levelId: appStore.subscriptionPlanId.validate());
            await getMemberShip();
          } catch (e) {
            log("Error cancelling membership: ${e.toString()}");
            toast(language.somethingWentWrong);
          } finally {
            appStore.setLoading(false);
          }
        } else {
          toast('${language.noActiveSubscriptions}');
        }
      },
    );
  }
}
