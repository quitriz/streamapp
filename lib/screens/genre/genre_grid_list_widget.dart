import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streamit_flutter/models/genre_data.dart';
import 'package:streamit_flutter/screens/genre/genre_movie_list_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class GenreItemListWidget extends StatelessWidget {
  final List<GenreData> list;
  final String type;

  GenreItemListWidget(this.list, this.type);

  @override
  Widget build(BuildContext context) {
    final double availableWidth = context.width() - (16 * 2) - (16.0 * (3 - 1));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: list.map((data) {
          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              GenreMovieListScreen(genre: data.name, type: type, slug: data.slug.validate()).launch(context);
            },
            child: Container(
              width: availableWidth / 3,
              height: availableWidth / 3 / (126 / 150),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: data.genreImage.validate(), fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 26,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                      ),
                      child: Center(
                        child: Text('${parseHtmlString(data.name.validate())}',
                            style: boldTextStyle(size: 12),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

///Shimmer Effect
class GenreItemListShimmer extends StatelessWidget {
  const GenreItemListShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double availableWidth = context.width() - (16 * 2) - (16.0 * (3 - 1));

    return Shimmer.fromColors(
      baseColor: cardColor,
      highlightColor: navigationBackground,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: List.generate(12, (index) {
            return Container(
              width: availableWidth / 3,
              height: availableWidth / 3 / (126 / 150),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.white),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
