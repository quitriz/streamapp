import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/store/review_store.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class AddRateReviewComponent extends StatelessWidget {
  final int postId;
  final String? postType;
  final bool showReviews;
  final Function()? callForRefresh;
  final ReviewStore reviewStore = ReviewStore();

  AddRateReviewComponent({Key? key, required this.postId, this.callForRefresh, this.showReviews = false, this.postType}) : super(key: key);

  PostType? _getPostTypeFromString(String? postType) {
    if (postType == null) return null;

    String type = postType.toLowerCase();
    switch (type) {
      case ReviewConst.reviewTypeMovie:
        return PostType.MOVIE;
      case ReviewConst.reviewTypeTvShow:
        return PostType.TV_SHOW;
      case ReviewConst.reviewTypeVideo:
        return PostType.VIDEO;
      default:
        return PostType.MOVIE;
    }
  }

  String _getDisplayPostType() {
    PostType? postType = _getPostTypeFromString(this.postType);
    String result = getPostTypeString(postType);
    return result.isNotEmpty ? result.capitalizeFirstLetter() : 'Content';
  }

  Future<void> addRatings() async {
    if (reviewStore.hasUserReviewed) {
      toast(language.youHaveAlreadySubmittedReview);
      return;
    }

    if (reviewStore.reviewTextController.text.trim().isEmpty && reviewStore.selectedRating == 0) {
      toast(language.pleaseProvideRating);
      return;
    }

    final success = await reviewStore.submitReview(
      postId: postId,
      postType: postType.toString(),
      userName: getStringAsync(USERNAME),
      userEmail: getStringAsync(USER_EMAIL),
    );

    if (success) {
      toast(language.reviewSubmittedSuccessfully);
      callForRefresh?.call();
    } else {
      toast(reviewStore.errorMessage ?? language.pleaseTryAgain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          12.height,
          if (!showReviews)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${language.rateThis} ${_getDisplayPostType()}', style: boldTextStyle(size: 16)),
                8.height,
                RatingBarWidget(
                  onRatingChanged: (rating) {
                    reviewStore.setSelectedRating(rating);
                  },
                  activeColor: ratingBarColor,
                  inActiveColor: ratingBarColor,
                  rating: reviewStore.selectedRating,
                  size: 22,
                ),
                12.height,
              ],
            ).paddingSymmetric(horizontal: 8),
          AppTextField(
            controller: reviewStore.reviewTextController,
            textFieldType: TextFieldType.MULTILINE,
            maxLines: 5,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            textStyle: primaryTextStyle(color: textColorPrimary),
            errorThisFieldRequired: errorThisFieldRequired,
            decoration: InputDecoration(
              hintText: '${language.shareYourFavouriteThoughts} ${_getDisplayPostType()}',
              hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
              filled: true,
              fillColor: appBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          16.height,
          AppButton(
            text: language.submit,
            textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
            height: 48,
            width: context.width(),
            elevation: 0,
            color: context.primaryColor,
            splashColor: context.primaryColor.withValues(alpha: 0.2),
            onTap: () {
              hideKeyboard(context);
              if (reviewStore.selectedRating == 0) {
                toast(language.pleaseSelectRatingBeforeSubmittingYourReview);
                return;
              }
              addRatings();
            },
          ),
        ],
      ),
    );
  }
}
