import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class EpisodeShimmerComponent extends StatelessWidget {
  const EpisodeShimmerComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image Placeholder
            Container(
              height: 62,
              width: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
            16.width,

            /// Text Placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  4.height,
                  Container(height: 14, width: context.width() * 0.3, color: Colors.white),
                  8.height,
                  Container(height: 12, width: context.width() * 0.4, color: Colors.white),
                ],
              ),
            ),
            16.width,

            /// Icon Placeholders
            Container(height: 20, width: 20, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            8.width,
            Container(height: 20, width: 20, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ],
        ),
      ),
    ).paddingSymmetric(horizontal: 16, vertical: 8);
  }
}
