import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/genre_data.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/genre/genre_grid_list_widget.dart';
import 'package:streamit_flutter/utils/cached_data.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class GenreListScreen extends StatefulWidget {
  static String tag = '/GenreListScreen';
  final String? type;

  GenreListScreen({this.type});

  @override
  GenreListScreenState createState() => GenreListScreenState();
}

class GenreListScreenState extends State<GenreListScreen> {
  Future<List<GenreData>>? future;
  ScrollController scrollController = ScrollController();

  String get currentType => widget.type ?? dashboardTypeMovie;

  @override
  void initState() {
    super.initState();
    genreStore.initializeGenreListType(currentType);
    init(showLoader: true);
  }

  Future<void> init({bool showLoader = false}) async {
    try {
      if (showLoader) {
        genreStore.setGenreListLoading(currentType, true);
      }

      final currentPage = genreStore.getGenreListCurrentPage(currentType);
      final currentList = genreStore.getGenreListByType(currentType);
      final isLastPage = genreStore.isGenreListLastPage(currentType);

      final data = await getGenreList(
          type: widget.type,
          page: currentPage,
          genreDataList: currentList.toList(),
          isLast: isLastPage,
          lastPageCallback: (isLast) {
            genreStore.setGenreListLastPage(currentType, isLast);
          });

      genreStore.setGenreListData(currentType, data, isRefresh: currentPage == 1);
      genreStore.setGenreListError(currentType, false);
    } catch (e) {
      genreStore.setGenreListError(currentType, true);
      log('Error loading genre list: $e');
    } finally {
      genreStore.setGenreListLoading(currentType, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: Container(
        height: context.height(),
        child: Stack(
          children: [
            SnapHelperWidget(
              future: future,
              key: UniqueKey(),
              initialData: GenreCachedData.getData(dashboardTypeKey: widget.type.validate()),
              loadingWidget: Observer(builder: (_) => GenreItemListShimmer().visible(genreStore.isGenreListLoading(currentType) && genreStore.isGenreListEmpty(currentType))),
              errorBuilder: (p0) {
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.noGenresFound,
                  onRetry: () {
                    genreStore.resetGenreListState(currentType);
                    init(showLoader: true);
                  },
                );
              },
              onSuccess: (list) {
                return Observer(
                  builder: (context) {
                    final currentGenreList = genreStore.getGenreListByType(currentType);
                    final isLastPage = genreStore.isGenreListLastPage(currentType);

                    return AnimatedScrollView(
                      listAnimationType: ListAnimationType.None,
                      padding: EdgeInsets.only(bottom: isLastPage ? 80 : 0),
                      onNextPage: () {
                        if (!isLastPage && !genreStore.isGenreListLoading(currentType)) {
                          final nextPage = genreStore.getGenreListCurrentPage(currentType) + 1;
                          genreStore.setGenreListCurrentPage(currentType, nextPage);
                          init(showLoader: true);
                        }
                      },
                      onSwipeRefresh: () async {
                        genreStore.setGenreListCurrentPage(currentType, 1);
                        genreStore.setGenreListLastPage(currentType, false);
                        init(showLoader: true);
                        return await 2.seconds.delay;
                      },
                      children: [GenreItemListWidget(currentGenreList.toList(), widget.type.validate())],
                    );
                  },
                );
              },
            ),
            Observer(
              builder: (context) {
                return Positioned(
                  right: 0,
                  left: 0,
                  bottom: 8,
                  child: LoadingDotsWidget(),
                ).visible(genreStore.isGenreListLoading(currentType) && !genreStore.isGenreListEmpty(currentType));
              },
            )
          ],
        ),
      ),
    );
  }
}
