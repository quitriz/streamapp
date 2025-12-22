import 'package:mobx/mobx.dart';
import 'package:streamit_flutter/models/genre_data.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/utils/constants.dart';

part 'genre_store.g.dart';

class GenreStore = GenreStoreBase with _$GenreStore;

abstract class GenreStoreBase with Store {

//region Genre Fragment State

  @observable
  int genreSelectedTabIndex = 0;

  @observable
  bool genreIsTabAnimating = false;

  @observable
  String genreCurrentType = dashboardTypeMovie;

  @action
  void setGenreSelectedTabIndex(int index) {
    genreSelectedTabIndex = index;
    
    // Update the current type based on tab index
    switch (index) {
      case 0:
        genreCurrentType = dashboardTypeMovie;
        break;
      case 1:
        genreCurrentType = dashboardTypeTVShow;
        break;
      case 2:
        genreCurrentType = dashboardTypeVideo;
        break;
      default:
        genreCurrentType = dashboardTypeMovie;
    }
  }

  @action
  void setGenreTabAnimating(bool animating) {
    genreIsTabAnimating = animating;
  }

  @action
  void setGenreCurrentType(String type) {
    genreCurrentType = type;
  }

  @action
  void resetGenreState() {
    genreSelectedTabIndex = 0;
    genreIsTabAnimating = false;
    genreCurrentType = dashboardTypeMovie;
  }

  // Computed getter for current genre type
  @computed
  String get currentGenreType => genreCurrentType;

  // Helper method to get tab title by index
  String getGenreTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Movies'; // Will be replaced with language.movies in widget
      case 1:
        return 'TV Shows'; // Will be replaced with language.tVShows in widget
      case 2:
        return 'Videos'; // Will be replaced with language.videos in widget
      default:
        return 'Movies';
    }
  }

//endregion

//region Genre List State

  @observable
  ObservableMap<String, ObservableList<GenreData>> genreListData = ObservableMap<String, ObservableList<GenreData>>();

  @observable
  ObservableMap<String, bool> genreListLoading = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> genreListLastPage = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, int> genreListCurrentPage = ObservableMap<String, int>();

  @observable
  ObservableMap<String, bool> genreListHasError = ObservableMap<String, bool>();

  @action
  void initializeGenreListType(String type) {
    if (!genreListData.containsKey(type)) {
      genreListData[type] = ObservableList<GenreData>();
      genreListLoading[type] = false;
      genreListLastPage[type] = false;
      genreListCurrentPage[type] = 1;
      genreListHasError[type] = false;
    }
  }

  @action
  void setGenreListLoading(String type, bool loading) {
    initializeGenreListType(type);
    genreListLoading[type] = loading;
  }

  @action
  void setGenreListLastPage(String type, bool isLastPage) {
    initializeGenreListType(type);
    genreListLastPage[type] = isLastPage;
  }

  @action
  void setGenreListCurrentPage(String type, int page) {
    initializeGenreListType(type);
    genreListCurrentPage[type] = page;
  }

  @action
  void setGenreListError(String type, bool hasError) {
    initializeGenreListType(type);
    genreListHasError[type] = hasError;
  }

  @action
  void setGenreListData(String type, List<GenreData> data, {bool isRefresh = false}) {
    initializeGenreListType(type);
    if (isRefresh) {
      genreListData[type]!.clear();
    }
    genreListData[type]!.addAll(data);
  }

  @action
  void clearGenreListData(String type) {
    initializeGenreListType(type);
    genreListData[type]!.clear();
    genreListCurrentPage[type] = 1;
    genreListLastPage[type] = false;
    genreListHasError[type] = false;
  }

  @action
  void resetGenreListState(String type) {
    clearGenreListData(type);
    genreListLoading[type] = false;
  }

  @action
  void clearAllGenreListStates() {
    genreListData.clear();
    genreListLoading.clear();
    genreListLastPage.clear();
    genreListCurrentPage.clear();
    genreListHasError.clear();
  }

  // Helper methods for genre list
  ObservableList<GenreData> getGenreListByType(String type) {
    initializeGenreListType(type);
    return genreListData[type]!;
  }

  bool isGenreListLoading(String type) {
    return genreListLoading[type] ?? false;
  }

  bool isGenreListLastPage(String type) {
    return genreListLastPage[type] ?? false;
  }

  int getGenreListCurrentPage(String type) {
    return genreListCurrentPage[type] ?? 1;
  }

  bool hasGenreListError(String type) {
    return genreListHasError[type] ?? false;
  }

  bool isGenreListEmpty(String type) {
    final list = genreListData[type];
    return list == null || list.isEmpty;
  }

//endregion

//region Genre Movie List State

  @observable
  ObservableMap<String, ObservableList<CommonDataListModel>> genreMovieListData = ObservableMap<String, ObservableList<CommonDataListModel>>();

  @observable
  ObservableMap<String, bool> genreMovieListLoading = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> genreMovieListLoadMore = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> genreMovieListHasError = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, int> genreMovieListCurrentPage = ObservableMap<String, int>();

  @action
  void initializeGenreMovieListType(String key) {
    if (!genreMovieListData.containsKey(key)) {
      genreMovieListData[key] = ObservableList<CommonDataListModel>();
      genreMovieListLoading[key] = false;
      genreMovieListLoadMore[key] = true;
      genreMovieListHasError[key] = false;
      genreMovieListCurrentPage[key] = 1;
    }
  }

  @action
  void setGenreMovieListLoading(String key, bool loading) {
    initializeGenreMovieListType(key);
    genreMovieListLoading[key] = loading;
  }

  @action
  void setGenreMovieListLoadMore(String key, bool loadMore) {
    initializeGenreMovieListType(key);
    genreMovieListLoadMore[key] = loadMore;
  }

  @action
  void setGenreMovieListError(String key, bool hasError) {
    initializeGenreMovieListType(key);
    genreMovieListHasError[key] = hasError;
  }

  @action
  void setGenreMovieListCurrentPage(String key, int page) {
    initializeGenreMovieListType(key);
    genreMovieListCurrentPage[key] = page;
  }

  @action
  void setGenreMovieListData(String key, List<CommonDataListModel> data, {bool isRefresh = false}) {
    initializeGenreMovieListType(key);
    if (isRefresh) {
      genreMovieListData[key]!.clear();
    }
    genreMovieListData[key]!.addAll(data);
  }

  @action
  void clearGenreMovieListData(String key) {
    initializeGenreMovieListType(key);
    genreMovieListData[key]!.clear();
    genreMovieListCurrentPage[key] = 1;
    genreMovieListLoadMore[key] = true;
    genreMovieListHasError[key] = false;
  }

  @action
  void resetGenreMovieListState(String key) {
    clearGenreMovieListData(key);
    genreMovieListLoading[key] = false;
  }

  @action
  void clearAllGenreMovieListStates() {
    genreMovieListData.clear();
    genreMovieListLoading.clear();
    genreMovieListLoadMore.clear();
    genreMovieListHasError.clear();
    genreMovieListCurrentPage.clear();
  }

  // Helper methods for genre movie list
  ObservableList<CommonDataListModel> getGenreMovieListByKey(String key) {
    initializeGenreMovieListType(key);
    return genreMovieListData[key]!;
  }

  bool isGenreMovieListLoading(String key) {
    return genreMovieListLoading[key] ?? false;
  }

  bool canGenreMovieListLoadMore(String key) {
    return genreMovieListLoadMore[key] ?? true;
  }

  bool hasGenreMovieListError(String key) {
    return genreMovieListHasError[key] ?? false;
  }

  int getGenreMovieListCurrentPage(String key) {
    return genreMovieListCurrentPage[key] ?? 1;
  }

  bool isGenreMovieListEmpty(String key) {
    final list = genreMovieListData[key];
    return list == null || list.isEmpty;
  }

  // Generate unique key for genre movie list
  String getGenreMovieListKey(String slug, String type) {
    return '${slug}_$type';
  }

//endregion

//region Global Genre Actions

  @action
  void clearAllGenreStates() {
    // Clear fragment state
    resetGenreState();
    
    // Clear genre list states
    clearAllGenreListStates();
    
    // Clear genre movie list states
    clearAllGenreMovieListStates();
  }

//endregion
}
