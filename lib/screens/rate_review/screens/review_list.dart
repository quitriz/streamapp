import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/rate_review/components/reviews_item_component.dart';
import 'package:streamit_flutter/store/review_store.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ViewAllRateReviewList extends StatelessWidget {
  final String postType;
  final int postId;
  final String? movieTitle;
  final ReviewStore reviewStore = ReviewStore();

  ViewAllRateReviewList({super.key, required this.postType, required this.postId, this.movieTitle});

  @override
  Widget build(BuildContext context) {
    // Fetch initial reviews when the screen loads.
    afterBuildCreated(() {
      reviewStore.fetchReviews(postType: postType, postId: postId);
    });

    /// Helper widget for a single progress bar row in the summary card.
    Widget _buildRatingProgressBarRow({required int star, required int count, required int total}) {
      final Map<int, Color> starColors = {
        5: reviewColor5,
        4: reviewColor4,
        3: reviewColor3,
        2: reviewColor2,
        1: reviewColor1,
      };

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Icon(Icons.star, color: ratingBarColor, size: 16),
            4.width,
            Text('$star', style: secondaryTextStyle(color: white)),
            8.width,
            LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(starColors[star] ?? Colors.grey),
              minHeight: 8,
              borderRadius: radius(4),
            ).expand(),
            8.width,
            Text(count.toString(), style: secondaryTextStyle(size: 14), textAlign: TextAlign.end).withWidth(40),
          ],
        ),
      );
    }

    /// Builds the top card showing the average rating and star breakdown.
    Widget _buildAverageRatingSummary() {
      if (!reviewStore.hasReviews) return SizedBox.shrink();

      final totalReviews = reviewStore.reviewList.length;
      final double avgRating = reviewStore.averageRating;
      final Map<int, int> starCounts = reviewStore.starCounts;

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: appBackground, borderRadius: radius()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${avgRating.toStringAsFixed(1)}/5', style: boldTextStyle(size: 28)),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBarWidget(onRatingChanged: (_) {}, rating: avgRating, size: 20, allowHalfRating: true, disable: true, activeColor: ratingBarColor, inActiveColor: ratingBarColor),
                    8.height,
                    Text(language.basedOnIndividualRating, style: secondaryTextStyle()),
                  ],
                ),
              ],
            ),
            ...starCounts.entries.map((entry) {
              return _buildRatingProgressBarRow(star: entry.key, count: entry.value, total: totalReviews);
            }).toList(),
          ],
        ),
      );
    }

    /// Builds the header for the reviews list, including the filter button.
    Widget _buildAllReviewsHeader() {
      return Observer(
        builder: (_) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.allReviews, style: boldTextStyle(size: 20)),
            PopupMenuButton<ReviewFilter>(
              initialValue: reviewStore.selectedFilter,
              onSelected: (ReviewFilter result) {
                if (reviewStore.selectedFilter != result) {
                  reviewStore.setSelectedFilter(result);
                  reviewStore.fetchReviews(postType: postType, postId: postId, filter: result);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<ReviewFilter>>[
                for (var filter in ReviewFilter.values) PopupMenuItem<ReviewFilter>(value: filter, child: Text(filter.name.capitalizeFirstLetter())),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.import_export_rounded, size: 16, color: textSecondaryColorGlobal),
                    8.width,
                    Text(reviewStore.selectedFilter.name.capitalizeFirstLetter(), style: secondaryTextStyle()),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// Builds the scrollable list of reviews using your `ReviewsComponent`.
    Widget _buildReviewsListView() {
      return Observer(
        builder: (_) => Stack(
          children: [
            // Reviews content
            if (!reviewStore.hasReviews && !reviewStore.isLoadingReviews)
              Center(
                child: Column(
                  children: [
                    50.height,
                    Text(language.noReviewsYet, style: boldTextStyle(size: 18)),
                    8.height,
                    Text(language.beTheFirstOne, style: secondaryTextStyle()),
                  ],
                ),
              )
            else if (reviewStore.hasReviews)
              ListView.separated(
                itemCount: reviewStore.reviewList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ReviewsItemComponent(review: reviewStore.reviewList[index]);
                },
                separatorBuilder: (_, __) => 16.height,
              )
            else
              SizedBox(height: 200),

            if (reviewStore.isLoadingReviews)
              Container(
                height: 200,
                child: LoaderWidget(),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(language.reviewsRatings, style: boldTextStyle(size: 20)),
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
      ),
      body: Observer(
        builder: (_) => ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            if (reviewStore.hasReviews && !reviewStore.isLoadingReviews) _buildAverageRatingSummary(),
            if (reviewStore.hasReviews && !reviewStore.isLoadingReviews) 24.height,
            _buildAllReviewsHeader(),
            16.height,
            _buildReviewsListView(),
          ],
        ),
      ),
    );
  }
}
