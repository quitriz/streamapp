import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/models/movie_episode/rate_review_model.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/common.dart';

class ReviewsItemComponent extends StatelessWidget {
  final Review review;

  const ReviewsItemComponent({Key? key, required this.review}) : super(key: key);

  Widget _buildRatingStars(num rating) {
    int starCount = rating.toInt();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(index < starCount ? Icons.star : Icons.star_border, color: ratingBarColor, size: 18);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: radius(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CachedImageWidget(url: review.userImage.validate(), height: 40, width: 40, fit: BoxFit.cover).cornerRadiusWithClipRRect(20),
                  12.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName.validate(), style: boldTextStyle()),
                      4.height,
                      Text(convertToAgo(review.date.validate()), style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                ],
              ).expand(),
              8.width,
              _buildRatingStars(review.rate ?? 0),
            ],
          ),
          12.height,
          Text(review.rateContent.validate(), style: primaryTextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
