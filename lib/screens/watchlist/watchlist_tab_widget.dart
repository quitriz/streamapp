import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/utils/common.dart';

class WatchlistTabWidget extends StatefulWidget {
  final String postType;
  final Function()? onRefresh;

  const WatchlistTabWidget({Key? key, required this.postType, this.onRefresh}) : super(key: key);

  WatchlistTabWidgetState createState() => WatchlistTabWidgetState();
}

class WatchlistTabWidgetState extends State<WatchlistTabWidget> {
  ScrollController scrollController = ScrollController();
  BannerAd? bannerAd;
  Random random = Random();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!watchlistStore.isLastPageByType(widget.postType)) {
          watchlistStore.loadMoreWatchlist(widget.postType);
        }
      }
    });

    init();
  }

  init() async {
    watchlistStore.loadWatchlist(widget.postType);
    bannerAd = buildBannerAds()..load();
  }

  BannerAd buildBannerAds() {
    return BannerAd(
      size: AdSize.banner,
      request: AdRequest(),
      adUnitId: mAdMobBannerId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        //
      }),
    );
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Stack(
          children: [
            if (watchlistStore.getWatchlistByType(widget.postType).isNotEmpty)
              SizedBox(
                height: context.height(),
                width: context.width(),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 65),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: watchlistStore.getWatchlistByType(widget.postType).map((e) {
                          CommonDataListModel data = e;

                          return CommonListItemComponent(
                            data: e,
                            isVerticalList: true,
                            isWatchList: true,
                            isViewAll: true,
                            callback: () {
                              if (!mIsLoggedIn) {
                                SignInScreen(
                                  redirectTo: () {
                                    watchlistStore.refreshWatchlist(widget.postType);
                                  },
                                ).launch(context);
                                return;
                              } else {
                                toast(language.pleaseWait);
                                watchlistStore.removeFromWatchlist(widget.postType, data).then((value) {
                                  widget.onRefresh?.call();
                                }).catchError((e) {
                                  log(e.toString());
                                  toast(e.toString());
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      controller: scrollController,
                    ),
                    if (bannerAd != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(height: AdSize.banner.height.toDouble(), width: context.width(), child: AdWidget(ad: bannerAd!)),
                      ),
                  ],
                ),
              ).paddingAll(16),
            if (watchlistStore.getWatchlistByType(widget.postType).isEmpty && !watchlistStore.isLoadingByType(widget.postType) && !watchlistStore.hasErrorByType(widget.postType))
              NoDataWidget(imageWidget: noDataImage(), title: language.yourWatchListIsEmpty, subTitle: language.keepTrackOfEverything).paddingSymmetric(horizontal: 50).center(),
            if (watchlistStore.hasErrorByType(widget.postType) && !watchlistStore.isLoadingByType(widget.postType))
              NoDataWidget(imageWidget: noDataImage(), title: language.somethingWentWrong).center(),
            if (watchlistStore.isLoadingByType(widget.postType) && watchlistStore.getWatchlistByType(widget.postType).isEmpty && watchlistStore.getCurrentPage(widget.postType) == 1)
              SizedBox(
                height: context.height(),
                width: context.width(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 65),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (index) {
                      return CommonListItemShimmer(isVerticalList: true, isViewAll: true);
                    }),
                  ),
                ),
              ).paddingAll(16)
            else if (watchlistStore.isLoadingByType(widget.postType) && watchlistStore.getCurrentPage(widget.postType) > 1)
              Positioned(right: 0, left: 0, bottom: 8, child: LoadingDotsWidget()),
          ],
        );
      },
    );
  }
}
