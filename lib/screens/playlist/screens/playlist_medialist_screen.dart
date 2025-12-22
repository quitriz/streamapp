import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class PlaylistMediaScreen extends StatefulWidget {
  final int playlistId;
  final String playlistTitle;
  final String playlistType;

  const PlaylistMediaScreen({Key? key, required this.playlistId, required this.playlistTitle, required this.playlistType}) : super(key: key);

  @override
  State<PlaylistMediaScreen> createState() => _PlaylistMediaScreenState();
}

class _PlaylistMediaScreenState extends State<PlaylistMediaScreen> {
  String get mediaKey => playlistStore.getPlaylistMediaKey(widget.playlistId, widget.playlistType);

  @override
  void initState() {
    super.initState();
    playlistStore.initializePlaylistMediaKey(mediaKey);
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    try {
      playlistStore.setPlaylistMediaError(mediaKey, false);
      playlistStore.setPlaylistMediaLoading(mediaKey, true);

      final currentPage = playlistStore.getPlaylistMediaCurrentPage(mediaKey);
      final data = await getPlayListMedia(playlistId: widget.playlistId, postType: widget.playlistType, page: currentPage);

      playlistStore.setPlaylistMediaLastPage(mediaKey, data.length != 7);
      playlistStore.setPlaylistMediaData(mediaKey, data, isRefresh: currentPage == 1);
    } catch (e) {
      playlistStore.setPlaylistMediaError(mediaKey, true);
      log("Error Log ===== $e");
      toast(language.somethingWentWrong);
      log("====>>>>>Playlist Media Error : ${e.toString()}");
    } finally {
      playlistStore.setPlaylistMediaLoading(mediaKey, false);
    }
  }

  Future<void> deleteMovieFromPlaylist({required CommonDataListModel movieData, required int playlistId, required int postId, required String postType}) async {
    try {
      Map req = {
        "playlist_id": playlistId,
        "post_id": postId,
      };

      playlistStore.setPlaylistMediaLoading(mediaKey, true);
      final response = await editPlaylistItems(request: req, type: widget.playlistType, playListId: playlistId, isDelete: true);

      toast(response.message);
      playlistStore.removePlaylistMediaItem(mediaKey, movieData);
    } catch (e) {
      log("====>>>>Delete From Playlist Error : ${e.toString()}");
      toast(language.somethingWentWrong);
    } finally {
      playlistStore.setPlaylistMediaLoading(mediaKey, false);
    }
  }

  @override
  void dispose() {
    playlistStore.setPlaylistMediaLoading(mediaKey, false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.playlistTitle, style: boldTextStyle(size: 22)),
      ),
      body: Stack(
        children: [
          Observer(
            builder: (context) {
              final playlistMediaList = playlistStore.getPlaylistMediaByKey(mediaKey);
              final isLoading = playlistStore.isPlaylistMediaLoading(mediaKey);
              final isLastPage = playlistStore.isPlaylistMediaLastPage(mediaKey);

              return AnimatedListView(
                itemCount: playlistMediaList.length,
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 50, top: 8),
                itemBuilder: (_, index) {
                  CommonDataListModel _data = playlistMediaList[index];
                  return GestureDetector(
                    onTap: () {
                      MovieDetailScreen(
                        movieData: _data,
                        playList: playlistMediaList,
                        currentIndex: index,
                        onRemoveFromPlaylist: () {
                          init();
                        },
                      ).launch(context);
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Color(0xFF484848), blurRadius: 2.0)],
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(imageUrl: _data.image.validate(), height: 80, width: 70, fit: BoxFit.fill).cornerRadiusWithClipRRect(8),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_data.title.validate(), style: primaryTextStyle(size: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                              4.height,
                              Text(_data.runTime.validate(), style: secondaryTextStyle()),
                            ],
                          ).expand(),
                          8.width,
                          IconButton(
                            onPressed: () {
                              deleteMovieFromPlaylist(
                                movieData: _data,
                                postType: _data.postType == PostType.MOVIE
                                    ? playlistMovie
                                    : _data.postType == PostType.TV_SHOW
                                        ? playlistTvShows
                                        : playlistVideo,
                                playlistId: widget.playlistId,
                                postId: _data.id.validate(),
                              );
                            },
                            color: colorPrimary,
                            icon: Icon(Icons.delete_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onNextPage: () {
                  if (!isLastPage && !isLoading) {
                    final nextPage = playlistStore.getPlaylistMediaCurrentPage(mediaKey) + 1;
                    playlistStore.setPlaylistMediaCurrentPage(mediaKey, nextPage);
                    init();
                  }
                },
              );
            },
          ),
          Observer(
            builder: (_) {
              final isLoading = playlistStore.isPlaylistMediaLoading(mediaKey);
              final isEmpty = playlistStore.isPlaylistMediaEmpty(mediaKey);
              final hasError = playlistStore.hasPlaylistMediaError(mediaKey);

              if (!isLoading && isEmpty) {
                if (hasError) {
                  return NoDataWidget(imageWidget: noDataImage(), title: language.somethingWentWrong).center();
                } else {
                  return NoDataWidget(
                    imageWidget: noDataImage(),
                    title: '${widget.playlistTitle} ${language.isEmpty}',
                    subTitle: '${language.contentAddedTo} ${widget.playlistTitle}, ${language.willBeShownHere}',
                  );
                }
              } else {
                return Offstage();
              }
            },
          ),
          Observer(
            builder: (_) {
              final isLoading = playlistStore.isPlaylistMediaLoading(mediaKey);
              final currentPage = playlistStore.getPlaylistMediaCurrentPage(mediaKey);

              if (currentPage == 1) {
                return LoaderWidget().center().visible(isLoading);
              } else {
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: LoadingDotsWidget(),
                ).visible(isLoading);
              }
            },
          ),
        ],
      ),
    );
  }
}
