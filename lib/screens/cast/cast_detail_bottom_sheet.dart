import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/cast_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/cast/components/cast_detail_bottom_sheet_shimmer_widget.dart';
import 'package:streamit_flutter/utils/common.dart';

class CastDetailBottomSheet extends StatelessWidget {
  final String? castId;

  const CastDetailBottomSheet({Key? key, this.castId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
          child: FutureBuilder<CastModel>(
            future: getCastDetails(castId!),
            builder: (context, snap) {
              if (snap.hasData) {
                CastModel cast = snap.data!;
                if (cast.data == null) {
                  return Center(child: Text(language.actorDetailsNotFound, style: primaryTextStyle()));
                }
                var actor = cast.data!;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 317,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedImageWidget(url: actor.image.validate(), fit: BoxFit.cover).cornerRadiusWithClipRRectOnly(topLeft: 34, topRight: 34),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Color(0xFF1E1E1E).withValues(alpha: 0.7), Color(0xFF1E1E1E)],
                                      stops: [0.3, 0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(actor.title.validate(), style: boldTextStyle(size: 18)).expand(),
                                  8.width,
                                  Text(actor.category.validate().toUpperCase(), style: boldTextStyle(color: context.primaryColor, size: 12)),
                                ],
                              ),
                              16.height,
                              ReadMoreText(
                                actor.description.validate(),
                                style: secondaryTextStyle(height: 1.5),
                                trimLines: 3,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: '...${language.readMore}',
                                trimExpandedText: ' ${language.readLess}',
                                colorClickableText: context.primaryColor,
                              ),
                              24.height,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  infoIcon(Icons.calendar_today_outlined, actor.birthday.validate(value: 'N/A'), context),
                                  if (actor.deathDay.validate().isNotEmpty) infoIcon(Icons.event_busy_outlined, actor.deathDay.validate(), context),
                                ],
                              ),
                              32.height,
                              if (cast.mostViewedContent.validate().isNotEmpty) ...[
                                Text("${language.movies} ${language.ofLabel} ${actor.title.validate()}", style: boldTextStyle(size: 16)),
                                16.height,
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemCount: cast.mostViewedContent!.length,
                                  itemBuilder: (context, index) {
                                    var movie = cast.mostViewedContent![index];
                                    return CommonListItemComponent(data: movie);
                                  },
                                ),
                              ]
                            ],
                          ).paddingSymmetric(horizontal: 16, vertical: 8),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => finish(context)),
                    ),
                  ],
                );
              }
              return snapWidgetHelper(
                snap,
                loadingWidget: CastBottomSheetShimmerWidget(),
                errorWidget: NoDataWidget(imageWidget: noDataImage(), title: language.somethingWentWrong).center(),
              ).center();
            },
          ),
        );
      },
    );
  }

  Widget infoIcon(IconData icon, String text, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: textSecondaryColorGlobal, size: 14),
        8.width,
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.width() * 0.4,
          ),
          child: Text(
            text,
            style: secondaryTextStyle(size: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
