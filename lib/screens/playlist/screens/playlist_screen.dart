import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/screens/playlist/components/create_play_list_widget.dart';
import 'package:streamit_flutter/screens/playlist/components/playlist_item_widget.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({Key? key}) : super(key: key);

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  late TabController tabController;
  GlobalKey movieKey = GlobalKey();
  GlobalKey episodesKey = GlobalKey();
  GlobalKey videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = BottomSheet.createAnimationController(this);
    controller.duration = const Duration(milliseconds: 350);
    controller.reverseDuration = const Duration(milliseconds: 350);
    controller.drive(CurveTween(curve: Curves.ease));
    tabController = TabController(length: 3, vsync: this);
    playlistStore.setSelectedTabIndex(0);

    playlistStore.initializePlaylistTypes();
    playlistStore.refreshAllPlaylists();
  }

  Future<void> createPlayList(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      transitionAnimationController: controller,
      builder: (_) {
        return CreatePlayListWidget(
          onPlaylistCreated: () async {
            await playlistStore.refreshPlaylist(playlistStore.selectedPlaylistType);
          },
          playlistType: playlistStore.selectedPlaylistType,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    tabController.dispose();
    super.dispose();
  }

  Widget chipButton(String title, int index) {
    return Observer(
      builder: (_) {
        bool isSelected = playlistStore.selectedTabIndex == index;
        return GestureDetector(
          onTap: () {
            playlistStore.setSelectedTabIndex(index);
            tabController.animateTo(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? colorPrimary : appBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSelected ? colorPrimary : borderColor, width: 1),
            ),
            child: Text(
              title,
              style: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: AppBar(
          backgroundColor: appBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(language.playlist, style: boldTextStyle(size: 18)),
          actions: [
            TextButton(
              onPressed: () {
                createPlayList(context);
              },
              child: Text(language.createPlaylist, style: boldTextStyle(size: textSecondarySizeGlobal.toInt(), color: colorPrimary)),
            ).paddingOnly(right: 16),
          ],
          bottom: PreferredSize(
            preferredSize: Size(context.width(), 70),
            child: Container(
              color: appBackground,
              padding: EdgeInsets.symmetric(horizontal: context.width() > 400 ? 24 : 16, vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TabBar(
                  isScrollable: true,
                  indicatorWeight: 0.0,
                  indicatorColor: Colors.transparent,
                  indicator: BoxDecoration(),
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.start,
                  onTap: (i) {
                    playlistStore.setSelectedTabIndex(i);
                    if (i == 0) {
                      LiveStream().emit(RefreshHome);
                    }
                  },
                  labelPadding: EdgeInsets.only(right: context.width() > 400 ? 16 : 12),
                  tabs: [
                    chipButton(language.movies, 0),
                    chipButton(language.episodes, 1),
                    chipButton(language.videos, 2),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            PlayListItemWidget(
              key: movieKey,
              playlistType: playlistMovie,
              onPlaylistDelete: () async {
                await playlistStore.refreshPlaylist(playlistMovie);
              },
              onCreatePlaylist: () {
                playlistStore.setSelectedPlaylistType(playlistMovie);
                createPlayList(context);
              },
            ),
            PlayListItemWidget(
              key: episodesKey,
              playlistType: playlistEpisodes,
              onPlaylistDelete: () async {
                await playlistStore.refreshPlaylist(playlistEpisodes);
              },
              onCreatePlaylist: () {
                playlistStore.setSelectedPlaylistType(playlistEpisodes);
                createPlayList(context);
              },
            ),
            PlayListItemWidget(
              key: videoKey,
              playlistType: playlistVideo,
              onPlaylistDelete: () async {
                await playlistStore.refreshPlaylist(playlistVideo);
              },
              onCreatePlaylist: () {
                playlistStore.setSelectedPlaylistType(playlistVideo);
                createPlayList(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
