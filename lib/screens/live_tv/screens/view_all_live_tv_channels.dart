import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/utils/constants.dart';

import '../../../components/loader_widget.dart';
import '../../../components/loading_dot_widget.dart';
import '../../../main.dart';
import '../../../models/view_all_response.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/common.dart';

class ViewAllLiveTvChannels extends StatefulWidget {
  final String categoryTitle;
  final int sliderIndex;
  final String? type;
  final List<dynamic>? typeId;

   ViewAllLiveTvChannels({Key? key, required this.categoryTitle, required this.sliderIndex, this.type, this.typeId}) : super(key: key);

  @override
  _ViewAllLiveTvChannelsState createState() => _ViewAllLiveTvChannelsState();
}

class _ViewAllLiveTvChannelsState extends State<ViewAllLiveTvChannels> {
  Future<ViewAllResponse>? future;

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({bool showLoader = true, int page = 1}) async {
    appStore.setLoading(true);
    final f = viewAll(
      widget.sliderIndex,
      widget.type.validate(),
      postType: PostType.CHANNEL,
      page: page,
      list: (widget.typeId is List) ? widget.typeId : [],
    ).then((value) {
      fragmentStore.setLiveChannels(value.data!.toList(), isRefresh: page == 1);
      mIsLastPage = value.data!.length == postPerPage;
      fragmentStore.setLiveChannelsIsLastPage(mIsLastPage);
      appStore.setLoading(false);
      return value;
    });
    future = f;
    fragmentStore.setLiveChannelsPage(page);
    fragmentStore.setLiveChannelsFuture(f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: boldTextStyle(color: Colors.white, size: 20)),
        backgroundColor: context.scaffoldBackgroundColor,
        surfaceTintColor: context.scaffoldBackgroundColor,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SnapHelperWidget(
            future: fragmentStore.liveChannelsFuture ?? future,
            loadingWidget: Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading).center()),
            errorBuilder: (p0) {
              return NoDataWidget(
                imageWidget: noDataImage(),
                title: p0,
                onRetry: () {
                  mPage = 1;
                  init(showLoader: true, page: mPage);
                },
                retryText: language.refresh,
              ).center();
            },
            onSuccess: (data) {
              if (fragmentStore.liveChannels.isEmpty)
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: '${language.noDataFound} ${language.forText} ${widget.categoryTitle}',
                  onRetry: () {
                    mPage = 1;
                    init(showLoader: true, page: mPage);
                  },
                  retryText: language.refresh,
                ).center();
              else
                return AnimatedScrollView(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                  onSwipeRefresh: () async {
                    return await init();
                  },
                  onNextPage: () {
                    if (!mIsLastPage) {
                      mPage++;
                      init(page: mPage);
                    }
                  },
                  children: [
                    AnimatedWrap(
                      children: fragmentStore.liveChannels.map(
                        (e) {
                          return CommonListItemComponent(
                            data: e,
                            isLandscape: true,
                            width: context.width() / 2 - 24,
                            isLive: true,
                          );
                        },
                      ).toList(),
                      runSpacing: 16,
                      spacing: 16,
                    )
                  ],
                );
            },
          ),
          Observer(
            builder: (context) {
              return mPage > 1
                  ? Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: LoadingDotsWidget(),
                    ).visible(appStore.isLoading)
                  : LoaderWidget().visible(appStore.isLoading);
            },
          )
        ],
      ),
    );
  }
}