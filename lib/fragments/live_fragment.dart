import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/components/live_tv_slider_component.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_tv_category_item_component.dart';
import 'package:streamit_flutter/screens/live_tv/screens/view_all_live_tv_channels.dart';
import 'package:streamit_flutter/screens/live_tv/screens/view_live_tv_category_channels.dart';

import '../components/item_horizontal_list.dart';
import '../main.dart';
import '../models/dashboard_response.dart';
import '../models/live_tv/live_category_list_model.dart';
import '../network/rest_apis.dart';
import '../screens/live_tv/screens/view_all_live_tv_categories.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';
import '../utils/constants.dart';

class LiveFragment extends StatefulWidget {
  const LiveFragment({Key? key}) : super(key: key);

  @override
  _LiveFragmentState createState() => _LiveFragmentState();
}

class _LiveFragmentState extends State<LiveFragment> {
  ScrollController controller = ScrollController();
  PageController sliderController = PageController();

  int currentSliderIndex = 0;

  late Future<DashboardResponse> future;
  Future<AllLiveCategoryList>? liveCategoryFuture;

  @override
  void initState() {
    ScreenProtector.preventScreenshotOn();
    init();
    super.initState();
  }

  Future<void> init({bool showLoader = false}) async {
    appStore.setLoading(true);
    final dashFuture = getDashboardData({}, type: dashboardTypeLive).then((v) {
      appStore.setLoading(false);
      return v;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
    future = dashFuture;
    fragmentStore.setDashboardFuture(dashboardTypeLive, dashFuture);
    liveCategoryFuture = getLiveCategoryList();
    fragmentStore.liveCategoryFuture = liveCategoryFuture;
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await init();
        return await 2.seconds.delay;
      },
      child: Scaffold(
        backgroundColor: CupertinoColors.black,
        appBar: AppBar(
          title: Text(language.liveTV, style: boldTextStyle(color: Colors.white, size: 20)),
          automaticallyImplyLeading: false,
          centerTitle: false,
          surfaceTintColor: CupertinoColors.black,
          systemOverlayStyle: defaultSystemUiOverlayStyle(
            context,
            color: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Stack(
          children: [
            SnapHelperWidget(
              future: fragmentStore.getDashboardFuture(dashboardTypeLive) ?? future,
              loadingWidget: Offstage(),
              onSuccess: (data) {
                return Column(
                  children: [
                    SizedBox(
                      height: context.height() * 0.35,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemBuilder: (context, index) {
                              return LiveTvSliderComponent(sliderData: data.banner.validate()[index]);
                            },
                            controller: sliderController,
                            itemCount: data.banner.validate().length,
                            allowImplicitScrolling: true,
                            pageSnapping: true,
                            onPageChanged: (page) {
                              currentSliderIndex = page;
                              sliderController.animateToPage(page, duration: Duration(milliseconds: 1000), curve: Curves.ease);
                            },
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                data.banner.validate().length,
                                (index) {
                                  return InkWell(
                                    onTap: () {
                                      currentSliderIndex = index;
                                      sliderController.animateToPage(index, duration: Duration(milliseconds: 1000), curve: Curves.ease);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(4),
                                      padding: EdgeInsets.all(currentSliderIndex == index ? 5 : 4),
                                      decoration: boxDecorationDefault(
                                        shape: BoxShape.circle,
                                        color: currentSliderIndex == index ? Colors.white : Colors.white54,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: EdgeInsets.only(bottom: 60),
                        children: [
                          16.height,
                          headingWidViewAll(
                            context,
                            language.channelCategories,
                            showViewMore: true,
                            callback: () {
                              ViewAllLiveTvCategories().launch(context);
                            },
                          ),
                          SnapHelperWidget(
                            future: liveCategoryFuture,
                            loadingWidget: Offstage(),
                            onSuccess: (AllLiveCategoryList categoryList) {
                              return SizedBox(
                                height: 90,
                                child: HorizontalList(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: categoryList.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final category = categoryList.data![index];
                                    return LiveTvCategoryItemComponent(
                                      category: category,
                                      onTap: () {
                                        ViewLiveTvCategoryChannels(
                                          categoryId: category.id.validate(),
                                          categoryName: category.name ?? '',
                                        ).launch(context);
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          ...data.sliders.validate().map<Widget>((e) {
                            if (e.data.validate().isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  16.height,
                                  headingWidViewAll(
                                    context,
                                    e.title.validate(),
                                    showViewMore: e.viewAll.validate(),
                                    callback: () async {
                                      ViewAllLiveTvChannels(
                                        categoryTitle: e.title.validate(),
                                        sliderIndex: data.sliders.validate().indexOf(e),
                                        type: e.type,
                                        typeId: e.ids,
                                      ).launch(context);
                                    },
                                  ),
                                  ItemHorizontalList(
                                    e.data.validate(),
                                    isLandscape: true,
                                    isLiveTv: true,
                                  ),
                                ],
                              );
                            } else {
                              return Offstage();
                            }
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
