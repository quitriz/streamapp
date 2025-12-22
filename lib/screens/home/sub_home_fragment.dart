import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/components/item_horizontal_list.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/dashboard_response.dart' as Model;
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home/dashboard_slider_widget.dart';
import 'package:streamit_flutter/screens/home/view_all_continue_watchings_screen.dart';
import 'package:streamit_flutter/screens/home/view_all_movies_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/cached_data.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SubHomeFragment extends StatefulWidget {
  static String tag = '/SubHomeFragment';
  final String? type;

  SubHomeFragment({this.type});

  @override
  SubHomeFragmentState createState() => SubHomeFragmentState();
}

class SubHomeFragmentState extends State<SubHomeFragment> with AutomaticKeepAliveClientMixin {
  late Future<Model.DashboardResponse> future;
  final GlobalKey<DashboardSliderWidgetState> _dashboardSliderKey = GlobalKey<DashboardSliderWidgetState>();

  @override
  void initState() {
    init();
    ScreenProtector.preventScreenshotOn();
    super.initState();
    LiveStream().on(RefreshHome, (p0) {
      init();
    });
  }

  Future<void> init() async {
    final typeKey = widget.type.validate(value: dashboardTypeHome);
    final dashFuture = getDashboardData({}, type: typeKey).then((v) {
      DashboardCachedData.storeData(dashboardTypeKey: widget.type.validate(), data: v.toJson());
      return v;
    }).catchError((e) {
      throw e;
    });

    future = dashFuture;
    fragmentStore.setDashboardFuture(typeKey, dashFuture);

    if (appStore.isLogging) {
      _loadContinueWatchData();
    }
  }

  Future<void> _loadContinueWatchData() async {
    try {
      await getVideoContinueWatch(
        continueWatchList: appStore.continueWatchDataList,
        type: '',
        page: 1,
        lastPageCallback: (isLastPage) {
          appStore.setContinueWatchIsLastPage(isLastPage);
        },
      );
    } catch (e) {
      log('Error loading continue watch data: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  PostType detectPostTypeFromSlider(Model.Slider slider) {
    try {
      return slider.data.validate().isNotEmpty ? slider.data!.first.postType : PostType.NONE;
    } catch (e) {
      log("Failed to detect postType for slider '${slider.title}': $e");
      return PostType.NONE;
    }
  }

  List<CommonDataListModel> filterLikedByType(List<CommonDataListModel> likedList, String? fragmentType) {
    if (fragmentType == null || fragmentType == dashboardTypeHome) return likedList;

    PostType targetType;
    switch (fragmentType) {
      case ReviewConst.reviewTypeMovie:
        targetType = PostType.MOVIE;
        break;
      case ReviewConst.reviewTypeVideo:
        targetType = PostType.VIDEO;
        break;
      case ReviewConst.reviewTypeTvShow:
        targetType = PostType.TV_SHOW;
        break;
      default:
        return likedList;
    }

    return likedList.where((item) => item.postType == targetType).toList();
  }

  Widget buildShimmerHorizontalList({required bool isLandscape, bool isContinueWatch = false, EdgeInsets? padding, int itemCount = 5}) {
    return Container(
      width: context.width(),
      alignment: Alignment.centerLeft,
      child: HorizontalList(
        itemCount: itemCount,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return CommonListItemShimmer(isLandscape: isLandscape, isContinueWatch: isContinueWatch);
        },
      ),
    );
  }

  Widget buildShimmerSlider() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade600,
      child: Container(
        height: 200,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget buildShimmerSection({String title = "Loading...", required Widget shimmerList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade700,
          highlightColor: Colors.grey.shade600,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            height: 20,
            width: 150,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ),
        shimmerList,
      ],
    );
  }

  Widget buildLoadingShimmer() {
    return Observer(
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for banner/slider
              buildShimmerSlider(),

              // Shimmer for continue watching section
              if (appStore.isLogging)
                buildShimmerSection(
                  title: "${language.continueWatching}",
                  shimmerList: buildShimmerHorizontalList(isLandscape: true, isContinueWatch: true, itemCount: 3),
                ).visible(!appStore.hasInFullScreen),

              // Shimmer for multiple content sections
              ...List.generate(
                4,
                (index) => buildShimmerSection(
                  title: "${language.loadingSection} ${index + 1}",
                  shimmerList: buildShimmerHorizontalList(isLandscape: false, isContinueWatch: false, itemCount: 5),
                ).visible(!appStore.hasInFullScreen),
              ),

              // Shimmer for liked section
              if (appStore.isLogging)
                buildShimmerSection(title: language.likedByYou, shimmerList: buildShimmerHorizontalList(isLandscape: false, isContinueWatch: false, itemCount: 4)).visible(!appStore.hasInFullScreen),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
    LiveStream().dispose(RefreshHome);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await coreStore.refresh();
        } catch (e) {
          log('Failed to refresh core settings: $e');
        }
        await init();
        await 2.seconds.delay;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: cardColor,
        body: Container(
          alignment: Alignment.topCenter,
          child: SnapHelperWidget<Model.DashboardResponse>(
            initialData: DashboardCachedData.getData(dashboardTypeKey: widget.type.validate()),
            future: fragmentStore.getDashboardFuture(widget.type.validate(value: dashboardTypeHome)) ?? future,
            loadingWidget: buildLoadingShimmer(),
            errorBuilder: (p0) {
              return NoDataWidget(imageWidget: noDataImage(), title: '${language.noData}', subTitle: language.somethingWentWrong);
            },
            onSuccess: (data) {
              if (data.banner.validate().isEmpty && data.sliders.validate().isEmpty && data.continueWatch.validate().isEmpty && data.liked.validate().isEmpty)
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: '${language.no} ${widget.type.validate() == 'home' ? '${language.content}' : widget.type.validate()} ${language.found}',
                  subTitle: '${language.the} ${widget.type.validate() == 'home' ? '${language.content}' : widget.type.validate()} ${language.hasNotYetBeenAdded}',
                );
              return Observer(
                builder: (context) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.banner.validate().isNotEmpty)
                          VisibilityDetector(
                            key: Key('dashboard-slider-${widget.type ?? 'home'}'),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction == 0) {
                                _dashboardSliderKey.currentState?.pauseVideo();
                              } else {
                                _dashboardSliderKey.currentState?.resumeVideo();
                              }
                            },
                            child: DashboardSliderWidget(
                              key: _dashboardSliderKey,
                              mSliderList: data.banner.validate(),
                            ),
                          ),
                        if (appStore.isLogging)
                          Observer(
                            builder: (_) => appStore.continueWatchDataList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      headingWidViewAll(
                                        context,
                                        language.continueWatching,
                                        showViewMore: appStore.continueWatchDataList.length > 4,
                                        callback: () async {
                                          LiveStream().emit(PauseVideo);
                                          ViewAllContinueWatchingScreen().launch(context);
                                        },
                                      ),
                                      ItemHorizontalList(
                                        appStore.continueWatchDataList,
                                        isContinueWatch: true,
                                        isLandscape: true,
                                        isLiveTv: false,
                                        refreshContinueWatchList: () {
                                          init();
                                        },
                                      ),
                                    ],
                                  ).visible(!appStore.hasInFullScreen)
                                : SizedBox.shrink(),
                          ),
                        Column(
                          children: data.sliders.validate().map((e) {
                            if (e.data.validate().isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  headingWidViewAll(
                                    context,
                                    e.title.validate(),
                                    callback: () async {
                                      LiveStream().emit(PauseVideo);
                                      await ViewAllMoviesScreen(
                                        data.sliders!.indexOf(e),
                                        e.type.toString(),
                                        e.title.validate(),
                                        e.type.toString() != 'latest' ? e.ids : [],
                                        postType: detectPostTypeFromSlider(e),
                                      ).launch(context);
                                    },
                                    showViewMore: e.viewAll.validate(),
                                  ),
                                  ItemHorizontalList(
                                    e.data.validate(),
                                    isTop10: e.type.validate() == 'top_ten',
                                    isContinueWatch: false,
                                    isLandscape: e.postType == PostType.CHANNEL,
                                    isLiveTv: e.postType == PostType.CHANNEL,
                                  ),
                                ],
                              );
                            } else {
                              return Offstage();
                            }
                          }).toList(),
                        ).visible(!appStore.hasInFullScreen),
                        if (data.liked.validate().isNotEmpty && appStore.isLogging)
                          Builder(
                            builder: (context) {
                              final filteredLiked = filterLikedByType(data.liked.validate(), widget.type);
                              if (filteredLiked.isEmpty) return Offstage();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  headingWidViewAll(context, language.likedByYou, showViewMore: false, callback: () {}),
                                  ItemHorizontalList(filteredLiked, isContinueWatch: false, isLandscape: false, isLiveTv: false),
                                ],
                              );
                            },
                          ).visible(!appStore.hasInFullScreen),
                      ],
                    ),
                  );
                },
              );
            },
          ).makeRefreshable,
        ),
      ),
    );
  }
}
