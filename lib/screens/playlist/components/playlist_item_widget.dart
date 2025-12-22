import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/screens/playlist/components/empty_playlist_widget.dart';
import 'package:streamit_flutter/screens/playlist/components/playlist_item_card_component.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

class PlayListItemWidget extends StatelessWidget {
  final String playlistType;
  final VoidCallback? onPlaylistDelete;
  final VoidCallback? onCreatePlaylist;

  const PlayListItemWidget({Key? key, required this.playlistType, this.onPlaylistDelete, this.onCreatePlaylist}) : super(key: key);

  String get noDataTitle {
    if (playlistType == playlistMovie) {
      return language.movies;
    } else if (playlistType == playlistEpisodes) {
      return language.episodes;
    } else {
      return language.videos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final future = playlistStore.playlistFutures[playlistType];

        if (future == null) {
          playlistStore.loadPlaylistByType(playlistType);
          return LoaderWidget();
        }

        return FutureBuilder<List<PlaylistModel>>(
          future: future,
          builder: (ctx, snap) {
            if (snap.hasData) {
              if (snap.data!.validate().isNotEmpty) {
                return ListView.builder(
                  padding: EdgeInsets.only(top: 8),
                  itemCount: snap.data!.length,
                  itemBuilder: (context, index) {
                    PlaylistModel playlistItem = snap.data.validate()[index];
                    return PlaylistItemCardComponent(
                      playlist: playlistItem,
                      onRefresh: () {
                        playlistStore.refreshPlaylist(playlistType);
                      },
                      onPlaylistDeleted: onPlaylistDelete,
                      playlistType: playlistType,
                    );
                  },
                );
              } else {
                return EmptyPlaylistWidget(onCreatePlaylist: onCreatePlaylist);
              }
            } else if (snap.hasError) {
              return NoDataWidget(imageWidget: noDataImage(), title: language.somethingWentWrong).center();
            }
            return LoaderWidget();
          },
        );
      },
    );
  }
}
