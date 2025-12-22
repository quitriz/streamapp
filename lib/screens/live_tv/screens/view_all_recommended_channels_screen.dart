import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/live_tv/live_channel_detail_model.dart';
import 'package:streamit_flutter/screens/live_tv/components/live_card.dart';
import 'package:streamit_flutter/screens/live_tv/screens/channel_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';

class ViewAllRecommendedChannelsScreen extends StatefulWidget {
  final List<RecommendedChannel> recommendedChannels;

  ViewAllRecommendedChannelsScreen({required this.recommendedChannels});

  @override
  State<ViewAllRecommendedChannelsScreen> createState() => _ViewAllRecommendedChannelsScreenState();
}

class _ViewAllRecommendedChannelsScreenState extends State<ViewAllRecommendedChannelsScreen> {
  @override
  void initState() {
    super.initState();
    fragmentStore.setRecommendedLoading(true);
    fragmentStore.setRecommendedChannels(widget.recommendedChannels, isRefresh: true);
    Future.delayed(Duration(milliseconds: 200), () => fragmentStore.setRecommendedLoading(false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language.recommendedForYou,
          style: boldTextStyle(color: Colors.white, size: 20),
        ),
        backgroundColor: context.cardColor,
        centerTitle: false,
        leading: const BackButton(color: Colors.white),
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
        surfaceTintColor: context.scaffoldBackgroundColor,
      ),
      body: Container(
        child: Stack(
          children: [
            Observer(builder: (_) {
              if (fragmentStore.isRecommendedLoading) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: 8,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemBuilder: (context, index) {
                    return CommonListItemShimmer(
                      isLandscape: true,
                      isContinueWatch: false,
                    );
                  },
                );
              } else if (fragmentStore.recommendedChannels.isNotEmpty) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: fragmentStore.recommendedChannels.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemBuilder: (context, index) {
                    final recommendedChannel = fragmentStore.recommendedChannels[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        child: Stack(
                          children: [
                            CachedImageWidget(
                              url: recommendedChannel.thumbnailImage.validate().isNotEmpty ? recommendedChannel.thumbnailImage.validate() : appStore.sliderDefaultImage.validate(),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.8),
                                      Colors.black.withValues(alpha: 0.6),
                                      Colors.black.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.3, 0.7, 1.0],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
                                      child: Text(
                                        recommendedChannel.title.validate(),
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Align(alignment: Alignment.bottomRight, child: LiveTagComponent()),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).onTap(() {
                      ChannelDetailScreen(channelId: recommendedChannel.id.validate()).launch(context);
                    });
                  },
                );
              } else {
                return NoDataWidget(
                  imageWidget: noDataImage(),
                ).center();
              }
            })
          ],
        ),
      ),
    );
  }
}
