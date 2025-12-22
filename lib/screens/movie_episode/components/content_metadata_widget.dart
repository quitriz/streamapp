import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class ContentMetaData extends StatelessWidget {
  final MovieData movieData;
  final String genre;
  final double? overallRating;

  const ContentMetaData({Key? key, required this.movieData, required this.genre, this.overallRating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (movieData.censorRating?.isNotEmpty ?? false)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: white,
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(movieData.censorRating!, style: boldTextStyle(size: 12, color: black)),
              ),
            16.width,
            if (genre.isNotEmpty) Text(genre, style: secondaryTextStyle(size: 12)),
          ],
        ),
        8.height,
        if (movieData.tag != null && movieData.tag!.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: movieData.tag!.map((tag) {
              return Chip(
                padding: EdgeInsets.all(0),
                label: Text(tag, style: secondaryTextStyle(size: 12)),
                backgroundColor: borderColor,
                shape: RoundedRectangleBorder(borderRadius: radius(4), side: BorderSide(color: transparentColor)),
              );
            }).toList(),
          ),
        4.height,
        if (movieData.runTime.validate().isNotEmpty || movieData.releaseDate.validate().isNotEmpty || movieData.imdbRating != null || movieData.views != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// Release Date
              if (movieData.releaseDate.validate().isNotEmpty && !movieData.isUpcoming.validate()) ...[
                Text(
                  getYearFromDate(movieData.releaseDate.validate()),
                  style: secondaryTextStyle(size: 12),
                ).visible(movieData.isUpcoming.validate()),
                8.width,
              ],

              /// Duration
              if (movieData.runTime.validate().isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: iconColor, size: 16),
                    4.width,
                    Text(
                      convertRuntimeToReadableFormat(movieData.runTime.validate()),
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),
                8.width,
              ],

              /// Rating
              if (overallRating != null) ...[
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: iconColor, size: 16),
                    4.width,
                    Text(overallRating.toString(), style: secondaryTextStyle(size: 12)),
                    8.width,
                  ],
                ),
              ],

              ///IMDB Rating
              if (movieData.imdbRating != null) ...[
                Row(
                  children: [
                    CachedImageWidget(
                      url: ic_imdb,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    4.width,
                    Text(
                      movieData.imdbRating.toString(),
                      style: secondaryTextStyle(size: 12),
                    ),
                    8.width,
                  ],
                ),
              ],

              /// View Counts
              if (coreStore.shouldShowViewCounter && movieData.views != null && movieData.isUpcoming == false) ...[
                Text('${movieData.views} ${language.views}', style: secondaryTextStyle(size: 12)),
              ]
            ],
          ),
      ],
    );
  }
}
