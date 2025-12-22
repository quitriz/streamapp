import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/blog/screens/blog_list_screen.dart';
import 'package:streamit_flutter/screens/home/sub_home_fragment.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class HomeFragment extends StatefulWidget {
  static String tag = '/HomeFragment';

  @override
  HomeFragmentState createState() => HomeFragmentState();
}

class HomeFragmentState extends State<HomeFragment> with SingleTickerProviderStateMixin {
  Future<String>? logoFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    logoFuture = _getLogoUrl();

    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: fragmentStore.homeTabIndex,
    );

    _tabController.animation?.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (fragmentStore.homeTabIndex != newIndex) {
        fragmentStore.setHomeTabIndex(newIndex);
        if (newIndex == 0) {
          LiveStream().emit(RefreshHome);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _getLogoUrl() async {
    if (appStore.hasValidApiLogo) {
      return appStore.appLogo.validate();
    }
    return ic_logo;
  }

  Future<void> getMemberShip() async {
    await getMembershipLevelForUser(userId: getIntAsync(USER_ID)).then((value) {
      if (value != null) {
        fragmentStore.setHasMembership(value != false);
        appStore.setLoading(false);
      } else {
        fragmentStore.setHasMembership(false);
        appStore.setLoading(false);
      }
    });
  }

  Widget chipTab(String title, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? colorPrimary : appBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? colorPrimary : borderColor, width: 1),
      ),
      child: Text(
        title,
        style: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) =>
          Scaffold(
            appBar: !appStore.hasInFullScreen
                ? AppBar(
              backgroundColor: appBackground,
              leading: FutureBuilder<String>(
                future: logoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CachedImageWidget(url: appLogo, height: 32, width: 32, fit: BoxFit.contain);
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return CachedImageWidget(url: appLogo, height: 32, width: 32, fit: BoxFit.contain);
                  } else {
                    String logoUrl = snapshot.data!;
                    if (logoUrl.startsWith('http://') || logoUrl.startsWith('https://')) {
                      return CachedNetworkImage(
                        imageUrl: logoUrl,
                        height: 32,
                        width: 32,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => CachedImageWidget(url: appLogo, height: 32, width: 32, fit: BoxFit.contain),
                      );
                    } else {
                      return CachedImageWidget(url: appLogo, height: 32, width: 32, fit: BoxFit.contain);
                    }
                  }
                },
              ),
              automaticallyImplyLeading: false,
              actions: [
                InkWell(
                  radius: 8,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    BlogListScreen().launch(context);
                  },
                  child: CachedImageWidget(
                    url: ic_blog,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    height: 24,
                    width: 24,
                  ),
                ).paddingSymmetric(horizontal: 8, vertical: 16),
                InkWell(
                  onTap: () {
                    MembershipPlansScreen(selectedPlanId: appStore.subscriptionPlanId).launch(context).then((v) {
                      if (v ?? false) getMemberShip();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: subscriptionColor.withValues(alpha: 0.3),
                      border: Border.all(color: subscriptionColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      appStore.subscriptionPlanId.isNotEmpty ? '${language.upgrade}' : '${language.subscribe}',
                      style: primaryTextStyle(color: subscriptionColor, size: textSecondarySizeGlobal.toInt()),
                    ),
                  ),
                ).visible(appStore.isLogging).paddingSymmetric(horizontal: 8),
              ],
              bottom: PreferredSize(
                preferredSize: Size(context.width(), 70),
                child: Container(
                  color: cardColor,
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 8),
                  child: AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (context, _) {
                      final currentIndex = _tabController.index;
                      return TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        indicatorWeight: 0.0,
                        indicator: BoxDecoration(),
                        tabAlignment: TabAlignment.start,
                        onTap: (i) {
                          fragmentStore.setHomeTabIndex(i);
                          if (i == 0) LiveStream().emit(RefreshHome);
                        },
                        labelPadding: EdgeInsets.only(right: context.width() > 400 ? 16 : 12),
                        tabs: [
                          chipTab(language.home, currentIndex == 0),
                          chipTab(language.movies, currentIndex == 1),
                          chipTab(language.tVShows, currentIndex == 2),
                          chipTab(language.videos, currentIndex == 3),
                        ],
                      );
                    },
                  ),
                ),
              ),
            )
                : null,
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                SubHomeFragment(type: dashboardTypeHome),
                SubHomeFragment(type: dashboardTypeMovie),
                SubHomeFragment(type: dashboardTypeTVShow),
                SubHomeFragment(type: dashboardTypeVideo),
              ],
            ),
          ),
    );
  }
}
