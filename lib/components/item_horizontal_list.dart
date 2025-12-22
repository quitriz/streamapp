import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/screens/live_tv/screens/channel_detail_screen.dart';

// ignore: must_be_immutable
class ItemHorizontalList extends StatelessWidget {
  List<CommonDataListModel> list = [];
  EdgeInsets? padding;
  bool isContinueWatch;
  bool isLandscape;
  final VoidCallback? refreshContinueWatchList;
  final bool isTop10;
  final bool isLiveTv;
  final bool isForDownload;
  final Function(CommonDataListModel)? onDeleteTap;
  final Function(CommonDataListModel)? onItemTap;

  ItemHorizontalList(
    this.list, {
    this.isContinueWatch = false,
    this.refreshContinueWatchList,
    this.padding,
    this.isTop10 = false,
    this.isLandscape = false,
    this.isLiveTv = false,
    this.isForDownload = false,
    this.onDeleteTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      alignment: Alignment.centerLeft,
      child: HorizontalList(
        itemCount: list.length,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          CommonDataListModel data = list[index];
          return Stack(
            children: [
              CommonListItemComponent(
                data: data,
                isLandscape: isLandscape,
                isContinueWatch: isContinueWatch,
                isLive: isLiveTv && !isContinueWatch,
                isForDownload: isForDownload,
                onTap: isForDownload
                    ? () {
                        onItemTap?.call(data);
                      }
                    : (isLiveTv && !isContinueWatch)
                        ? () {
                            ChannelDetailScreen(channelId: data.id.validate()).launch(context);
                          }
                        : null,
                onDeleteTap: isForDownload
                    ? (item) {
                        onDeleteTap?.call(item);
                      }
                    : null,
                callback: () => onTap.call,
              ),
              if (isTop10.validate())
                Positioned(
                  bottom: -9,
                  right: 4,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
