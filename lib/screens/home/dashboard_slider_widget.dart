import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/coming_soon_badge.dart';
import 'package:streamit_flutter/components/view_video/video_widget.dart';
import 'package:streamit_flutter/components/view_video/video_playback_handle.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/screens/tv_show/tv_show_detail_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';

class DashboardSliderWidget extends StatefulWidget {
  final List<CommonDataListModel> mSliderList;

  DashboardSliderWidget({required this.mSliderList, super.key});

  @override
  State<DashboardSliderWidget> createState() => DashboardSliderWidgetState();
}

class DashboardSliderWidgetState extends State<DashboardSliderWidget> {
  final PageController _pageController = PageController();
  Timer? _pageChangeTimer;
  VideoPlaybackHandle? _playbackHandle;

  @override
  void initState() {
    super.initState();
    if (widget.mSliderList.isNotEmpty) {
      appStore.setDashboardSliderList(widget.mSliderList);
      _startPageSequence();
    }
    // Listen for resume events when slider comes back into view
    LiveStream().on(ResumeDashboardVideo, (p0) {
      if (mounted && widget.mSliderList.isNotEmpty) {
        _startPageSequence();
      }
    });
  }

  /// Pause video playback and cancel timers
  void pauseVideo() {
    _pageChangeTimer?.cancel();
    appStore.setDashboardShowVideo(false);
    appStore.resetDashboardVideoState();
    _playbackHandle?.pause();
  }

  /// Resume video playback sequence
  void resumeVideo() {
    if (mounted && widget.mSliderList.isNotEmpty) {
      _startPageSequence();
      _playbackHandle?.resume?.call();
    }
  }

  @override
  void didUpdateWidget(DashboardSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mSliderList != oldWidget.mSliderList) {
      appStore.setDashboardSliderList(widget.mSliderList);
      // Clamp current page to valid range
      final validPage = widget.mSliderList.isEmpty 
          ? 0 
          : appStore.dashboardCurrentPage.clamp(0, widget.mSliderList.length - 1);
      if (validPage != appStore.dashboardCurrentPage) {
        appStore.setDashboardCurrentPage(validPage);
      }
      // Update PageController to the valid page
      if (widget.mSliderList.isNotEmpty && _pageController.hasClients) {
        _pageController.jumpToPage(validPage);
      }
      // Restart the page sequence if list changed
      if (widget.mSliderList.isNotEmpty) {
        _startPageSequence();
      }
    }
  }


  @override
  void dispose() {
    LiveStream().dispose(ResumeDashboardVideo);
    pauseVideo();
    _pageController.dispose();
    super.dispose();
  }

  void _startPageSequence() {
    _pageChangeTimer?.cancel();
    appStore.resetDashboardVideoState();
    _pageChangeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        appStore.setDashboardShowVideo(true);

        ///TODO: remove setState
        setState(() {});
      }
    });
  }

  void _goToNextPage() {
    if (appStore.dashboardSliderList.length > 1) {
      appStore.nextDashboardPage();
      _pageController.animateToPage(
        appStore.dashboardCurrentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _navigateToDetailScreen(CommonDataListModel slider) async {
    appStore.setTrailerVideoPlayer(true);
    if (slider.postType == PostType.MOVIE || slider.postType == PostType.VIDEO) {
      await MovieDetailScreen(movieData: slider).launch(context);
    } else if (slider.postType == PostType.TV_SHOW || slider.postType == PostType.EPISODE) {
      await TvShowDetailScreen(showData: slider).launch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure current page is within valid bounds
    final sliderList = appStore.dashboardSliderList;
    if (sliderList.isEmpty) {
      return SizedBox.shrink();
    }
    
    // Clamp current page to valid range
    final currentPage = appStore.dashboardCurrentPage.clamp(0, sliderList.length - 1);
    if (currentPage != appStore.dashboardCurrentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          appStore.setDashboardCurrentPage(currentPage);
          // Sync PageController if it has clients
          if (_pageController.hasClients) {
            _pageController.jumpToPage(currentPage);
          }
        }
      });
    }
    
    final currentSlider = sliderList[currentPage];
    
    return InkWell(
            onTap: () => _navigateToDetailScreen(currentSlider),
            child: SizedBox(
              height: appStore.hasInFullScreen ? context.height() : context.height() * 0.26,
              width: context.width(),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) {
                      appStore.setDashboardCurrentPage(value);
                      _startPageSequence();
                    },
                    itemCount: sliderList.length,
                    itemBuilder: (context, index) {
                      CommonDataListModel slider = sliderList[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: slider.image.validate().isEmpty ? appStore.bannerDefaultImage.validate() : slider.image.validate(),
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => CachedImageWidget(url: appStore.bannerDefaultImage.validate(), fit: BoxFit.cover),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                stops: [0.0, 0.6],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [Colors.black.withAlpha(204), Colors.transparent],
                                center: Alignment.bottomLeft,
                                radius: 1.2,
                                stops: const [0.0, 0.9],
                              ),
                            ),
                          ),
                          if (slider.isUpcoming.validate())
                            ComingSoonBadge(
                              top: 8,
                              left: 8,
                              iconSize: 14,
                              textSize: 12,
                              iconTextSpacing: 6,
                            ),
                          if (index == currentPage && appStore.dashboardShowVideo)
                            VideoWidget(
                              videoURL: slider.trailerLink.validate(),
                              watchedTime: '',
                              videoType: slider.postType,
                              videoURLType: slider.trailerLinkType.validate(),
                              videoId: slider.id.validate(),
                              thumbnailImage: slider.image.validate().isEmpty ? appStore.bannerDefaultImage.validate() : slider.image.validate(),
                              isTrailer: true,
                              isSlider: true,
                              onPlaybackHandleReady: (handle) {
                                _playbackHandle = handle;
                              },
                              onTap: () async {
                                appStore.setTrailerVideoPlayer(true);
                                if (slider.postType == PostType.MOVIE || slider.postType == PostType.VIDEO) {
                                  await MovieDetailScreen(movieData: slider).launch(context).then((value) {
                                    appStore.refreshDashboardSlider();
                                  });
                                } else if (slider.postType == PostType.TV_SHOW || slider.postType == PostType.EPISODE) {
                                  await TvShowDetailScreen(showData: slider).launch(context).then((value) {
                                    appStore.refreshDashboardSlider();
                                  });
                                }
                              },
                              onVideoEnd: () {
                                if (mounted) {
                                  appStore.setDashboardShowVideo(false);
                                  _pageChangeTimer = Timer(const Duration(seconds: 5), () {
                                    _goToNextPage();
                                  });
                                }
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 26,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            currentSlider.genre != null && currentSlider.genre!.isNotEmpty
                                ? currentSlider.genre!.take(2).join(' •')
                                : '',
                            style: primaryTextStyle(size: 12)),
                        8.height,
                        Text(currentSlider.title.validate(), style: boldTextStyle(size: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (sliderList.length > 1)
                    Positioned(
                      bottom: 5,
                      left: 16,
                      child: DotIndicator(
                          pageController: _pageController,
                          pages: sliderList,
                          indicatorColor: Colors.white,
                          unselectedIndicatorColor: Colors.white.withAlpha(102),
                          currentDotSize: 8,
                          dotSize: 6),
                    ),
                ],
              ),
            ),
          );
  }
}
