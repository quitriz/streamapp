import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/notification_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> future;

  @override
  void initState() {
    fragmentStore.resetNotificationState();
    init();
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  init() {
    fragmentStore.setNotificationIsLastPage(false);
    fragmentStore.setNotificationPage(1);
    future = getList();
  }

  Future readNotification(String id) async {
    await readNotificationAdd(id).then((value) {
      init();
    }).catchError((e) {
      fragmentStore.setNotificationHasError(true);
      fragmentStore.setNotificationError(e.toString());
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<List<NotificationModel>> getList() async {
    // Prevent further API calls if last page is reached
    if (fragmentStore.notificationIsLastPage) {
      return fragmentStore.notificationList;
    }

    appStore.setLoading(true);

    try {
      List<NotificationModel> value = await getNotifications(page: fragmentStore.notificationPage);

      if (fragmentStore.notificationPage == 1) fragmentStore.clearNotificationList(); // Clear list if first page

      // If fetched items are less than `postPerPage`, it's the last page
      if (value.length < postPerPage) {
        fragmentStore.setNotificationIsLastPage(true);
      }

      fragmentStore.setNotificationList(value);
    } catch (e) {
      fragmentStore.setNotificationHasError(true);
      fragmentStore.setNotificationError(e.toString());
      toast(e.toString(), print: true);
    } finally {
      appStore.setLoading(false);
    }

    return fragmentStore.notificationList;
  }

  Future<void> clear() async {
    appStore.setLoading(true);
    await clearNotification().then((value) {
      fragmentStore.clearNotificationList();
      appStore.setLoading(false);
    }).catchError((e) {
      fragmentStore.setNotificationHasError(true);
      fragmentStore.setNotificationError(e.toString());
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.notifications, style: primaryTextStyle()),
        elevation: 0,
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
      ),
      body: DefaultTabController(
        length: 2,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<NotificationModel>>(
                  future: future,
                  builder: (ctx, snap) {
                    if (snap.hasError) {
                      return NoDataWidget(
                        imageWidget: noDataImage(),
                        title: language.somethingWentWrong,
                      ).center();
                    }

                    if (snap.hasData) {
                      if (snap.data.validate().isEmpty) {
                        return NoDataWidget(
                          imageWidget: noDataImage(),
                          title: language.noNotificationsFound,
                        ).center();
                      } else {
                        return AnimatedListView(
                          shrinkWrap: true,
                          slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 50),
                          itemCount: fragmentStore.notificationList.length,
                          itemBuilder: (context, index) {
                            NotificationModel notification = fragmentStore.notificationList[index];

                            return GestureDetector(
                              onTap: () async {
                                await readNotification(notification.notificationId.toString());

                                if (notification.postType == FirebaseMsgConst.movieKey) {
                                  MovieDetailScreen(movieData: CommonDataListModel(id: notification.id.isNotEmpty ? int.parse(notification.id.toString()) : 0, postType: PostType.MOVIE))
                                      .launch(context);
                                }
                              },
                              child: ColoredBox(
                                color: notification.status == "unread" ? context.cardColor : context.scaffoldBackgroundColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    (notification.action == "pmp_new_plan")
                                        ? Container(
                                            height: 50,
                                            width: 80,
                                            decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(defaultRadius)),
                                            child: CachedImageWidget(url: ic_notification, width: 42, height: 42, color: context.primaryColor),
                                          ).cornerRadiusWithClipRRect(defaultRadius)
                                        : CachedImageWidget(
                                            url: notification.imageUrl.validate(),
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(defaultRadius),
                                    20.width,
                                    Column(
                                      children: [
                                        Text(
                                          parseHtmlString(notification.message.validate()),
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(notification.metaMessage.validate(), style: secondaryTextStyle()),
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                    ).expand(),
                                  ],
                                ).paddingSymmetric(vertical: 8, horizontal: 16),
                              ),
                            );
                          },
                          onNextPage: () {
                            if (!fragmentStore.notificationIsLastPage) {
                              fragmentStore.incrementNotificationPage();
                              future = getList();
                            }
                          },
                        );
                      }
                    }
                    return Offstage();
                  },
                ).expand()
              ],
            ),
            Observer(
              builder: (_) {
                if (fragmentStore.notificationPage == 1) {
                  return LoaderWidget().center().visible(appStore.isLoading);
                } else {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: LoadingDotsWidget(),
                  ).visible(appStore.isLoading);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
