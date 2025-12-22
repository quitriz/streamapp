import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/extentions/string_extentions.dart';

class ViewAllContinueWatchingScreen extends StatefulWidget {
  ViewAllContinueWatchingScreen();

  @override
  State<ViewAllContinueWatchingScreen> createState() => _ViewAllContinueWatchingScreenState();
}

class _ViewAllContinueWatchingScreenState extends State<ViewAllContinueWatchingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchContinueWatchData();
    });
  }

  ///Function to fetch Continue Watch Data
  Future<void> fetchContinueWatchData() async {
    appStore.startContinueWatchLoading();

    try {
      final future = getVideoContinueWatch(
        continueWatchList: appStore.continueWatchDataList,
        type: appStore.currentContinueWatchPostType,
        page: appStore.continueWatchPage,
        lastPageCallback: (isLastPage) {
          appStore.setContinueWatchIsLastPage(isLastPage);
        },
      );

      appStore.updateContinueWatchFuture(future);

      final data = await future;
      appStore.setContinueWatchDataList(data, isRefresh: appStore.continueWatchPage == 1);
    } catch (e) {
      appStore.setContinueWatchError(e.toString());
    } finally {
      appStore.stopContinueWatchLoading();
    }
  }

  Future<void> refreshContinueWatchData() async {
    appStore.refreshContinueWatchState();
    await fetchContinueWatchData();
  }

  Future<void> loadMoreContinueWatchData() async {
    if (!appStore.continueWatchIsLastPage) {
      appStore.incrementContinueWatchPage();
      await fetchContinueWatchData();
    }
  }

  Future<void> changeContinueWatchTab(int index) async {
    appStore.changeContinueWatchTab(index);
    await fetchContinueWatchData();
  }

  /// Shimmer Effect
  Widget buildShimmerGrid() {
    return Column(
      children: [
        HorizontalList(
          itemCount: 3,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade700,
              highlightColor: Colors.grey.shade600,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  width: 60,
                  height: 16,
                ),
              ),
            );
          },
        ),
        24.height,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(6, (index) {
            return CommonListItemShimmer(
              isLandscape: true,
              isContinueWatch: true,
            );
          }),
        ),
      ],
    ).paddingOnly(left: 16, right: 16, bottom: 30, top: 8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.continueWatching, style: primaryTextStyle(color: Colors.white, size: 22)),
        centerTitle: false,
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: Observer(
        builder: (_) => Stack(
          children: [
            SnapHelperWidget(
              future: appStore.continueWatchFuture,
              loadingWidget: buildShimmerGrid(),
              errorBuilder: (error) {
                return Observer(
                  builder: (_) => NoDataWidget(
                    imageWidget: noDataImage(),
                    title: appStore.continueWatchError ?? error,
                    subTitle: language.somethingWentWrong,
                    retryText: language.refresh,
                    onRetry: () {
                      refreshContinueWatchData();
                    },
                  ).center(),
                );
              },
              onSuccess: (data) {
                return Observer(
                  builder: (_) {
                    if (!appStore.hasContinueWatchData && !appStore.continueWatchIsLoading)
                      return NoDataWidget(
                        imageWidget: noDataImage(),
                        title: language.notFound,
                        retryText: language.watchNow,
                        onRetry: () {
                          finish(context);
                        },
                      ).center();
                    return AnimatedScrollView(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 8),
                      physics: AlwaysScrollableScrollPhysics(),
                      refreshIndicatorColor: colorPrimary,
                      onSwipeRefresh: () {
                        return refreshContinueWatchData();
                      },
                      onNextPage: () {
                        loadMoreContinueWatchData();
                      },
                      children: [
                        Observer(
                          builder: (_) => HorizontalList(
                            itemCount: appStore.continueWatchPostTypeList.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  changeContinueWatchTab(index);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  decoration: boxDecorationDefault(
                                    color: index == appStore.continueWatchCurrentTabIndex ? colorPrimary : context.cardColor,
                                    boxShadow: [],
                                  ),
                                  child: Text(appStore.continueWatchPostTypeList[index].title(),
                                      style: index == appStore.continueWatchCurrentTabIndex ? boldTextStyle(color: Colors.white) : primaryTextStyle()),
                                ),
                              );
                            },
                          ),
                        ),
                        24.height,
                        Observer(
                          builder: (_) => AnimatedWrap(
                            spacing: 8,
                            runSpacing: 8,
                            itemCount: appStore.continueWatchDataList.length,
                            itemBuilder: (p0, index) {
                              CommonDataListModel data = appStore.continueWatchDataList[index];
                              return CommonListItemComponent(
                                data: data,
                                isLandscape: true,
                                isContinueWatch: true,
                                onTap: null,
                                callback: () async {
                                  await showConfirmDialogCustom(context,
                                      primaryColor: colorPrimary,
                                      cancelable: false,
                                      onCancel: (c) {
                                        finish(c);
                                      },
                                      title: language.areYouSureYouWantToDeleteThisFromYourContinueWatching,
                                      onAccept: (_) async {
                                        finish(context);
                                        await deleteVideoContinueWatch(postId: data.id.validate(), postType: data.postType).then((v) {
                                          refreshContinueWatchData();
                                          LiveStream().emit(RefreshHome);
                                        }).catchError(onError);
                                      });
                                },
                              );
                            },
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
            Observer(
              builder: (_) => LoadingDotsWidget().visible(appStore.continueWatchIsLoading),
            ),
          ],
        ),
      ),
    );
  }
}
