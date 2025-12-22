import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';

class ComingSoonBadge extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double textSize;
  final double iconTextSpacing;
  final double borderRadius;
  final bool usePositioned;

  const ComingSoonBadge({
    Key? key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.horizontalPadding = 4,
    this.verticalPadding = 2,
    this.iconSize = 12,
    this.textSize = 10,
    this.iconTextSpacing = 4,
    this.borderRadius = 6,
    this.usePositioned = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: iconSize, color: Colors.white),
          SizedBox(width: iconTextSpacing),
          Text(
            language.comingSoon,
            style: boldTextStyle(size: textSize.toInt(), color: Colors.white),
          ),
        ],
      ),
    );

    if (usePositioned) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: badge,
      );
    }

    return badge;
  }
}
