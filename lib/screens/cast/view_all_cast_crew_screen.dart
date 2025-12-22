import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_common_models.dart';
import 'package:streamit_flutter/screens/cast/cast_detail_bottom_sheet.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

enum CastCrewType { cast, crew }

class ViewAllCastCrewScreen extends StatelessWidget {
  final List<CommonDataDetailsModel>? people;
  final CastCrewType type;

  const ViewAllCastCrewScreen({
    Key? key,
    required this.type,
    this.people,
  }) : super(key: key);

  String get _title {
    return type == CastCrewType.cast ? language.cast : language.crew;
  }

  List<CommonDataDetailsModel> get _items => people ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(_title, style: boldTextStyle(size: default_appbar_size)),
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        centerTitle: false,
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: _items.isEmpty
          ? Center(
              child: Text(
                language.noDataFound,
                style: secondaryTextStyle(),
              ),
            )
          : _buildGridList(_items),
    );
  }
  Widget _buildGridList(List<CommonDataDetailsModel> list) {
    return Builder(
      builder: (context) {
        final double availableWidth = context.width() - (16 * 2) - (16.0 * (3 - 1));
        final double itemWidth = availableWidth / 3;
        // Calculate image height with portrait aspect ratio (approximately 1:1.4)
        final double imageHeight = itemWidth * 1.4;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: list.map((data) {
              return _buildCastCrewItem(context, data, itemWidth, imageHeight);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCastCrewItem(BuildContext context, CommonDataDetailsModel data, double width, double imageHeight) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CastDetailBottomSheet(castId: data.id.validate()),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: cardColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedImageWidget(
                url: data.image.validate().isEmpty ? appStore.personDefaultImage.validate() : data.image.validate(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: imageHeight,
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    parseHtmlString(data.name.validate()),
                    style: boldTextStyle(size: 12),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

