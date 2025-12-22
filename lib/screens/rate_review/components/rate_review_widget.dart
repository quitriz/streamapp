import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/rate_review_model.dart';
import 'package:streamit_flutter/screens/rate_review/components/add_rate_review_component.dart';
import 'package:streamit_flutter/screens/rate_review/components/reviews_item_component.dart';
import 'package:streamit_flutter/screens/rate_review/screens/review_list.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ReviewWidget extends StatelessWidget {
  final String postType;
  final int? postId;
  final Function callReviewList;

  ReviewWidget({super.key, required this.postType, required this.postId, required this.callReviewList});
  void showEditReviewDialog(BuildContext context, Review review) {
    TextEditingController reviewController = TextEditingController(text: review.rateContent.validate());
    double currentRating = review.rate?.toDouble() ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cardColor)),
          backgroundColor: context.cardColor,
          titlePadding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          title: Text(language.editReview, style: primaryTextStyle()),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: reviewController,
                style: secondaryTextStyle(),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: language.editYourReview,
                  hintStyle: secondaryTextStyle(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.withAlpha(128)),
                  ),
                ),
              ),
              12.height,
              Theme(
                data: ThemeData(
                  primaryColor: colorPrimary,
                  unselectedWidgetColor: colorPrimary,
                ),
                child: RatingBarWidget(
                  onRatingChanged: (rating) {
                    currentRating = rating;
                  },
                  rating: currentRating,
                  inActiveColor: colorPrimary,
                  allowHalfRating: false,
                  size: 20,
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            AppButton(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(8),
                side: BorderSide(color: Colors.white),
              ),
              color: context.cardColor,
              onTap: () {
                finish(context);
              },
              child: Text(
                language.cancel,
                style: primaryTextStyle(color: Colors.white, size: 14),
              ),
            ),
            8.width,
            AppButton(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(8),
                side: BorderSide(color: colorPrimary),
              ),
              color: colorPrimary,
              onTap: () async {
                if (reviewController.text.trim().isEmpty && currentRating == 0) {
                  toast(language.pleaseProvideRating);
                  return;
                }
                finish(context);
                await Future.delayed(Duration(milliseconds: 300));

                final success = await reviewStore.updateReview(
                  postId: postId!,
                  postType: postType,
                  userName: getStringAsync(USERNAME),
                  userEmail: getStringAsync(USER_EMAIL),
                  rateId: review.rateId!,
                  rating: currentRating,
                  reviewText: reviewController.text.trim(),
                );

                if (success) {
                  callReviewList();
                  toast(language.reviewUpdatedSuccessfully);
                } else {
                  toast(reviewStore.errorMessage ?? language.pleaseTryAgain);
                }
              },
              child: Text(
                language.update,
                style: boldTextStyle(color: Colors.white, size: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteReviewDialog(BuildContext context, Review review) {
    showConfirmDialogCustom(
      context,
      title: language.areYouSureYouWantToDeleteThisReview,
      primaryColor: colorPrimary,
      positiveText: language.delete,
      negativeText: language.cancel,
      onAccept: (value) async {
        final success = await reviewStore.deleteReview(
          postId: postId!,
          postType: postType,
          rateId: review.rateId!,
        );

        if (success) {
          toast(language.reviewDeletedSuccessfully);
          callReviewList();
        } else {
          toast(reviewStore.errorMessage ?? language.pleaseTryAgain);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final myReview = reviewStore.currentUserReview;
        final otherReviews = reviewStore.otherUserReviews;

        if (!reviewStore.hasReviews) {
          return AddRateReviewComponent(
            postType: postType,
            postId: postId.validate(),
            showReviews: postType == PostType.VIDEO,
            callForRefresh: () {
              callReviewList();
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (myReview != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.yourReview, style: boldTextStyle(size: 18)),
                      Row(
                        children: [
                          Text(language.edit, style: primaryTextStyle(color: context.primaryColor)).onTap(() => showEditReviewDialog(context, myReview)),
                          16.width,
                          Text(language.delete, style: primaryTextStyle(color: context.primaryColor)).onTap(() => _showDeleteReviewDialog(context, myReview)),

                        ],
                      ),
                    ],
                  ),
                  8.height,
                  ReviewsItemComponent(review: myReview),
                ],
              )
            else
              AddRateReviewComponent(
                postType: postType,
                postId: postId.validate(),
                showReviews: postType == PostType.VIDEO,
                callForRefresh: () {
                  callReviewList();
                },
              ),
            if (otherReviews.isNotEmpty) ...[
              24.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.reviews, style: boldTextStyle(size: 18)),
                      if (otherReviews.length > 2)
                        TextButton(
                          onPressed: () {
                            ViewAllRateReviewList(postType: postType, postId: postId.validate()).launch(context);
                          },
                          child: Text(language.viewAll, style: primaryTextStyle(color: context.primaryColor)),
                        ),
                    ],
                  ),
                  8.height,
                  ListView.separated(
                    itemCount: otherReviews.length > 2 ? 2 : otherReviews.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return ReviewsItemComponent(review: otherReviews[index]);
                    },
                    separatorBuilder: (_, __) => 16.height,
                  ),
                ],
              )
            ]
          ],
        );
      },
    );
  }
}
