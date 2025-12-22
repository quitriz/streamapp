import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class CastBottomSheetShimmerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 317,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 18, width: context.width() * 0.6, color: Colors.white),
                    8.width,
                    Container(height: 12, width: context.width() * 0.2, color: Colors.white),
                  ],
                ),
                16.height,

                Container(height: 14, width: double.infinity, color: Colors.white),
                8.height,
                Container(height: 14, width: double.infinity, color: Colors.white),
                8.height,
                Container(height: 14, width: context.width() * 0.7, color: Colors.white),
                24.height,

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(height: 16, width: context.width() * 0.4, color: Colors.white).expand(),
                    Container(height: 16, width: context.width() * 0.4, color: Colors.white).expand(),
                  ],
                ),
                32.height,

                Container(height: 16, width: context.width() * 0.5, color: Colors.white),
                16.height,

                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ],
            ).paddingSymmetric(horizontal: 16, vertical: 8),
          ],
        ),
      ),
    );
  }
}
