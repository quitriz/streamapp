import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/genre/genrelist_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class GenreFragment extends StatefulWidget {
  static String tag = '/Genre Fragment';

  @override
  GenreFragmentState createState() => GenreFragmentState();
}

class GenreFragmentState extends State<GenreFragment> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = genreStore.genreSelectedTabIndex;
    genreStore.resetGenreState();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index != genreStore.genreSelectedTabIndex) {
        genreStore.setGenreSelectedTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Custom Chip-style button widget
  Widget chipButton(String title, int index) {
    return Observer(
      builder: (context) {
        bool isSelected = genreStore.genreSelectedTabIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              genreStore.setGenreSelectedTabIndex(index);
              _tabController.animateTo(index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? colorPrimary : appBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isSelected ? colorPrimary : borderColor, width: 1),
              ),
              child: Text(title, textAlign: TextAlign.center, style: boldTextStyle(size: textSecondarySizeGlobal.toInt())),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        leading: CachedImageWidget(url: appLogo, height: 32, width: 32, fit: BoxFit.cover),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size(context.width(), 60),
          child: Container(
            color: cardColor,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                chipButton(language.movies, 0),
                12.width,
                chipButton(language.tVShows, 1),
                12.width,
                chipButton(language.videos, 2),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          GenreListScreen(type: dashboardTypeMovie),
          GenreListScreen(type: dashboardTypeTVShow),
          GenreListScreen(type: dashboardTypeVideo),
        ],
      ).makeRefreshable,
    );
  }
}
