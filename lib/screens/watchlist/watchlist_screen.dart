import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/watchlist/watchlist_tab_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class WatchlistScreen extends StatefulWidget {
  static String tag = '/WatchlistScreen';

  @override
  WatchlistScreenState createState() => WatchlistScreenState();
}

class WatchlistScreenState extends State<WatchlistScreen> with TickerProviderStateMixin {
  GlobalKey movieKey = GlobalKey();
  GlobalKey tvShowKey = GlobalKey();
  GlobalKey videoKey = GlobalKey();
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    watchlistStore.setUserId(getIntAsync(USER_ID));
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.watchList, style: boldTextStyle(size: default_appbar_size)),
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
        centerTitle: false,
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
        bottom: PreferredSize(
          preferredSize: Size(context.width(), 45),
          child: Align(
            alignment: Alignment.topLeft,
            child: TabBar(
              controller: tabController,
              indicatorPadding: const EdgeInsets.only(left: 30, right: 30),
              indicatorWeight: 0.0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
              indicatorColor: colorPrimary,
              indicator: TabIndicator(),
              unselectedLabelStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
              unselectedLabelColor: Theme.of(context).textTheme.titleLarge!.color,
              labelColor: colorPrimary,
              labelPadding: const EdgeInsets.only(left: spacing_large, right: spacing_large),
              onTap: (index) {
                watchlistStore.setSelectedTabIndex(index);
              },
              tabs: [
                Tab(child: Text(language.movies)),
                Tab(child: Text(language.tVShows)),
                Tab(child: Text(language.videos)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          WatchlistTabWidget(key: movieKey, postType: ReviewConst.reviewTypeMovie),
          WatchlistTabWidget(key: tvShowKey, postType: ReviewConst.reviewTypeTvShow),
          WatchlistTabWidget(key: videoKey, postType: ReviewConst.reviewTypeVideo),
        ],
      ),
    );
  }
}
