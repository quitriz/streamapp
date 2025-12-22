import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/coming_soon_badge.dart';
import 'package:streamit_flutter/components/release_date_badge.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_common_models.dart';
import 'package:streamit_flutter/models/movie_episode/season_detail_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:streamit_flutter/screens/movie_episode/components/selection_button_widget.dart';
import 'package:streamit_flutter/screens/tv_show/components/episode_item_component.dart';
import 'package:streamit_flutter/screens/tv_show/components/episode_shimmer_effect.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class SeasonsAndEpisodesWidget extends StatefulWidget {
  final MovieData movie;
  final Future<void> Function(MovieData episode, int index, List<MovieData> episodes, {int? seasonNumber})? onEpisodeSelected;
  final bool userHasAccess;

  const SeasonsAndEpisodesWidget({Key? key, required this.movie, this.onEpisodeSelected, this.userHasAccess = true}) : super(key: key);

  @override
  _SeasonsAndEpisodesWidgetState createState() => _SeasonsAndEpisodesWidgetState();
}

class _SeasonsAndEpisodesWidgetState extends State<SeasonsAndEpisodesWidget> {
  final int previewCount = 3;
  int _currentPage = 1;
  bool _hasMoreEpisodes = true;
  bool _isPageFetching = false;

  List<CommonDataDetailsModel> get seasons => widget.movie.seasons!.data.validate();

  void _resetListKey() {}

  void _resetPaginationState() {
    _currentPage = 1;
    _hasMoreEpisodes = true;
    _isPageFetching = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEpisodes();
    });
  }

  void _initializeEpisodes() {
    if (!mounted || seasons.isEmpty) return;

    _resetPaginationState();

    final firstSeason = seasons.first;
    final currentShowId = widget.movie.id?.toString();

    final episodesBelongToCurrentShow =
        fragmentStore.allEpisodes.isNotEmpty && currentShowId != null && fragmentStore.allEpisodes.isNotEmpty && fragmentStore.allEpisodes.first.tvShowId?.toString() == currentShowId;

    if (fragmentStore.selectedSeason?.id != firstSeason.id || fragmentStore.allEpisodes.isEmpty || !episodesBelongToCurrentShow) {
      fragmentStore.setSelectedSeason(firstSeason);
      // Only load episodes if season is not upcoming
      if (firstSeason.isUpcoming != true) {
        _loadEpisodes();
      } else {
        // Clear episodes for upcoming seasons
        fragmentStore.setAllEpisodes([]);
        fragmentStore.setVisibleEpisodes([]);
        fragmentStore.setSeasonLoading(false);
      }
    } else if (fragmentStore.visibleEpisodes.isEmpty && fragmentStore.allEpisodes.isNotEmpty) {
      fragmentStore.setVisibleEpisodes(fragmentStore.allEpisodes.take(previewCount).toList());
    }
  }

  /// This function fetches episodes for the selected season
  Future<void> _loadEpisodes({bool loadMore = false}) async {
    if (fragmentStore.selectedSeason == null) return;

    // Skip loading episodes if season is upcoming
    if (fragmentStore.selectedSeason!.isUpcoming == true) {
      fragmentStore.setAllEpisodes([]);
      fragmentStore.setVisibleEpisodes([]);
      fragmentStore.setSeasonLoading(false);
      fragmentStore.setSeasonExpanded(false);
      _hasMoreEpisodes = false;
      return;
    }

    if (loadMore && (_isPageFetching || !_hasMoreEpisodes)) {
      return;
    }

    if (!loadMore) {
      _resetPaginationState();
      fragmentStore.setSeasonLoading(true);
      fragmentStore.setSeasonExpanded(false);
      fragmentStore.setVisibleEpisodes([]);
      fragmentStore.setAllEpisodes([]);
    }

    if (mounted) {
      setState(() {
        _isPageFetching = loadMore;
      });
    }

    final nextPage = loadMore ? _currentPage + 1 : 1;
    try {
      final Season seasonDetail = await tvShowSeasonDetail(showId: widget.movie.id.validate(), seasonId: fragmentStore.selectedSeason!.id.validate().toInt(), page: nextPage);
      final episodes = seasonDetail.episodes.validate();

      if (loadMore) {
        if (episodes.isNotEmpty) {
          final updatedAllEpisodes = List<MovieData>.from(fragmentStore.allEpisodes)..addAll(episodes);
          fragmentStore.setAllEpisodes(updatedAllEpisodes);

          if (fragmentStore.isSeasonExpanded) {
            final updatedVisibleEpisodes = List<MovieData>.from(fragmentStore.visibleEpisodes)..addAll(episodes);
            fragmentStore.setVisibleEpisodes(updatedVisibleEpisodes);
          }
        }
      } else {
        fragmentStore.setAllEpisodes(episodes);
        fragmentStore.setVisibleEpisodes(episodes.take(previewCount).toList());
      }

      _hasMoreEpisodes = episodes.length >= postPerPage;
      _currentPage = nextPage;
    } catch (e) {
      toast(e.toString());
      fragmentStore.setAllEpisodes([]);
      fragmentStore.setVisibleEpisodes([]);
    } finally {
      if (!loadMore) {
        fragmentStore.setSeasonLoading(false);
      }

      if (mounted) {
        setState(() {
          _isPageFetching = false;
        });
      }
    }
  }

  Future<void> _handleRemindMe() async {
    if (fragmentStore.selectedSeason == null || widget.movie.id == null) {
      toast(language.somethingWentWrong);
      return;
    }

    final currentSeason = fragmentStore.selectedSeason!;
    final currentIsRemind = currentSeason.isRemind.validate();

    // Create the updated season object for optimistic update
    final updatedSeason = CommonDataDetailsModel(
      id: currentSeason.id,
      name: currentSeason.name,
      releaseDate: currentSeason.releaseDate,
      image: currentSeason.image,
      isUpcoming: currentSeason.isUpcoming,
      isRemind: !currentIsRemind, // Toggle the remind status
    );

    await handleRemindMeWithOptimisticUI(
      context: context,
      contentId: widget.movie.id!,
      postType: ReviewConst.reviewTypeTvShow2,
      seasonId: currentSeason.id?.validate().toInt(),
      onOptimisticUpdate: () {
        fragmentStore.setSelectedSeason(updatedSeason);
      },
      onRollback: () {
        fragmentStore.setSelectedSeason(currentSeason);
      },
    );
  }

  /// Create a minimal MovieData object from season for use with SelectionButtonsWidget
  MovieData _createSeasonMovieData(CommonDataDetailsModel season) {
    return MovieData(
      id: season.id?.toInt() ?? 0,
      title: season.name ?? '',
      image: season.image,
      isUpcoming: season.isUpcoming ?? false,
      isRemind: season.isRemind ?? false,
      releaseDate: season.releaseDate,
      trailerLinkType: '',
      // Required field with default
      purchaseType: '',
      // Required field with default
      isRent: false,
      // Required field with default
      requiredPlan: [], // Required for SelectionButtonsWidget validation
    );
  }

  /// This function handles the animated expansion of the list
  void _expandList() {
    if (fragmentStore.isSeasonExpanded || !mounted) return;

    fragmentStore.setSeasonExpanded(true);

    // Create a safe copy of allEpisodes to avoid race conditions
    List<MovieData> safeAllEpisodes;
    try {
      safeAllEpisodes = List<MovieData>.from(fragmentStore.allEpisodes);
    } catch (e) {
      log('Error creating safe copy in _expandList: $e');
      return;
    }

    // Add remaining episodes with staggered delay for animation effect
    for (int i = previewCount; i < safeAllEpisodes.length; i++) {
      if (i >= safeAllEpisodes.length || !mounted) break;

      final episodeToAdd = safeAllEpisodes[i];
      Future.delayed(Duration(milliseconds: 100 * (i - previewCount)), () {
        if (mounted) {
          try {
            fragmentStore.addVisibleEpisode(episodeToAdd);
          } catch (e) {
            log('Error adding episode in _expandList: $e');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) return Offstage();

    return Observer(
      builder: (context) {
        final isLoading = fragmentStore.isSeasonLoading;
        final episodesList = fragmentStore.visibleEpisodes;
        final allEpisodes = fragmentStore.allEpisodes;
        final isExpanded = fragmentStore.isSeasonExpanded;
        final selectedSeason = fragmentStore.selectedSeason;

        // Create safe copies with null and empty checks
        List<MovieData> safeEpisodesList;
        List<MovieData> safeAllEpisodes;

        try {
          safeEpisodesList = episodesList.isNotEmpty ? List<MovieData>.from(episodesList) : <MovieData>[];
          safeAllEpisodes = allEpisodes.isNotEmpty ? List<MovieData>.from(allEpisodes) : <MovieData>[];
        } catch (e) {
          safeEpisodesList = <MovieData>[];
          safeAllEpisodes = <MovieData>[];
          log('Error creating safe list copies: $e');
        }

        final safeAllEpisodesCount = safeAllEpisodes.length;
        final finalItemCount = safeEpisodesList.length;
        final isValidState = finalItemCount > 0 && safeEpisodesList.isNotEmpty && !isLoading;

        final bool isSelectedSeasonUpcoming = selectedSeason?.isUpcoming == true;
        final bool showPaginationFooter = isExpanded && (_hasMoreEpisodes || _isPageFetching);
        final int listItemCount = finalItemCount + (showPaginationFooter ? 1 : 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            seasonSelector(),
            if (isSelectedSeasonUpcoming && !isLoading)
              _buildUpcomingSeasonUI(selectedSeason!)
            else if (isLoading)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: previewCount,
                itemBuilder: (_, __) => EpisodeShimmerComponent(),
              )
            else if (isValidState && finalItemCount > 0)
              ListView.builder(
                key: ValueKey('season_episodes_${selectedSeason?.id}_${finalItemCount}'),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: listItemCount,
                itemBuilder: (context, index) {
                  if (showPaginationFooter && index == finalItemCount) {
                    return _buildPaginationFooter();
                  }

                  // Triple-check bounds to prevent any index errors in release builds
                  if (index < 0 || index >= safeEpisodesList.length || safeEpisodesList.isEmpty || index >= finalItemCount) {
                    return SizedBox.shrink();
                  }

                  MovieData episode;
                  try {
                    if (index >= safeEpisodesList.length) {
                      return SizedBox.shrink();
                    }
                    episode = safeEpisodesList[index];
                  } catch (e) {
                    log('Error accessing episode at index $index: $e');
                    return SizedBox.shrink();
                  }

                  final bool isLastPreviewItem = index == previewCount - 1 && !isExpanded && safeAllEpisodesCount > previewCount;
                  final bool showDownloadIcon = (episode.episodeFile?.validate().isNotEmpty ?? false);

                  Widget episodeItem = Observer(
                    builder: (context) => EpisodeItemComponent(
                      episode: episode,
                      episodeIndex: index,
                      isSelected: fragmentStore.selectedEpisode?.id == episode.id,
                      showDownloadIcon: showDownloadIcon,
                      onTap: () async {
                        if (!widget.userHasAccess) {
                          return;
                        }

                        if (selectedSeason == null || !mounted) return;

                        if (episode.isUpcoming.validate()) {
                          return;
                        }
                        try {
                          final seasonIndex = seasons.indexOf(selectedSeason);
                          final seasonNumber = seasonIndex >= 0 ? seasonIndex + 1 : 1;
                          await widget.onEpisodeSelected?.call(episode, index, safeAllEpisodes, seasonNumber: seasonNumber);
                        } catch (e) {
                          log('Error in onEpisodeSelected: $e');
                        }
                      },
                    ),
                  );

                  if (isLastPreviewItem) {
                    return viewAllOverlay(episodeItem);
                  }
                  return episodeItem;
                },
              )
            else if (!isSelectedSeasonUpcoming)
              SizedBox.shrink()
          ],
        );
      },
    );
  }

  /// Builds the UI for upcoming seasons (ReleaseDateBadge + Remind Me button)
  Widget _buildUpcomingSeasonUI(CommonDataDetailsModel season) {
    return Observer(
      builder: (context) {
        final currentSeason = fragmentStore.selectedSeason ?? season;
        final releaseDateStr = currentSeason.releaseDate.validate();
        final parsedDate = releaseDateStr.isNotEmpty ? parseReleaseDate(releaseDateStr) : null;
        final seasonMovieData = _createSeasonMovieData(currentSeason);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            if (parsedDate != null) ReleaseDateBadge(releaseDate: parsedDate).paddingSymmetric(horizontal: 16) else SizedBox.shrink(),
            if (parsedDate != null) 16.height,
            SelectionButtonsWidget(
              movie: seasonMovieData,
              genre: '',
              isUpcoming: true,
              onRemindMe: _handleRemindMe,
            ).paddingSymmetric(horizontal: 16),
          ],
        );
      },
    );
  }

  Widget _buildPaginationFooter() {
    final seasonId = fragmentStore.selectedSeason?.id?.toString() ?? 'unknown';

    return VisibilityDetector(
      key: ValueKey('season_load_more_${seasonId}_page_$_currentPage'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          _loadEpisodes(loadMore: true);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isPageFetching) SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            if (!_isPageFetching) Text(language.loading.validate(value: 'Loading more...'), style: primaryTextStyle(size: 12)),
          ],
        ),
      ),
    );
  }

  /// Builds the stack with the gradient and "View All" button
  Widget viewAllOverlay(Widget child) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: radius(),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, cardColor.withValues(alpha: 0.7), cardColor.withValues(alpha: 0.9)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        AppButton(
          text: language.viewAll,
          padding: EdgeInsets.all(6),
          height: 32,
          width: 115,
          color: Color(0xFF393939),
          textStyle: primaryTextStyle(size: 14, weight: FontWeight.w500),
          onTap: _expandList,
          shapeBorder: RoundedRectangleBorder(borderRadius: radius(8), side: BorderSide(width: 1, color: Colors.transparent)),
        ),
      ],
    );
  }

  Widget seasonSelector() {
    return HorizontalList(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        final season = seasons[index];
        final bool isSelected = fragmentStore.selectedSeason?.id == season.id;
        final bool isUpcoming = season.isUpcoming == true;

        return AppButton(
          height: 32,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          onTap: () {
            if (fragmentStore.selectedSeason?.id == season.id) return;
            fragmentStore.setSelectedSeason(season);
            fragmentStore.setAllEpisodes([]);
            fragmentStore.setVisibleEpisodes([]);
            fragmentStore.setSeasonExpanded(false);
            _resetPaginationState();
            setState(() {
              _resetListKey();
            });
            if (season.isUpcoming != true) {
              _loadEpisodes();
            } else {
              fragmentStore.setSeasonLoading(false);
            }
          },
          color: isSelected ? context.primaryColor : appBackground,
          shapeBorder: RoundedRectangleBorder(
            borderRadius: radius(34),
            side: BorderSide(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                season.name.validate(),
                style: boldTextStyle(color: isSelected ? Colors.white : textPrimaryColorGlobal),
              ),
              if (isUpcoming) ...[6.width, ComingSoonBadge(usePositioned: false)],
            ],
          ),
        ).paddingRight(8);
      },
    );
  }
}
