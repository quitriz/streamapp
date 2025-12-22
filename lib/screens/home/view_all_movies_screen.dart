import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home/movie_grid_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

// ignore: must_be_immutable
class ViewAllMoviesScreen extends StatefulWidget {
  static String tag = '/ViewAllMoviesScreen';
  int index;
  String? type;
  String? title;
  List<dynamic>? typeId = [];
  final PostType postType;

  ViewAllMoviesScreen(this.index, this.type, this.title, this.typeId, {this.postType = PostType.MOVIE});

  @override
  ViewAllMoviesScreenState createState() => ViewAllMoviesScreenState();
}

class ViewAllMoviesScreenState extends State<ViewAllMoviesScreen> {
  ScrollController scrollController = ScrollController();
  BannerAd? bannerAd;

  @override
  void initState() {
    super.initState();
    appStore.resetViewAllMoviesState();
    appStore.setViewAllMoviesTitle(widget.title ?? '');
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (appStore.canLoadMoreViewAllMovies) {
          appStore.incrementViewAllMoviesPage();
          appStore.setViewAllMoviesIsLoading(true);
          init();
        }
      }
    });
  }

  Future<void> init() async {
    bannerAd = buildBannerAds()..load();
    if (!appStore.viewAllMoviesIsLoading) {
      appStore.setViewAllMoviesIsLoading(true);
    }
    viewAll(
      widget.index,
      widget.type ?? dashboardTypeHome,
      page: appStore.viewAllMoviesPage,
      list: (widget.typeId is List) ? widget.typeId : [],
      postType: widget.postType,
    ).then((value) {
      appStore.setViewAllMoviesIsLoading(false);

      if (appStore.viewAllMoviesPage == 1) appStore.clearViewAllMoviesList();
      appStore.setViewAllMoviesIsLastPage(value.data!.length < postPerPage);

      appStore.setViewAllMoviesTitle(widget.title.validate());
      appStore.setViewAllMoviesList(value.data!, isRefresh: appStore.viewAllMoviesPage == 1);
    }).catchError((e) {
      log(e);
      appStore.setViewAllMoviesIsLoading(false);
      appStore.setViewAllMoviesHasError(true);
      appStore.setViewAllMoviesError(e.toString());
      toast(e.toString());
    });
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

  Widget buildShimmerGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(12, (index) {
        return CommonListItemShimmer(
          isVerticalList: true,
          isViewAll: true,
        );
      }),
    ).paddingAll(16);
  }

  @override
  void dispose() {
    scrollController.dispose();
    bannerAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(widget.title ?? appStore.viewAllMoviesTitle, style: primaryTextStyle(color: Colors.white, size: 22)),
        centerTitle: false,
        backgroundColor: appBackground,
      ),
      body: Container(
        height: context.height(),
        child: Observer(
          builder: (_) => Stack(
            children: [
              if (appStore.viewAllMoviesIsLoading && appStore.viewAllMoviesPage == 1)
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 70),
                  child: buildShimmerGrid(),
                )
              else
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 70),
                  child: MovieGridList(appStore.viewAllMoviesList),
                  controller: scrollController,
                ),
              if (appStore.viewAllMoviesPage != 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: LoadingDotsWidget(),
                ).visible(appStore.viewAllMoviesIsLoading),
              NoDataWidget(
                imageWidget: noDataImage(),
                title: '${appStore.viewAllMoviesTitle} ${language.notFound}',
                subTitle: '${language.the} ${appStore.viewAllMoviesTitle} ${language.hasNotYetBeenAdded}',
              ).center().visible(!appStore.viewAllMoviesIsLoading && appStore.viewAllMoviesList.isEmpty && !appStore.viewAllMoviesHasError),
              Text(errorSomethingWentWrong, style: boldTextStyle(color: Colors.white)).center().visible(appStore.viewAllMoviesHasError),
            ],
          ),
        ),
      ),
    );
  }
}
