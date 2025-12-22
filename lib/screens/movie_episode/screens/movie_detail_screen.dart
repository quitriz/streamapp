import 'dart:async';

import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/release_date_badge.dart';
import 'package:streamit_flutter/config.dart';
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
import 'package:streamit_flutter/screens/web_view_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/html_widget.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../components/movie_header_component.dart';

class MovieDetailScreen extends StatefulWidget {
  final String? title;
  final CommonDataListModel movieData;
  final int? currentIndex;
  final List<CommonDataListModel>? playList;
  final VoidCallback? onRemoveFromPlaylist;
  final bool isContinueWatching;

  MovieDetailScreen({
    this.title = "",
    required this.movieData,
    this.onRemoveFromPlaylist,
    this.currentIndex,
    this.playList,
    this.isContinueWatching = false,
  });

  @override
  MovieDetailScreenState createState() => MovieDetailScreenState();
}

class MovieDetailScreenState extends State<MovieDetailScreen> with WidgetsBindingObserver {
  ScrollController scrollController = ScrollController();
  InterstitialAd? interstitialAd;
  String _watchedTime = '';
  final GlobalKey<MovieDetailHeaderComponentState> _headerKey = GlobalKey<MovieDetailHeaderComponentState>();

  @override
  void initState() {
    appStore.setTrailerVideoPlayer(!widget.isContinueWatching);
    fragmentStore.resetMovieDetailState();
    init();
    ScreenProtector.preventScreenshotOn();
    super.initState();
    requestPipAvailability();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> init() async {
    fragmentStore.setCurrentMovie(
      MovieData(
        image: widget.movieData.image,
        title: widget.movieData.title,
        id: widget.movieData.id,
        postType: widget.movieData.postType,
        trailerLink: widget.movieData.trailerLink.validate(),
      ),
    );
    fragmentStore.setCurrentIndex(widget.currentIndex ?? 0);

    if (widget.playList.validate().isNotEmpty) {
      CommonDataListModel data = widget.playList.validate()[fragmentStore.currentIndex];
      fragmentStore.setCurrentMovie(
        MovieData(image: data.image, title: data.title, id: data.id, postType: data.postType),
      );
    }
    fragmentStore.setPostType(fragmentStore.currentMovie?.postType);
    appStore.setLoading(true);

    try {
      final detailSuccess = await getDetails();
      if (detailSuccess) {
        await getReview();
      } else {
        appStore.setLoading(false);
        return;
      }
    } catch (e) {
      fragmentStore.setMovieDetailError(true);
      appStore.setLoading(false);
      return;
    } finally {
      if (fragmentStore.hasData && !fragmentStore.hasMovieError) {
        appStore.setLoading(false);
      }
    }

    if (adShowCount < 5) {
      adShowCount++;
    } else {
      adShowCount = 0;
      buildInterstitialAd();
    }
  }

  Future<void> getReview() async {
    try {
      String type = '';
      switch (fragmentStore.currentMovie?.postType) {
        case PostType.MOVIE:
          type = ReviewConst.reviewTypeMovie;
          break;
        case PostType.VIDEO:
          type = ReviewConst.reviewTypeVideo;
          break;
        default:
          type = ReviewConst.reviewTypeMovie;
      }

      final rateReviewResponse = await getRateReviews(
        postType: type.toLowerCase(),
        postId: widget.movieData.id.validate(),
      );

      reviewStore.reviewList.clear();
      if (rateReviewResponse.data?.reviews != null) {
        reviewStore.reviewList.addAll(rateReviewResponse.data!.reviews!);
      } else {
        log('MovieDetailScreen: No reviews found in response');
      }

      if (rateReviewResponse.data?.ratingSummary?.overallRating != null) {
        reviewStore.setOverallRating(rateReviewResponse.data!.ratingSummary!.overallRating!.toDouble());
      } else {
        reviewStore.setOverallRating(null);
      }
    } catch (e) {
      log('MovieDetailScreen: Review API failed with error: $e');
    }
  }

  Future<void> requestPipAvailability() async {
    appStore.setShowPIP(await FlPiP().isAvailable);
  }

  Future<MovieDetailResponse?> getDetailAPIByType() async {
    if (widget.movieData.postType == PostType.MOVIE) {
      return movieDetail(fragmentStore.currentMovie!.id.validate());
    } else if (widget.movieData.postType == PostType.VIDEO) {
      return getVideosDetail(fragmentStore.currentMovie!.id.validate());
    } else {
      return null;
    }
  }

  Future<bool> getDetails() async {
    try {
      final value = await getDetailAPIByType();
      if (value != null) {
        fragmentStore.setMovieResponse(value);
        widget.movieData.isUpcoming = value.data?.isUpcoming.validate() ?? true;
        fragmentStore.setHasData(true);
        fragmentStore.setCurrentMovie(value.data ?? MovieData());

        if (value.data?.genre != null) {
          String genreString = '';
          value.data!.genre!.forEach((element) {
            if (genreString.isNotEmpty) {
              genreString = '$genreString • ${element.validate()}';
            } else {
              genreString = element.validate();
            }
          });
          fragmentStore.setGenre(genreString);
        }

        if (value.data != null) fragmentStore.setCurrentMovie(value.data!);

        if (value.data!.trailerLink.validate().isNotEmpty && !widget.isContinueWatching) {
          appStore.setTrailerVideoPlayer(true);
        }

        if (value.data!.subscriptionLevels.validate().isNotEmpty && !value.data!.userHasAccess.validate()) {
          String plans = '';
          value.data!.subscriptionLevels!.forEach((element) {
            plans = plans + '${plans.isEmpty ? '' : ','} ${element.label}';
          });
          fragmentStore.setRestrictedPlans(plans);
        }

        return true;
      } else {
        fragmentStore.setHasData(false);
        fragmentStore.setMovieDetailError(true);
        return false;
      }
    } catch (e) {
      fragmentStore.setHasData(false);
      fragmentStore.setMovieDetailError(true);
      return false;
    }
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        buildInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        buildInterstitialAd();
      },
    );
    interstitialAd!.show();
  }

  void buildInterstitialAd() {
    InterstitialAd.load(
      adUnitId: mAdMobInterstitialId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          this.interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  Future<void> _handleRentPayment() async {
    if (!appStore.isLogging) {
      SignInScreen(redirectTo: () {}).launch(context);
      return;
    }

    if (fragmentStore.currentMovie?.checkOutUrl.validate().isEmpty == true) {
      toast(language.checkoutUrlNotAvailable);
      return;
    }

    await WebViewScreen(
      url: fragmentStore.currentMovie!.checkOutUrl.validate() + '&web_view_nonce=${appStore.userNonce}&user_id=${appStore.userId}',
      title: '${language.rent.capitalizeFirstLetter()} - ${fragmentStore.currentMovie!.title.validate()}',
      paymentType: 'rent',
    ).launch(context).then((result) async {
      appStore.setLoading(true);
      try {
        await getDetails();
        if (result == true) {
          toast(language.paymentCompletedSuccessfully);
        }
      } catch (e) {
        log('Error refreshing movie details: $e');
      } finally {
        appStore.setLoading(false);
      }
    });
  }

  Future<void> remindMe() async {
    if (fragmentStore.currentMovie?.id == null) {
      toast(language.somethingWentWrong, print: true);
      return;
    }

    if (!appStore.isLogging) {
      SignInScreen(redirectTo: () {}).launch(context);
      return;
    }

    final currentMovie = fragmentStore.currentMovie!;
    final postType = currentMovie.postType == PostType.MOVIE ? 'movie' : 'video';

    try {
      // Call remind-me API
      Map<String, dynamic> request = {"id": currentMovie.id!, "post_type": postType.toLowerCase()};
      final response = await remindMeNotification(request);

      if (response.message?.isNotEmpty == true) {
        toast(response.message!);
      }

      // Refresh movie details after remind-me API succeeds
      await getDetails();
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('network') || errorMessage.contains('timeout')) {
        toast('Please check your internet connection');
      } else if (errorMessage.contains('unauthorized') || errorMessage.contains('401')) {
        toast('Your session has expired. Please sign in again.');
      } else {
        toast(errorMessage);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (appStore.hasInFullScreen.validate()) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        enterPiPMode();
      }
    }
  }

  @override
  void dispose() {
    appStore.setTrailerVideoPlayer(true);
    if (scrollController.hasClients) scrollController.dispose();
    if (!disabledAds) showInterstitialAd();
    appStore.setToFullScreen(false);
    appStore.setShowPIP(false);
    WidgetsBinding.instance.removeObserver(this);
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final List<CommonDataDetailsModel> casts = fragmentStore.currentMovie?.castsList.validate() ?? [];
        final List<CommonDataDetailsModel> crews = fragmentStore.currentMovie?.crews.validate() ?? [];
        final bool showCastSection = coreStore.shouldShowCast && casts.isNotEmpty;
        final bool showCrewSection = coreStore.shouldShowCrew && crews.isNotEmpty;
        return RefreshIndicator(
          onRefresh: () async {
            getDetails();
            getReview();
            return await 2.seconds.delay;
          },
          child: SafeArea(
            child: PiPBuilder(
              builder: (statusInfo) {
                appStore.setPIPOn(statusInfo?.status == PiPStatus.enabled);
                return Scaffold(
                  backgroundColor: cardColor,
                  resizeToAvoidBottomInset: true,
                  appBar: (statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen)
                      ? AppBar(
                          backgroundColor: cardColor,
                          elevation: 0,
                          leading: const BackButton(color: Colors.white),
                          title: null,
                          centerTitle: false,
                          automaticallyImplyLeading: false,
                          systemOverlayStyle: defaultSystemUiOverlayStyle(context),
                          surfaceTintColor: cardColor,
                        )
                      : null,
                  body: Stack(
                    children: [
                      if (fragmentStore.hasData && !fragmentStore.hasMovieError)
                        Observer(
                          builder: (context) {
                            return SingleChildScrollView(
                              physics: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? ScrollPhysics() : NeverScrollableScrollPhysics(),
                              controller: scrollController,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? 30 : 0,
                                  top: 0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen ? context.height() * 0.26 : context.height(),
                                      width: context.width(),
                                      child: VisibilityDetector(
                                        key: const Key('movie-player'),
                                        onVisibilityChanged: (info) {
                                          if (info.visibleFraction == 0) {
                                            _headerKey.currentState?.pauseVideo();
                                          }
                                        },
                                        child: MovieDetailHeaderComponent(
                                          key: _headerKey,
                                          movie: fragmentStore.currentMovie!,
                                          userHasAccess: fragmentStore.currentMovie!.userHasAccess.validate(),
                                          selectedEpisode: fragmentStore.currentMovie!,
                                          watchedTime: _watchedTime,
                                        ),
                                      ),
                                    ),
                                    if (statusInfo?.status != PiPStatus.enabled && !appStore.hasInFullScreen) ...[
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ContentMetaData(movieData: fragmentStore.currentMovie!, genre: fragmentStore.genre, overallRating: reviewStore.overallRating),
                                          8.height,
                                          Text(
                                            parseHtmlString(fragmentStore.currentMovie!.title.validate()),
                                            style: primaryTextStyle(size: 22),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          4.height,
                                          if (fragmentStore.currentMovie!.description.validate().isNotEmpty)
                                            if (fragmentStore.currentMovie!.description.validate().contains('href') || fragmentStore.currentMovie!.description.validate().contains('img'))
                                              HtmlWidget(
                                                postContent: fragmentStore.currentMovie!.description.validate(),
                                                color: textSecondaryColor,
                                                fontSize: 14,
                                              )
                                            else
                                              ReadMoreText(
                                                parse(fragmentStore.currentMovie!.description.validate()).body!.text,
                                                style: secondaryTextStyle(),
                                                trimLines: 3,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText: ' ...${language.readMore.toLowerCase()}',
                                                trimExpandedText: '  ${language.readLess.toLowerCase()}',
                                              ),
                                          Builder(
                                            builder: (context) {
                                              final parsedDate = parseReleaseDate(fragmentStore.currentMovie!.releaseDate.validate());
                                              return parsedDate != null ? ReleaseDateBadge(releaseDate: parsedDate).paddingSymmetric(vertical: 4) : SizedBox.shrink();
                                            },
                                          ),
                                          4.height,
                                          if (fragmentStore.currentMovie!.isRented.validate())
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                language.rented,
                                                style: primaryTextStyle(color: Colors.green, size: 16),
                                              ),
                                            ),
                                          8.height,

                                          /// Dynamic selection buttons
                                          Observer(
                                            builder: (context) => SelectionButtonsWidget(
                                              movie: fragmentStore.currentMovie!,
                                              genre: fragmentStore.genre,
                                              isTrailerPlaying: appStore.isTrailerVideoPlaying,
                                              isUpcoming: widget.movieData.isUpcoming == true,

                                              ///Stream Now button action
                                              onStreamNow: () {
                                                final movie = fragmentStore.currentMovie!;
                                                final hasAccess = movie.userHasAccess.validate();

                                                // Check if content requires purchase
                                                final requiresRent = movie.isRent == true && coreStore.isMembershipEnabled;
                                                final requiresSubscription =
                                                    movie.requiredPlan.validate().isNotEmpty && movie.requiredPlan.toString() != appStore.subscriptionPlanId && coreStore.isMembershipEnabled;

                                                // Prevent playback if requires purchase and user doesn't have access
                                                if (!hasAccess && (requiresRent || requiresSubscription)) {
                                                  toast(language.youDontHaveMembership);
                                                  return;
                                                }

                                                final canGuestStream = !appStore.isLogging && hasAccess;

                                                if (canGuestStream) {
                                                  appStore.setTrailerVideoPlayer(false);
                                                  return;
                                                }

                                                ensureUserPlaybackAllowed(context).then((allowed) {
                                                  if (allowed) {
                                                    appStore.setTrailerVideoPlayer(false);
                                                  }
                                                });
                                              },

                                              ///OnRent button action
                                              onRent: () {
                                                _handleRentPayment();
                                              },

                                              ///Remind Me button action
                                              onRemindMe: () {
                                                if (!appStore.isLogging) {
                                                  SignInScreen(redirectTo: () {}).launch(context);
                                                  return;
                                                }
                                                remindMe();
                                              },

                                              ///Resume Watching button action
                                              onResumeWatching: () {
                                                final movie = fragmentStore.currentMovie!;
                                                final hasAccess = movie.userHasAccess.validate();

                                                // Check if content requires purchase
                                                final requiresRent = movie.isRent == true && coreStore.isMembershipEnabled;
                                                final requiresSubscription =
                                                    movie.requiredPlan.validate().isNotEmpty && movie.requiredPlan.toString() != appStore.subscriptionPlanId && coreStore.isMembershipEnabled;

                                                // Prevent playback if requires purchase and user doesn't have access
                                                if (!hasAccess && (requiresRent || requiresSubscription)) {
                                                  toast(language.youDontHaveMembership);
                                                  return;
                                                }

                                                final watchedDuration = fragmentStore.currentMovie?.watchedDuration;
                                                if (watchedDuration != null && watchedDuration.watchedTime > 0) {
                                                  ///TODO: remove setStates
                                                  setState(() {
                                                    _watchedTime = watchedDuration.watchedTime.toString();
                                                  });
                                                  appStore.setTrailerVideoPlayer(false);
                                                }
                                              },

                                              ///Start From Beginning button action
                                              onStartFromBeginning: () {
                                                final movie = fragmentStore.currentMovie!;
                                                final hasAccess = movie.userHasAccess.validate();

                                                // Check if content requires purchase
                                                final requiresRent = movie.isRent == true && coreStore.isMembershipEnabled;
                                                final requiresSubscription =
                                                    movie.requiredPlan.validate().isNotEmpty && movie.requiredPlan.toString() != appStore.subscriptionPlanId && coreStore.isMembershipEnabled;

                                                // Prevent playback if requires purchase and user doesn't have access
                                                if (!hasAccess && (requiresRent || requiresSubscription)) {
                                                  toast(language.youDontHaveMembership);
                                                  return;
                                                }

                                                setState(() {
                                                  _watchedTime = '';
                                                });
                                                appStore.setTrailerVideoPlayer(false);
                                              },
                                            ),
                                          ),
                                        ],
                                      ).paddingSymmetric(horizontal: 8),

                                      8.height,
                                      MovieDetailLikeWatchListWidget(
                                        shareUrl: fragmentStore.currentMovie!.shareUrl.validate(),
                                        postId: fragmentStore.currentMovie!.id.validate(),
                                        postType: fragmentStore.currentMovie!.postType!,
                                        isInWatchList: fragmentStore.currentMovie!.isInWatchList,
                                        isLiked: fragmentStore.currentMovie!.isLiked.validate(),
                                        likes: fragmentStore.currentMovie!.likes,
                                        videoName: fragmentStore.currentMovie!.title.validate(),
                                        videoLink: fragmentStore.currentMovie!.file.validate(),
                                        videoImage: fragmentStore.currentMovie!.image.validate(),
                                        videoDescription: fragmentStore.currentMovie!.description.validate(),
                                        videoDuration: fragmentStore.currentMovie!.runTime.validate(),
                                        userHasAccess: fragmentStore.currentMovie!.userHasAccess.validate(),
                                        isTrailerVideoPlaying: appStore.isTrailerVideoPlaying,
                                        isUpcoming: fragmentStore.currentMovie!.isUpcoming.validate(),
                                        onAction: () {
                                          widget.onRemoveFromPlaylist?.call();
                                        },
                                        onPauseVideo: () {
                                          _headerKey.currentState?.pauseVideo();
                                        },
                                      ).paddingSymmetric(horizontal: 16),

                                      Divider(thickness: 0.1, color: Colors.grey.shade500).visible(fragmentStore.hasData),

                                      /// Cast section
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

                                      /// Crew section
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
                                      ],
                                      if (showCastSection || showCrewSection) Divider(thickness: 0.1, color: Colors.grey.shade500).paddingTop(16),
                                      if (fragmentStore.hasData)
                                        UpcomingRelatedMovieListWidget(
                                          snap: fragmentStore.movieResponse,
                                          showRecommended: coreStore.shouldShowRecommended,
                                          showRelatedVideos: coreStore.shouldShowRelatedVideo,
                                          showRelatedMovies: coreStore.shouldShowRelatedMovie,
                                        ),
                                      16.height,
                                      Observer(
                                        builder: (context) {
                                          return ReviewWidget(
                                            postType: fragmentStore.currentMovie!.postType!.name.validate(),
                                            postId: fragmentStore.currentMovie!.id,
                                            callReviewList: () {
                                              getReview();
                                            },
                                          ).paddingSymmetric(vertical: 16, horizontal: 16).visible(
                                                fragmentStore.currentMovie!.isRateReviewOpen.validate() && appStore.isLogging && !fragmentStore.currentMovie!.isUpcoming.validate(),
                                              );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      if (!fragmentStore.hasData && fragmentStore.hasMovieError) NoDataWidget(imageWidget: noDataImage(), title: language.noDataFound).center(),
                      Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)).center(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
