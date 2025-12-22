import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/live_tv/screens/channel_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class GenreMovieListScreen extends StatefulWidget {
  static String tag = '/GenreMovieListScreen';
  final String? genre;
  final String? type;
  final String slug;

  GenreMovieListScreen({this.genre, this.type, required this.slug});

  @override
  GenreMovieListScreenState createState() => GenreMovieListScreenState();
}

class GenreMovieListScreenState extends State<GenreMovieListScreen> {
  ScrollController scrollController = ScrollController();

  String get listKey => genreStore.getGenreMovieListKey(widget.slug, widget.type ?? dashboardTypeMovie);

  @override
  void initState() {
    super.initState();
    genreStore.initializeGenreMovieListType(listKey);

    afterBuildCreated(() {
      init();
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (genreStore.canGenreMovieListLoadMore(listKey) && !genreStore.isGenreMovieListLoading(listKey)) {
          final nextPage = genreStore.getGenreMovieListCurrentPage(listKey) + 1;
          genreStore.setGenreMovieListCurrentPage(listKey, nextPage);
          init();
        }
      }
    });
  }

  Future<void> init() async {
    try {
      if (await isNetworkAvailable()) {
        genreStore.setGenreMovieListLoading(listKey, true);
        genreStore.setGenreMovieListError(listKey, false);

        final currentPage = genreStore.getGenreMovieListCurrentPage(listKey);
        final data = await getMovieListByGenre(widget.slug, widget.type!, currentPage);

        genreStore.setGenreMovieListData(listKey, data, isRefresh: currentPage == 1);
        genreStore.setGenreMovieListLoadMore(listKey, data.length == postPerPage);
      } else {
        genreStore.setGenreMovieListError(listKey, true);
      }
    } catch (error) {
      genreStore.setGenreMovieListError(listKey, true);
      log(error.toString());
    } finally {
      genreStore.setGenreMovieListLoading(listKey, false);
    }
  }

  Widget buildShimmerGrid() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(12, (index) {
          return CommonListItemShimmer(
            isVerticalList: widget.type != dashboardTypeLive,
            isLandscape: widget.type == dashboardTypeLive,
            isViewAll: true,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(parseHtmlString(widget.genre!.validate().capitalizeFirstLetter()), style: boldTextStyle()),
        backgroundColor: appBackground,
        centerTitle: false,
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
        surfaceTintColor: context.scaffoldBackgroundColor,
      ),
      body: Observer(builder: (context) {
        return Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                    children: genreStore.getGenreMovieListByKey(listKey).map((e) {
                    return CommonListItemComponent(
                      data: e,
                      isVerticalList: widget.type != dashboardTypeLive,
                      isLandscape: widget.type == dashboardTypeLive,
                      isLive: widget.type == dashboardTypeLive,
                      onTap: widget.type == dashboardTypeLive
                          ? () {
                              ChannelDetailScreen(channelId: e.id.validate()).launch(context);
                            }
                          : null,
                      isViewAll: true,
                    );
                  }).toList(),
                ),
              ),
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.noContentFound,
                subTitle: language.theContentHasNot,
              ).center().visible(!genreStore.isGenreMovieListLoading(listKey) && genreStore.isGenreMovieListEmpty(listKey) && !genreStore.hasGenreMovieListError(listKey)),
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.noContentFound,
                subTitle: language.somethingWentWrong,
              ).center().visible(!genreStore.isGenreMovieListLoading(listKey) && genreStore.isGenreMovieListEmpty(listKey) && genreStore.hasGenreMovieListError(listKey)),
              buildShimmerGrid().visible(genreStore.isGenreMovieListLoading(listKey) && genreStore.isGenreMovieListEmpty(listKey)),
            ],
          ),
        );
      }),
    );
  }
}
