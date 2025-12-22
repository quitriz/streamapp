import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class CommonListItemShimmer extends StatelessWidget {
  final bool isLandscape;
  final bool isContinueWatch;
  final bool isVerticalList;
  final bool isViewAll;
  final double? width;

  const CommonListItemShimmer({super.key, this.isLandscape = false, this.isContinueWatch = false, this.isVerticalList = false, this.isViewAll = false, this.width});

  double getWidth(BuildContext context) {
    double width = 140;

    if (context.width() < 400) {
      width = context.width() / 2 - 20;
    } else {
      width = context.width() / 3 - 16;
    }

    return width;
  }

  double getViewAllWidth(BuildContext context) {
    double width = 140;

    if (context.width() < 300) {
      width = context.width() / 2 - 20;
    } else {
      width = context.width() / 3 - 16;
    }

    return width;
  }


  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade600,
      child: isLandscape ? landscapeShimmer(context) : portraitShimmer(context),
    );
  }

  Widget landscapeShimmer(BuildContext context) {
    final double shimmerWidth = isContinueWatch ? 220 : width ?? context.width() / 2 - 22;

    final double shimmerHeight = isContinueWatch ? 125 : context.height() * 0.12;

    return Container(
      width: shimmerWidth,
      height: shimmerHeight,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(defaultRadius)),
    );
  }

  Widget portraitShimmer(BuildContext context) {
    final double shimmerHeight = isViewAll ? 160 : 200;
    final double shimmerWidth = isVerticalList ? (isViewAll ? getViewAllWidth(context) : getWidth(context)) : 140;

    return Container(
      height: shimmerHeight,
      width: shimmerWidth,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius_container)),
    );
  }
}
