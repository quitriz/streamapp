import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/playlist/components/create_play_list_widget.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class PlaylistListWidget extends StatefulWidget {
  final String playlistType;
  final int postId;

  const PlaylistListWidget({Key? key, required this.playlistType, required this.postId}) : super(key: key);

  @override
  State<PlaylistListWidget> createState() => _PlaylistListWidgetState();
}

class _PlaylistListWidgetState extends State<PlaylistListWidget> {
  String get listKey => '${widget.playlistType}_${widget.postId}';
  String noDataTitle = '';

  @override
  void initState() {
    super.initState();
    playlistStore.loadPlaylistForPost(playlistType: widget.playlistType, postId: widget.postId);

    if (widget.playlistType == playlistMovie) {
      noDataTitle = language.movies;
    } else if (widget.playlistType == playlistTvShows) {
      noDataTitle = language.tVShows;
    } else if (widget.playlistType == playlistEpisodes) {
      noDataTitle = language.episodes;
    } else {
      noDataTitle = language.videos;
    }
  }

  Future<void> createPlayList(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CreatePlayListWidget(
          playlistType: widget.playlistType,
          onPlaylistCreated: () async {
            /// Refresh the playlist data
            await playlistStore.refreshPlaylistForPost(playlistType: widget.playlistType, postId: widget.postId);

            /// Get the latest playlists to find the newly created one
            try {
              List<PlaylistModel> updatedPlaylists = await getPlayListByType(type: widget.playlistType, postId: widget.postId);
              if (updatedPlaylists.isNotEmpty) {
                /// Find the newest playlist (assuming it's the last one or has the highest ID)
                PlaylistModel newestPlaylist = updatedPlaylists.last;

                /// Automatically add the current content to the newly created playlist
                Map req = {"playlist_id": newestPlaylist.playlistId, "post_id": widget.postId.validate()};

                await editPlaylistItems(request: req, type: widget.playlistType, playListId: newestPlaylist.playlistId.validate(), isDelete: false).then((value) {
                  toast(value.message.validate().isNotEmpty ? value.message! : '${language.contentAddedTo} ${newestPlaylist.playlistName}');

                  /// Close the bottom sheet after successful addition
                  finish(context);
                }).catchError((e) {
                  log("====>>>>Add to New Playlist Error : ${e.toString()}");
                  toast(language.somethingWentWrong);
                });
              }
            } catch (e) {
              log("====>>>>Error getting updated playlists : ${e.toString()}");

              /// Refresh the list even if auto-add fails
              await playlistStore.refreshPlaylistForPost(playlistType: widget.playlistType, postId: widget.postId);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: context.height() * 0.8,
      decoration: boxDecorationDefault(color: search_edittext_color, borderRadius: radiusOnly(topLeft: defaultRadius + 8, topRight: defaultRadius + 8)),
      child: Observer(builder: (context) {
        final isLoading = playlistStore.isPlaylistListLoadingForPost(widget.playlistType, widget.postId);
        final playlistData = playlistStore.getPlaylistListDataForPost(widget.playlistType, widget.postId);
        final playlistFuture = playlistStore.getPlaylistListFutureForPost(widget.playlistType, widget.postId);

        if (isLoading && playlistData.isEmpty) {
          return CircularProgressIndicator(strokeWidth: 2).center();
        }

        return FutureBuilder<List<PlaylistModel>>(
          future: playlistFuture,
          builder: (_, snap) {
            if (snap.hasData || playlistData.isNotEmpty) {
              final data = playlistData.isNotEmpty ? playlistData : snap.data.validate();
              if (data.isEmpty) {
                return NoDataWidget(
                  imageWidget: noDataImage(),
                  title: '${language.noPlaylistsFoundFor} $noDataTitle',
                  subTitle: '${language.createPlaylistAndAdd} $noDataTitle',
                  onRetry: () {
                    finish(context);
                    createPlayList(context);
                  },
                  retryText: language.createPlaylist,
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.addToPlaylist, style: boldTextStyle(size: 18)).paddingSymmetric(vertical: 8, horizontal: 16),
                        IconButton(
                          onPressed: () async {
                            await createPlayList(context);
                          },
                          icon: Icon(Icons.add, color: textColorSecondary, size: 24),
                          tooltip: language.createPlaylist,
                        ).paddingRight(8),
                      ],
                    ),
                    ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (ctx, index) {
                        PlaylistModel _data = data[index];

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: radius()),
                          child: TextIcon(
                            onTap: () {
                              Map req = {"playlist_id": _data.playlistId, "post_id": widget.postId.validate()};

                              editPlaylistItems(request: req, type: widget.playlistType, playListId: _data.playlistId, isDelete: _data.isInPlaylist).then((value) {
                                toast(value.message);
                                playlistStore.updatePlaylistItemStatus(listKey, _data.playlistId.validate(), !_data.isInPlaylist.validate());
                                finish(context);
                              }).catchError((e) {
                                log("====>>>>Add to Playlist Error : ${e.toString()}");
                                toast(language.somethingWentWrong);
                              });
                            },
                            text: _data.playlistName,
                            textStyle: primaryTextStyle(size: 18),
                            spacing: 16,
                            expandedText: true,
                            suffix: Container(
                              color: context.scaffoldBackgroundColor,
                              padding: EdgeInsets.all(4),
                              child: Icon(_data.isInPlaylist ? Icons.check : Icons.add, color: context.primaryColor, size: 20),
                            ),
                          ),
                        );
                      },
                    ).expand(),
                  ],
                );
              }
            } else if (snap.hasError) {
              log("====>Movie Detail Playlist Error : ${snap.error.toString()}");
              return Text(language.somethingWentWrong, style: primaryTextStyle(size: 22)).center();
            }
            return CircularProgressIndicator(strokeWidth: 2).center().paddingAll(16);
          },
        );
      }),
    );
  }
}
