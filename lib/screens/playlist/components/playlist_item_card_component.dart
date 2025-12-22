import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/common_action_bottom_sheet.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/playlist/components/edit_playlist_bottom_sheet.dart';
import 'package:streamit_flutter/screens/playlist/screens/playlist_medialist_screen.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class PlaylistItemCardComponent extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback? onRefresh;
  final VoidCallback? onPlaylistDeleted;
  final String? playlistType;

  const PlaylistItemCardComponent({Key? key, required this.playlist, this.onRefresh, this.onPlaylistDeleted, this.playlistType}) : super(key: key);

  Future<void> _deletePlaylist(context) async {
    Map req = {"playlist_id": playlist.playlistId};
    appStore.setLoading(true);
    try {
      await deletePlaylist(request: req, type: playlist.postType).then((value) {
        toast(value.message.validate());
        appStore.setLoading(false);
        finish(context);
        onRefresh?.call();
        onPlaylistDeleted?.call();
      });
    } catch (e) {
      appStore.setLoading(false);
      toast(language.somethingWentWrong);
      log("====>>>>Delete Playlist Error : ${e.toString()}");
    }
  }

  void showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EditPlaylistBottomSheet(playlist: playlist, onPlaylistUpdated: onRefresh),
      ),
    );
  }

  void showDeleteBottomSheet(BuildContext context) {
    showCommonActionBottomSheet(
      context: context,
      title: language.deleteConfirmation,
      subtitle: '${language.areYouSureYouWantToDelete} ${playlist.playlistName.validate()}?',
      icon: ic_delete,
      positiveText: language.delete,
      negativeText: language.cancel,
      positiveOnTap: () {
        _deletePlaylist(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: appBackground, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor, width: 1)),
      child: InkWell(
        onTap: () {
          PlaylistMediaScreen(playlistTitle: playlist.playlistName, playlistId: playlist.playlistId, playlistType: playlist.postType).launch(context).then((v) {
            onRefresh?.call();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 64,
                height: 64,
                child: CachedNetworkImage(
                  imageUrl: playlist.image.validate().isNotEmpty ? playlist.image.validate() : appStore.sliderDefaultImage.validate(),
                  fit: BoxFit.cover,
                  width: 64,
                  height: 64,
                ),
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playlist.playlistName.validate(),
                    style: boldTextStyle(size: textPrimarySizeGlobal.toInt()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.height,
                  Text(playlist.dataCount.validate(), style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt())),
                ],
              ),
            ),
            16.width,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => showEditBottomSheet(context),
                  child: CachedImageWidget(url: ic_edit, height: textPrimarySizeGlobal, width: textPrimarySizeGlobal, color: iconColor),
                ),
                16.width,
                InkWell(
                  onTap: () => showDeleteBottomSheet(context),
                  child: CachedImageWidget(url: ic_delete, height: textPrimarySizeGlobal, width: textPrimarySizeGlobal, color: iconColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
