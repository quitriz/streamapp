import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/common/data_model.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart' as api;
import 'package:streamit_flutter/utils/constants.dart';

part 'playlist_store.g.dart';

class PlaylistStore = PlaylistStoreBase with _$PlaylistStore;

abstract class PlaylistStoreBase with Store {
  // Tab selection
  @observable
  int selectedTabIndex = 0;

  @observable
  String selectedPlaylistType = playlistMovie;

  // Playlist type selection for creation
  @observable
  DataModel? selectedPlaylistTypeModel;

  @observable
  ObservableList<DataModel> playListTypeList = ObservableList<DataModel>();

  // Loading states
  @observable
  bool isLoading = false;

  @observable
  bool isCreatingPlaylist = false;

  // Playlist data
  @observable
  ObservableMap<String, Future<List<PlaylistModel>>> playlistFutures = ObservableMap<String, Future<List<PlaylistModel>>>();

  @observable
  ObservableMap<String, List<PlaylistModel>> playlistData = ObservableMap<String, List<PlaylistModel>>();

  // Actions
  @action
  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    
    if (index == 0) {
      setSelectedPlaylistType(playlistMovie);
    } else if (index == 1) {
      setSelectedPlaylistType(playlistEpisodes);
    } else {
      setSelectedPlaylistType(playlistVideo);
    }
  }

  @action
  void setSelectedPlaylistType(String type) {
    selectedPlaylistType = type;
  }

  @action
  void setSelectedPlaylistTypeModel(DataModel? model) {
    selectedPlaylistTypeModel = model;
  }

  @action
  void setLoading(bool loading) {
    isLoading = loading;
  }

  @action
  void setCreatingPlaylist(bool creating) {
    isCreatingPlaylist = creating;
  }

  @action
  void initializePlaylistTypes() {
    playListTypeList.clear();
    playListTypeList.add(DataModel(title: 'Movies', data: playlistMovie));
    playListTypeList.add(DataModel(title: 'Episodes', data: playlistEpisodes));
    playListTypeList.add(DataModel(title: 'Videos', data: playlistVideo));
    
    if (selectedPlaylistTypeModel == null) {
      selectedPlaylistTypeModel = playListTypeList.first;
    }
  }

  @action
  Future<void> loadPlaylistByType(String type) async {
    try {
      setLoading(true);
      final future = api.getPlayListByType(type: type);
      playlistFutures[type] = future;
      
      final data = await future;
      playlistData[type] = data;
      setLoading(false);
    } catch (e) {
      setLoading(false);
      log('Error loading playlist: ${e.toString()}');
    }
  }

  @action
  Future<void> refreshPlaylist(String type) async {
    await loadPlaylistByType(type);
  }

  @action
  Future<void> refreshAllPlaylists() async {
    await Future.wait([
      loadPlaylistByType(playlistMovie),
      loadPlaylistByType(playlistEpisodes),
      loadPlaylistByType(playlistVideo),
    ]);
  }

  @action
  Future<bool> createPlaylist({
    required String playlistName,
    required String playlistType,
  }) async {
    try {
      setCreatingPlaylist(true);
      
      Map req = {"title": playlistName};
      await api.createOrEditPlaylist(request: req, type: playlistType);
      
      // Refresh the specific playlist type
      await refreshPlaylist(playlistType);
      
      setCreatingPlaylist(false);
      return true;
    } catch (e) {
      setCreatingPlaylist(false);
      log("Create Playlist Error : ${e.toString()}");
      return false;
    }
  }

  @action
  Future<bool> editPlaylist({
    required int playlistId,
    required String playlistName,
    required String playlistType,
  }) async {
    try {
      setLoading(true);
      
      Map req = {"title": playlistName, "id": playlistId};
      await api.createOrEditPlaylist(request: req, type: playlistType);
      
      // Refresh the specific playlist type
      await refreshPlaylist(playlistType);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      log("Edit Playlist Error : ${e.toString()}");
      return false;
    }
  }

  @action
  Future<bool> deletePlaylist({
    required int playlistId,
    required String playlistType,
  }) async {
    try {
      setLoading(true);
      
      Map req = {"id": playlistId};
      await api.deletePlaylist(request: req, type: playlistType);
      
      // Refresh the specific playlist type
      await refreshPlaylist(playlistType);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      log("Delete Playlist Error : ${e.toString()}");
      return false;
    }
  }

  // Computed values
  @computed
  Future<List<PlaylistModel>>? get currentPlaylistFuture => playlistFutures[selectedPlaylistType];

  @computed
  List<PlaylistModel> get currentPlaylistData => playlistData[selectedPlaylistType] ?? [];

  @computed
  String get currentNoDataTitle {
    if (selectedPlaylistType == playlistMovie) {
      return 'Movies';
    } else if (selectedPlaylistType == playlistEpisodes) {
      return 'Episodes';
    } else {
      return 'Videos';
    }
  }

  //region Playlist Media State

  @observable
  ObservableMap<String, ObservableList<CommonDataListModel>> playlistMediaData = ObservableMap<String, ObservableList<CommonDataListModel>>();

  @observable
  ObservableMap<String, bool> playlistMediaLoading = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> playlistMediaLastPage = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, int> playlistMediaCurrentPage = ObservableMap<String, int>();

  @observable
  ObservableMap<String, bool> playlistMediaHasError = ObservableMap<String, bool>();

  @action
  void initializePlaylistMediaKey(String key) {
    if (!playlistMediaData.containsKey(key)) {
      playlistMediaData[key] = ObservableList<CommonDataListModel>();
      playlistMediaLoading[key] = false;
      playlistMediaLastPage[key] = false;
      playlistMediaCurrentPage[key] = 1;
      playlistMediaHasError[key] = false;
    }
  }

  @action
  void setPlaylistMediaLoading(String key, bool loading) {
    initializePlaylistMediaKey(key);
    playlistMediaLoading[key] = loading;
  }

  @action
  void setPlaylistMediaLastPage(String key, bool isLastPage) {
    initializePlaylistMediaKey(key);
    playlistMediaLastPage[key] = isLastPage;
  }

  @action
  void setPlaylistMediaCurrentPage(String key, int page) {
    initializePlaylistMediaKey(key);
    playlistMediaCurrentPage[key] = page;
  }

  @action
  void setPlaylistMediaError(String key, bool hasError) {
    initializePlaylistMediaKey(key);
    playlistMediaHasError[key] = hasError;
  }

  @action
  void setPlaylistMediaData(String key, List<CommonDataListModel> data, {bool isRefresh = false}) {
    initializePlaylistMediaKey(key);
    if (isRefresh) {
      playlistMediaData[key]!.clear();
    }
    playlistMediaData[key]!.addAll(data);
  }

  @action
  void removePlaylistMediaItem(String key, CommonDataListModel item) {
    initializePlaylistMediaKey(key);
    playlistMediaData[key]!.remove(item);
  }

  @action
  void clearPlaylistMediaData(String key) {
    initializePlaylistMediaKey(key);
    playlistMediaData[key]!.clear();
    playlistMediaCurrentPage[key] = 1;
    playlistMediaLastPage[key] = false;
    playlistMediaHasError[key] = false;
  }

  @action
  void resetPlaylistMediaState(String key) {
    clearPlaylistMediaData(key);
    playlistMediaLoading[key] = false;
  }

  // Helper methods for playlist media
  ObservableList<CommonDataListModel> getPlaylistMediaByKey(String key) {
    initializePlaylistMediaKey(key);
    return playlistMediaData[key]!;
  }

  bool isPlaylistMediaLoading(String key) {
    return playlistMediaLoading[key] ?? false;
  }

  bool isPlaylistMediaLastPage(String key) {
    return playlistMediaLastPage[key] ?? false;
  }

  int getPlaylistMediaCurrentPage(String key) {
    return playlistMediaCurrentPage[key] ?? 1;
  }

  bool hasPlaylistMediaError(String key) {
    return playlistMediaHasError[key] ?? false;
  }

  bool isPlaylistMediaEmpty(String key) {
    final list = playlistMediaData[key];
    return list == null || list.isEmpty;
  }

  // Generate unique key for playlist media
  String getPlaylistMediaKey(int playlistId, String playlistType) {
    return '${playlistId}_$playlistType';
  }

  //endregion

  //region Playlist List Widget State

  @observable
  ObservableMap<String, Future<List<PlaylistModel>>> playlistListFutures = ObservableMap<String, Future<List<PlaylistModel>>>();

  @observable
  ObservableMap<String, List<PlaylistModel>> playlistListData = ObservableMap<String, List<PlaylistModel>>();

  @observable
  ObservableMap<String, bool> playlistListLoading = ObservableMap<String, bool>();

  @action
  void setPlaylistListLoading(String key, bool loading) {
    playlistListLoading[key] = loading;
  }

  @action
  Future<void> loadPlaylistForPost({required String playlistType, required int postId}) async {
    try {
      final key = '${playlistType}_$postId';
      setPlaylistListLoading(key, true);
      
      final future = api.getPlayListByType(type: playlistType, postId: postId);
      playlistListFutures[key] = future;
      
      final data = await future;
      playlistListData[key] = data;
      setPlaylistListLoading(key, false);
    } catch (e) {
      final key = '${playlistType}_$postId';
      setPlaylistListLoading(key, false);
      log('Error loading playlist for post: ${e.toString()}');
    }
  }

  @action
  Future<void> refreshPlaylistForPost({required String playlistType, required int postId}) async {
    await loadPlaylistForPost(playlistType: playlistType, postId: postId);
  }

  @action
  void updatePlaylistItemStatus(String key, int playlistId, bool isInPlaylist) {
    final list = playlistListData[key];
    if (list != null) {
      final index = list.indexWhere((item) => item.playlistId == playlistId);
      if (index != -1) {
        list[index].isInPlaylist = isInPlaylist;
      }
    }
  }

  // Helper methods for playlist list
  Future<List<PlaylistModel>>? getPlaylistListFutureForPost(String playlistType, int postId) {
    final key = '${playlistType}_$postId';
    return playlistListFutures[key];
  }

  List<PlaylistModel> getPlaylistListDataForPost(String playlistType, int postId) {
    final key = '${playlistType}_$postId';
    return playlistListData[key] ?? [];
  }

  bool isPlaylistListLoadingForPost(String playlistType, int postId) {
    final key = '${playlistType}_$postId';
    return playlistListLoading[key] ?? false;
  }

  //endregion

  //region Global Playlist Actions

  @action
  void clearAllPlaylistStates() {
    // Clear main playlist states
    playlistFutures.clear();
    playlistData.clear();
    
    // Clear playlist media states
    playlistMediaData.clear();
    playlistMediaLoading.clear();
    playlistMediaLastPage.clear();
    playlistMediaCurrentPage.clear();
    playlistMediaHasError.clear();
    
    // Clear playlist list states
    playlistListFutures.clear();
    playlistListData.clear();
    playlistListLoading.clear();
    
    // Reset selection
    selectedTabIndex = 0;
    selectedPlaylistType = playlistMovie;
    selectedPlaylistTypeModel = null;
    isLoading = false;
    isCreatingPlaylist = false;
  }

  //endregion
}