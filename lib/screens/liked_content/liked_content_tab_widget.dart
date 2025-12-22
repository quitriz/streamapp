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

class LikedContentTabWidget extends StatefulWidget {
  final String postType;
  final Function()? onRefresh;

  const LikedContentTabWidget({Key? key, required this.postType, this.onRefresh}) : super(key: key);

  @override
  LikedContentTabWidgetState createState() => LikedContentTabWidgetState();
}

class LikedContentTabWidgetState extends State<LikedContentTabWidget> {
  final ScrollController scrollController = ScrollController();
  BannerAd? bannerAd;
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!likedContentStore.isLastPageByType(widget.postType)) {
          likedContentStore.loadMoreLikedContent(widget.postType);
        }
      }
    });

    init();
  }

  Future<void> init() async {
    if (mIsLoggedIn) {
      await likedContentStore.loadLikedContent(widget.postType, isRefresh: true);
    } else {
      likedContentStore.clearLikedContent(widget.postType);
    }
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
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mIsLoggedIn) {
      return Center(
        child: NoDataWidget(
          imageWidget: noDataImage(),
          title: language.pleaseLoginToSearch,
        ).paddingSymmetric(horizontal: 50),
      );
    }

    return Observer(
      builder: (_) {
        return Stack(
          children: [
            if (likedContentStore.getLikedContentByType(widget.postType).isNotEmpty)
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
                        children: likedContentStore.getLikedContentByType(widget.postType).map((e) {
                          CommonDataListModel data = e;

                          return CommonListItemComponent(
                            data: e,
                            isVerticalList: true,
                            isWatchList: true,
                            isViewAll: true,
                            refresh: () {
                              likedContentStore.refreshLikedContent(widget.postType);
                            },
                            callback: () {
                              if (!mIsLoggedIn) {
                                SignInScreen(
                                  redirectTo: () {
                                    likedContentStore.refreshLikedContent(widget.postType);
                                  },
                                ).launch(context);
                                return;
                              } else {
                                toast(language.pleaseWait);
                                likedContentStore.removeFromLikedContent(widget.postType, data).then((value) {
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
            if (likedContentStore.getLikedContentByType(widget.postType).isEmpty && !likedContentStore.isLoadingByType(widget.postType) && !likedContentStore.hasErrorByType(widget.postType))
              NoDataWidget(imageWidget: noDataImage(), title: language.noDataFound).paddingSymmetric(horizontal: 50).center(),
            if (likedContentStore.hasErrorByType(widget.postType) && !likedContentStore.isLoadingByType(widget.postType))
              NoDataWidget(imageWidget: noDataImage(), title: language.somethingWentWrong).center(),
            if (likedContentStore.isLoadingByType(widget.postType) && likedContentStore.getLikedContentByType(widget.postType).isEmpty && likedContentStore.getCurrentPage(widget.postType) == 1)
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
            else if (likedContentStore.isLoadingByType(widget.postType) && likedContentStore.getCurrentPage(widget.postType) > 1)
              Positioned(right: 0, left: 0, bottom: 8, child: LoadingDotsWidget()),
          ],
        );
      },
    );
  }
}

