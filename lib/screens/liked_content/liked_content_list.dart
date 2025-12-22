import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/liked_content/liked_content_tab_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class LikedContentListScreen extends StatefulWidget {
  static String tag = '/LikedContentListScreen';

  @override
  LikedContentListScreenState createState() => LikedContentListScreenState();
}

class LikedContentListScreenState extends State<LikedContentListScreen> with TickerProviderStateMixin {
  late TabController tabController;
  GlobalKey movieKey = GlobalKey();
  GlobalKey videoKey = GlobalKey();
  GlobalKey tvShowKey = GlobalKey();
  GlobalKey episodeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    likedContentStore.setUserId(getIntAsync(USER_ID));
    likedContentStore.setSelectedTabIndex(0);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget chipButton(String title, int index) {
    return Observer(
      builder: (_) {
        bool isSelected = likedContentStore.selectedTabIndex == index;
        return GestureDetector(
          onTap: () {
            likedContentStore.setSelectedTabIndex(index);
            tabController.animateTo(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? colorPrimary : appBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSelected ? colorPrimary : borderColor, width: 1),
            ),
            child: Text(
              title,
              style: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(language.likedByYou, style: boldTextStyle(size: 18)),
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
        bottom: PreferredSize(
          preferredSize: Size(context.width(), 70),
          child: Container(
            color: appBackground,
            padding: EdgeInsets.symmetric(horizontal: context.width() > 400 ? 24 : 16, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorWeight: 0.0,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                tabAlignment: TabAlignment.start,
                onTap: (index) {
                  likedContentStore.setSelectedTabIndex(index);
                },
                labelPadding: EdgeInsets.only(right: context.width() > 400 ? 16 : 12),
                tabs: [
                  chipButton(language.movies, 0),
                  chipButton(language.videos, 1),
                  chipButton(language.tVShows, 2),
                  chipButton(language.episodes, 3),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          LikedContentTabWidget(key: movieKey, postType: ReviewConst.reviewTypeMovie),
          LikedContentTabWidget(key: videoKey, postType: ReviewConst.reviewTypeVideo),
          LikedContentTabWidget(key: tvShowKey, postType: ReviewConst.reviewTypeTvShow),
          LikedContentTabWidget(key: episodeKey, postType: ReviewConst.reviewTypeEpisode),
        ],
      ),
    );
  }
}



