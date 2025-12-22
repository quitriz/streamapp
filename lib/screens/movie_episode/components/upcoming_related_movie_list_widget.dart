import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/item_horizontal_list.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_response.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';

class UpcomingRelatedMovieListWidget extends StatelessWidget {
  final MovieDetailResponse? snap;
  final bool showRecommended;
  final bool showRelatedVideos;
  final bool showRelatedMovies;

  UpcomingRelatedMovieListWidget({this.snap, this.showRecommended = true, this.showRelatedVideos = true, this.showRelatedMovies = true});

  @override
  Widget build(BuildContext context) {
    if (snap == null) return Offstage();

    final hasUpcomingMovies = snap!.upcomingMovie.validate().isNotEmpty;
    final hasRecommended = snap!.recommendedMovie.validate().isNotEmpty;
    final hasUpcomingVideos = snap!.upcomingVideo.validate().isNotEmpty;
    final hasRelatedVideos = snap!.relatedVideos.validate().isNotEmpty;
    final hasRelatedMovies = snap!.relatedMovies.validate().isNotEmpty;

    if (!hasUpcomingMovies && !hasRecommended && !hasUpcomingVideos && !hasRelatedVideos && !hasRelatedMovies) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasUpcomingMovies) ...[
          headingWidViewAll(context, language.upcomingMovies, showViewMore: false),
          ItemHorizontalList(snap!.upcomingMovie!),
        ],
        if (showRecommended && hasRecommended) ...[
          headingWidViewAll(context, language.recommendedMovies, showViewMore: false),
          ItemHorizontalList(snap!.recommendedMovie!),
        ],
        if (hasUpcomingVideos) ...[
          headingWidViewAll(context, language.upcomingVideo, showViewMore: false),
          ItemHorizontalList(snap!.upcomingVideo!),
        ],
        if (showRelatedVideos && hasRelatedVideos) ...[
          headingWidViewAll(context, language.relatedVideos, showViewMore: false),
          ItemHorizontalList(snap!.relatedVideos!),
        ],
        if (showRelatedMovies && hasRelatedMovies) ...[
          headingWidViewAll(context, language.relatedMovies, showViewMore: false),
          ItemHorizontalList(snap!.relatedMovies!),
        ],
      ],
    );
  }
}
