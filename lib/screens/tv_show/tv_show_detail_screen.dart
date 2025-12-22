import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_common_models.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_response.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/cast/cast_detail_bottom_sheet.dart';
import 'package:streamit_flutter/screens/cast/view_all_cast_crew_screen.dart';
import 'package:streamit_flutter/screens/movie_episode/components/content_metadata_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/movie_detail_like_watchlist_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/selection_button_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/upcoming_related_movie_list_widget.dart';
import 'package:streamit_flutter/screens/rate_review/components/rate_review_widget.dart';
import 'package:streamit_flutter/screens/tv_show/components/season_episode_widget.dart';
import 'package:streamit_flutter/screens/tv_show/components/tv_show_header_component.dart';
import 'package:streamit_flutter/screens/web_view_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../components/release_date_badge.dart';

class TvShowDetailScreen extends StatefulWidget {
  final CommonDataListModel showData;
  final bool isEpisode;

  const TvShowDetailScreen({Key? key, required this.showData, this.isEpisode = false}) : super(key: key);

  @override
  State<TvShowDetailScreen> createState() => _TvShowDetailScreenState();
}

class _TvShowDetailScreenState extends State<TvShowDetailScreen> with WidgetsBindingObserver {
  MovieDetailResponse? movieResponse;
  String genre = '';
  String _watchedTime = '';
  bool _resumeActionTaken = false;
  final GlobalKey<TvShowHeaderComponentState> _headerKey = GlobalKey<TvShowHeaderComponentState>();

  @override
  void initState() {
    super.initState();
    fragmentStore.resetTvShowState();
    ScreenProtector.preventScreenshotOn();
    init();
    requestPipAvailability();
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
  }

  Future<void> requestPipAvailability() async {
    appStore.setShowPIP(await FlPiP().isAvailable);
  }

  /// Initialize + fetch TV show details and reviews
  Future<void> init() async {
    appStore.setLoading(true);
    appStore.setTrailerVideoPlayer(false);

    bool detailSuccess = false;

    try {
      if (widget.isEpisode) {
        /// Step 1: Get episode details
        final detailedEpisode = await getEpisodeDetail(widget.showData.id.validate());
        fragmentStore.setSelectedEpisode(detailedEpisode);

        /// Step 2: Fetch parent show using parent_id (if available)
        final parentResponse = await tvShowDetail(detailedEpisode.tvShowId.toInt().validate());
        if (parentResponse.data != null) {
          fragmentStore.setShowDetails(parentResponse.data);
          movieResponse = parentResponse;
          fragmentStore.setHasData(true);

          fragmentStore.setSelectedEpisodeIndex(1);
          fragmentStore.setSelectedSeasonNumber(1);

          if (fragmentStore.showDetails?.genre != null) {
            genre = fragmentStore.showDetails!.genre!.map((e) => e.validate()).join(' • ');
          }

          detailSuccess = true;
        } else {
          fragmentStore.setMovieDetailError(true);
        }
      } else {
        final response = await tvShowDetail(widget.showData.id.validate());
        if (response.data != null) {
          movieResponse = response;
          fragmentStore.setShowDetails(response.data);
          fragmentStore.setHasData(true);

          if (response.data?.genre != null) {
            genre = response.data!.genre!.map((e) => e.validate()).join(' • ');
          }

          detailSuccess = true;
        } else {
          fragmentStore.setMovieDetailError(true);
        }
      }
    } catch (e) {
      fragmentStore.setMovieDetailError(true);
      appStore.setLoading(false);
      return;
    }

    // Only proceed with review API if detail API was successful
    if (detailSuccess) {
      await getReview();
    } else {
      log('TvShowDetailScreen: Detail API failed, skipping review API');
    }

    appStore.setLoading(false);
  }

  /// Fetch reviews for the TV show
  Future<void> getReview() async {
    if (fragmentStore.showDetails == null) {
      return;
    }

    try {
      String type = ReviewConst.reviewTypeTvShow; // default
      switch (fragmentStore.showDetails!.postType) {
        case PostType.TV_SHOW:
          type = ReviewConst.reviewTypeTvShow;
          break;
        case PostType.EPISODE:
          type = ReviewConst.reviewTypeEpisode;
          break;
        default:
          type = ReviewConst.reviewTypeTvShow;
      }

      final rateReviewResponse = await getRateReviews(postType: type.toLowerCase(), postId: widget.showData.id.validate());

      reviewStore.reviewList.clear();
      if (rateReviewResponse.data?.reviews != null) {
        reviewStore.reviewList.addAll(rateReviewResponse.data!.reviews!);
      }
      if (rateReviewResponse.data?.ratingSummary?.overallRating != null) {
        reviewStore.setOverallRating(rateReviewResponse.data!.ratingSummary!.overallRating!.toDouble());
      } else {
        reviewStore.setOverallRating(null);
      }
    } catch (e) {
      log('TvShowDetailScreen: Review API failed with error: $e');
    }
  }

  /// Get episode index from season
  Future<int?> getEpisodeIndexFromSeason(int showId, int seasonId, int episodeId) async {
    try {
      final season = await tvShowSeasonDetail(showId: showId, seasonId: seasonId);
      if (season.episodes != null && season.episodes!.isNotEmpty) {
        for (int i = 0; i < season.episodes!.length; i++) {
          if (season.episodes![i].id == episodeId) {
            return i;
          }
        }
      }
      return null;
    } catch (e) {
      log('Error getting episode index from season: $e');
      return null;
    }
  }

  /// Handle episode selection
  Future<void> onEpisodeSelected(MovieData episode, int index, List<MovieData> episodes, {int? seasonNumber}) async {
    try {
      appStore.setLoading(true);

      final detailedEpisode = await getEpisodeDetail(episode.id.validate());

      fragmentStore.setSelectedEpisode(detailedEpisode);
      fragmentStore.setSelectedEpisodeIndex(index);
      fragmentStore.setSelectedSeasonNumber(seasonNumber ?? 1);
      fragmentStore.setAllEpisodes(episodes);

      appStore.setTrailerVideoPlayer(false);
    } catch (e) {
      toast('${language.failedToLoadEpisode} $e');
      log('Error fetching episode details: $e');
    } finally {
      appStore.setLoading(false);
    }
  }

  /// Play the selected episode
  Future<void> playSelectedEpisode() async {
    if (fragmentStore.selectedEpisode == null) return;
    if (!fragmentStore.showDetails!.userHasAccess.validate()) {
      toast(language.youDontHaveMembership);
      return;
    }

    appStore.setTrailerVideoPlayer(false);
  }

  /// Handle rent payment for TV shows
  Future<void> _handleRentPayment() async {
    if (!appStore.isLogging) {
      SignInScreen(
        redirectTo: () {},
      ).launch(context);
      return;
    }

    if (fragmentStore.showDetails?.checkOutUrl.validate().isEmpty == true) {
      toast(language.checkoutUrlNotAvailable);
      return;
    }

    await WebViewScreen(
      url: fragmentStore.showDetails!.checkOutUrl.validate() + '&web_view_nonce=${appStore.userNonce}&user_id=${appStore.userId}',
      title: '${language.rent.capitalizeFirstLetter()} - ${fragmentStore.showDetails!.title.validate()}',
      paymentType: 'rent',
    ).launch(context).then((result) async {
      appStore.setLoading(true);
      try {
        await init();
        if (result == true) {
          toast(language.paymentCompletedSuccessfully);
        }
      } catch (e) {
        log('Error refreshing TV show details: $e');
      } finally {
        appStore.setLoading(false);
      }
    });
  }

  /// Handle resume watching for TV Shows
  Future<void> _handleResumeWatching() async {
    final watchedDuration = fragmentStore.showDetails?.watchedDuration;
    if (watchedDuration == null || watchedDuration.seasonId == null || watchedDuration.episodeId == null) {
      return;
    }

    try {
      appStore.setLoading(true);

      // Fetch episode details
      final episode = await getEpisodeDetail(watchedDuration.episodeId!);

      // Fetch season episodes to get the full list and find index
      final season = await tvShowSeasonDetail(
        showId: fragmentStore.showDetails!.id.validate(),
        seasonId: watchedDuration.seasonId!,
      );

      if (season.episodes == null || season.episodes!.isEmpty) {
        toast(language.failedToLoadEpisode);
        return;
      }

      // Find episode index
      int? episodeIndex;
      for (int i = 0; i < season.episodes!.length; i++) {
        if (season.episodes![i].id == watchedDuration.episodeId) {
          episodeIndex = i;
          break;
        }
      }

      if (episodeIndex == null) {
        toast(language.failedToLoadEpisode);
        return;
      }

      // Use season_id directly as season number (as per plan)
      int seasonNumber = watchedDuration.seasonId!;

      // Set watched time for resume
      setState(() {
        _watchedTime = watchedDuration.watchedTime.toString();
      });

      // Call onEpisodeSelected to set episode and trigger UI updates
      await onEpisodeSelected(episode, episodeIndex, season.episodes!, seasonNumber: seasonNumber);

      // Hide resume watching buttons after action is taken
      setState(() {
        _resumeActionTaken = true;
      });

      appStore.setTrailerVideoPlayer(false);
    } catch (e) {
      toast('${language.failedToLoadEpisode} $e');
      log('Error resuming episode: $e');
    } finally {
      appStore.setLoading(false);
    }
  }

  /// Handle start from beginning for TV Shows
  Future<void> _handleStartFromBeginning() async {
    final watchedDuration = fragmentStore.showDetails?.watchedDuration;
    if (watchedDuration == null || watchedDuration.seasonId == null || watchedDuration.episodeId == null) {
      return;
    }

    try {
      appStore.setLoading(true);

      // Fetch episode details
      final episode = await getEpisodeDetail(watchedDuration.episodeId!);

      // Fetch season episodes to get the full list and find index
      final season = await tvShowSeasonDetail(
        showId: fragmentStore.showDetails!.id.validate(),
        seasonId: watchedDuration.seasonId!,
      );

      if (season.episodes == null || season.episodes!.isEmpty) {
        toast(language.failedToLoadEpisode);
        return;
      }

      // Find episode index
      int? episodeIndex;
      for (int i = 0; i < season.episodes!.length; i++) {
        if (season.episodes![i].id == watchedDuration.episodeId) {
          episodeIndex = i;
          break;
        }
      }

      if (episodeIndex == null) {
        toast(language.failedToLoadEpisode);
        return;
      }

      // Use season_id directly as season number (as per plan)
      int seasonNumber = watchedDuration.seasonId!;

      // Set empty watched time to start from beginning
      setState(() {
        _watchedTime = '';
      });

      // Call onEpisodeSelected to set episode and trigger UI updates
      await onEpisodeSelected(episode, episodeIndex, season.episodes!, seasonNumber: seasonNumber);

      // Hide resume watching buttons after action is taken
      setState(() {
        _resumeActionTaken = true;
      });

      appStore.setTrailerVideoPlayer(false);
    } catch (e) {
      toast('${language.failedToLoadEpisode} $e');
      log('Error starting episode from beginning: $e');
    } finally {
      appStore.setLoading(false);
    }
  }

  /// Handle remind me for upcoming TV shows
  /// Calls remind-me API and then refreshes TV show details
  Future<void> _handleRemindMe() async {
    if (fragmentStore.showDetails?.id == null) {
      toast(language.somethingWentWrong, print: true);
      return;
    }

    if (!appStore.isLogging) {
      SignInScreen(redirectTo: () {}).launch(context);
      return;
    }

    final currentShow = fragmentStore.showDetails!;

    try {
      // Call remind-me API
      Map<String, dynamic> request = {"id": currentShow.id!, "post_type": ReviewConst.reviewTypeTvShow2};
      final response = await remindMeNotification(request);

      if (response.message?.isNotEmpty == true) {
        toast(response.message!);
      }

      // Refresh TV show details after remind-me API succeeds
      await init();
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('network') || errorMessage.contains('timeout')) {
      } else if (errorMessage.contains('unauthorized') || errorMessage.contains('401')) {
        toast('Your session has expired. Please sign in again.');
      } else {
        toast(errorMessage);
      }
    }
  }

  Widget _buildEpisodeInfo() {
    if (fragmentStore.selectedEpisode == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${language.nowPlaying}: S${fragmentStore.selectedSeasonNumber}E${(fragmentStore.selectedEpisodeIndex ?? 0) + 1} ${fragmentStore.selectedEpisode!.title.validate()}',
          style: boldTextStyle(size: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (fragmentStore.selectedEpisode!.description.validate().isNotEmpty) ...[
          8.height,
          ReadMoreText(
            parseHtmlString(fragmentStore.selectedEpisode!.description.validate()),
            trimLines: 2,
            style: secondaryTextStyle(),
            colorClickableText: redColor,
            trimMode: TrimMode.Line,
            trimCollapsedText: ' ..${language.readMore.toLowerCase()}',
            trimExpandedText: ' ${language.readLess.toLowerCase()}',
          ),
        ]
      ],
    );
  }

  @override
  void dispose() {
    // Pause video when navigating away from detail screen
    _headerKey.currentState?.pauseVideo();
    WidgetsBinding.instance.removeObserver(this);
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (appStore.hasInFullScreen.validate()) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        enterPiPMode();
      }
    } else {
      // Pause video when app goes to background (but not in fullscreen/PIP)
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _headerKey.currentState?.pauseVideo();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      final List<CommonDataDetailsModel> casts = fragmentStore.showDetails?.castsList.validate() ?? [];
      final List<CommonDataDetailsModel> crews = fragmentStore.showDetails?.crews.validate() ?? [];
      final bool showCastSection = fragmentStore.hasData && fragmentStore.showDetails != null && coreStore.shouldShowCast && casts.isNotEmpty;
      final bool showCrewSection = fragmentStore.hasData && fragmentStore.showDetails != null && coreStore.shouldShowCrew && crews.isNotEmpty;

      return PiPBuilder(
        builder: (statusInfo) {
          appStore.setPIPOn(statusInfo?.status == PiPStatus.enabled);

          return Scaffold(
            backgroundColor: cardColor,
            appBar: AppBar(
              title: Text(widget.showData.title.validate(), style: boldTextStyle()),
              backgroundColor: cardColor,
              surfaceTintColor: cardColor,
              elevation: 0,
            ),
            body: Stack(
              children: [
                if (fragmentStore.hasData && fragmentStore.showDetails != null)
                  RefreshIndicator(
                    onRefresh: () async {
                      await init();
                      await 2.seconds.delay;
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? context.height() * 0.26 : context.height(),
                            child: VisibilityDetector(
                              key: Key('player'),
                              onVisibilityChanged: (VisibilityInfo info) {
                                if (info.visibleFraction == 0) {
                                  _headerKey.currentState?.pauseVideo();
                                }
                              },
                              child: TvShowHeaderComponent(
                                key: _headerKey,
                                show: fragmentStore.showDetails!,
                                userHasAccess: fragmentStore.showDetails!.userHasAccess.validate(),
                                watchedTime: _watchedTime,
                              ),
                            ),
                          ),
                          16.height,
                          ContentMetaData(
                            movieData: fragmentStore.showDetails!,
                            genre: genre,
                            overallRating: reviewStore.overallRating,
                          ).paddingSymmetric(horizontal: 16),
                          16.height,
                          Builder(
                            builder: (context) {
                              final parsedDate = parseReleaseDate(fragmentStore.showDetails?.releaseDate.validate() ?? '');
                              return parsedDate != null ? ReleaseDateBadge(releaseDate: parsedDate).paddingSymmetric(horizontal: 16) : SizedBox.shrink();
                            },
                          ),
                          8.height,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fragmentStore.showDetails!.title.validate(), style: boldTextStyle(size: 22), maxLines: 2, overflow: TextOverflow.ellipsis),
                              Observer(builder: (context) {
                                return fragmentStore.selectedEpisode != null && !appStore.isTrailerVideoPlaying
                                    ? Column(
                                        children: [
                                          16.height,
                                          _buildEpisodeInfo(),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          8.height,
                                          ReadMoreText(
                                            parseHtmlString(fragmentStore.showDetails!.description.validate()),
                                            trimLines: 3,
                                            style: secondaryTextStyle(),
                                            colorClickableText: redColor,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: ' ..${language.readMore.toLowerCase()}',
                                            trimExpandedText: ' ${language.readLess.toLowerCase()}',
                                          ),
                                        ],
                                      );
                              }),
                              8.height,
                              Observer(
                                builder: (context) => SelectionButtonsWidget(
                                  movie: fragmentStore.showDetails!,
                                  genre: genre,
                                  isTrailerPlaying: false,
                                  isUpcoming: fragmentStore.showDetails!.isUpcoming == true,
                                  onRent: _handleRentPayment,
                                  onRemindMe: _handleRemindMe,
                                  onResumeWatching: _handleResumeWatching,
                                  onStartFromBeginning: _handleStartFromBeginning,
                                  hideResumeWatching: _resumeActionTaken,
                                ),
                              ),
                              16.height,
                              if (fragmentStore.showDetails != null && fragmentStore.selectedEpisode == null)
                                MovieDetailLikeWatchListWidget(
                                  postId: fragmentStore.showDetails!.id.validate(),
                                  postType: PostType.TV_SHOW,
                                  isInWatchList: fragmentStore.showDetails!.isInWatchList,
                                  isLiked: fragmentStore.showDetails!.isLiked.validate(),
                                  likes: fragmentStore.showDetails!.likes,
                                  shareUrl: fragmentStore.showDetails!.shareUrl.validate(),
                                  isUpcoming: fragmentStore.showDetails!.isUpcoming.validate(),
                                  onPauseVideo: () {
                                    _headerKey.currentState?.pauseVideo();
                                  },
                                ),
                              if (fragmentStore.selectedEpisode != null)
                                MovieDetailLikeWatchListWidget(
                                  postId: fragmentStore.selectedEpisode!.id.validate(),
                                  postType: PostType.EPISODE,
                                  isInWatchList: fragmentStore.selectedEpisode!.isInWatchList.validate(),
                                  isLiked: fragmentStore.selectedEpisode!.isLiked.validate(),
                                  likes: fragmentStore.selectedEpisode!.likes,
                                  shareUrl: fragmentStore.selectedEpisode!.shareUrl.validate(),
                                  videoName: fragmentStore.selectedEpisode!.title.validate(),
                                  videoLink: fragmentStore.selectedEpisode!.file.validate(),
                                  videoImage: fragmentStore.selectedEpisode!.image.validate(),
                                  videoDescription: fragmentStore.selectedEpisode!.description.validate(),
                                  videoDuration: fragmentStore.selectedEpisode!.runTime.validate(),
                                  userHasAccess: fragmentStore.selectedEpisode!.userHasAccess.validate(),
                                  isTrailerVideoPlaying: appStore.isTrailerVideoPlaying,
                                  isUpcoming: fragmentStore.selectedEpisode!.isUpcoming.validate(),
                                  onAction: () {},
                                  onPauseVideo: () {
                                    _headerKey.currentState?.pauseVideo();
                                  },
                                ),
                            ],
                          ).paddingSymmetric(horizontal: 16),
                          if (fragmentStore.showDetails!.seasons != null && fragmentStore.showDetails!.seasons!.data.validate().isNotEmpty && !fragmentStore.showDetails!.isUpcoming.validate())
                            SeasonsAndEpisodesWidget(
                              movie: fragmentStore.showDetails!,
                              onEpisodeSelected: onEpisodeSelected,
                              userHasAccess: fragmentStore.showDetails!.userHasAccess.validate(),
                            ),

                          /// Casts & Crew section rendered independently
                          if (showCastSection) ...[
                            headingWidViewAll(
                              context,
                              language.cast,
                              showViewMore: true,
                              padding: EdgeInsets.only(left: 16, right: 0),
                              callback: () {
                                ViewAllCastCrewScreen(
                                  type: CastCrewType.cast,
                                  people: casts,
                                ).launch(context);
                              },
                            ),
                            HorizontalList(
                              itemCount: casts.length,
                              itemBuilder: (context, index) {
                                final CommonDataDetailsModel data = casts[index];
                                return SizedBox(
                                  width: 80,
                                  child: CachedImageWidget(
                                    url: data.image.validate().isEmpty ? appStore.personDefaultImage.validate() : data.image.validate(),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ).cornerRadiusWithClipRRect(60).onTap(
                                    () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => CastDetailBottomSheet(castId: data.id.validate()),
                                      );
                                    },
                                    borderRadius: radius(35),
                                    highlightColor: Colors.transparent,
                                  ),
                                );
                              },
                            ),
                            8.height,
                          ],
                          if (showCrewSection) ...[
                            headingWidViewAll(
                              context,
                              language.crew,
                              showViewMore: true,
                              padding: EdgeInsets.only(left: 16, right: 0),
                              callback: () {
                                ViewAllCastCrewScreen(
                                  type: CastCrewType.crew,
                                  people: crews,
                                ).launch(context);
                              },
                            ),
                            HorizontalList(
                              itemCount: crews.length,
                              itemBuilder: (context, index) {
                                final CommonDataDetailsModel data = crews[index];
                                return SizedBox(
                                  width: 80,
                                  child: CachedImageWidget(
                                    url: data.image.validate().isEmpty ? appStore.personDefaultImage.validate() : data.image.validate(),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ).cornerRadiusWithClipRRect(60).onTap(
                                    () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => CastDetailBottomSheet(castId: data.id.validate()),
                                      );
                                    },
                                    borderRadius: radius(35),
                                    highlightColor: Colors.transparent,
                                  ),
                                );
                              },
                            ),
                            8.height,
                          ],
                          if (showCastSection || showCrewSection) Divider(thickness: 0.1, color: Colors.grey.shade500).paddingTop(16),
                          if (movieResponse != null)
                            UpcomingRelatedMovieListWidget(
                              snap: movieResponse,
                              showRecommended: coreStore.shouldShowRecommended,
                            ),
                          Observer(builder: (context) {
                            return ReviewWidget(
                              postType: fragmentStore.showDetails!.postType!.name.validate(),
                              postId: fragmentStore.showDetails!.id,
                              callReviewList: () {
                                getReview();
                              },
                            ).paddingAll(16).visible(fragmentStore.showDetails!.isRateReviewOpen.validate() &&
                                appStore.isLogging &&
                                !fragmentStore.showDetails!.isUpcoming.validate() &&
                                fragmentStore.showDetails!.userHasAccess.validate());
                          }),
                        ],
                      ),
                    ),
                  ),
                if (!fragmentStore.hasData && fragmentStore.isError)
                  NoDataWidget(
                    imageWidget: noDataImage(),
                    title: language.noDataFound,
                  ).center(),
                Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)).center(),
              ],
            ),
          );
        },
      );
    });
  }
}
