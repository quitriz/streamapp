import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class EmptyPlaylistWidget extends StatelessWidget {
  final VoidCallback? onCreatePlaylist;

  const EmptyPlaylistWidget({Key? key, this.onCreatePlaylist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      height: context.height(),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedImageWidget(url: userCircleDashed, color: context.primaryColor, width: 120, height: 120),
              ],
            ),
          ),
          50.height,
          Text(language.createPlaylist, style: boldTextStyle(size: 20), textAlign: TextAlign.center),
          16.height,
          Text(
            language.keepYourFavouriteStories,
            style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
            textAlign: TextAlign.center,
          ),
          32.height,
          AppButton(
            text: language.createPlaylist,
            textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
            onTap: onCreatePlaylist,
            height: 48,
            width: context.width(),
            elevation: 0,
            color: context.primaryColor,
            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ],
      ),
    );
  }
}
