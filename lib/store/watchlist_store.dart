import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';

part 'watchlist_store.g.dart';

class WatchlistStore = WatchlistStoreBase with _$WatchlistStore;

abstract class WatchlistStoreBase with Store {
  // Tab selection
  @observable
  int selectedTabIndex = 0;

  // Data for different post types
  @observable
  ObservableMap<String, ObservableList<CommonDataListModel>> watchlistData = ObservableMap<String, ObservableList<CommonDataListModel>>();

  // Pagination
  @observable
  ObservableMap<String, int> currentPage = ObservableMap<String, int>();

  @observable
  ObservableMap<String, bool> isLastPage = ObservableMap<String, bool>();

  // Loading states
  @observable
  ObservableMap<String, bool> isLoading = ObservableMap<String, bool>();

  // Error states
  @observable
  ObservableMap<String, bool> hasError = ObservableMap<String, bool>();

  // User data
  @observable
  int userId = 0;

  // Actions
  @action
  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
  }

  @action
  void setUserId(int id) {
    userId = id;
  }

  @action
  void setLoading(String postType, bool loading) {
    isLoading[postType] = loading;
  }

  @action
  void setError(String postType, bool error) {
    hasError[postType] = error;
  }

  @action
  void setPage(String postType, int page) {
    currentPage[postType] = page;
  }

  @action
  void setLastPage(String postType, bool isLast) {
    isLastPage[postType] = isLast;
  }

  @action
  void initializePostType(String postType) {
    if (!watchlistData.containsKey(postType)) {
      watchlistData[postType] = ObservableList<CommonDataListModel>();
      currentPage[postType] = 1;
      isLastPage[postType] = false;
      isLoading[postType] = false;
      hasError[postType] = false;
    }
  }

  @action
  Future<void> loadWatchlist(String postType, {bool isRefresh = false}) async {
    try {
      initializePostType(postType);
      
      if (isRefresh) {
        currentPage[postType] = 1;
        hasError[postType] = false;
      }

      setLoading(postType, true);
      
      final page = currentPage[postType] ?? 1;
      final data = await getWatchList(page: page, postType: postType);
      
      setLastPage(postType, data.length != postPerPage);
      
      if (page == 1) {
        watchlistData[postType]!.clear();
      }
      
      watchlistData[postType]!.addAll(data);
      setLoading(postType, false);
      
    } catch (e) {
      setError(postType, true);
      setLoading(postType, false);
      log('Error loading watchlist: ${e.toString()}');
      rethrow;
    }
  }

  @action
  Future<void> loadMoreWatchlist(String postType) async {
    if (isLastPage[postType] == true || isLoading[postType] == true) return;
    
    final nextPage = (currentPage[postType] ?? 1) + 1;
    setPage(postType, nextPage);
    await loadWatchlist(postType);
  }

  @action
  Future<void> refreshWatchlist(String postType) async {
    await loadWatchlist(postType, isRefresh: true);
  }

  @action
  Future<void> removeFromWatchlist(String postType, CommonDataListModel item) async {
    try {
      Map req = {'post_id': item.id.validate(), 'user_id': userId};
      
      await watchlistMovie(req);
      
      // Remove item from local list
      watchlistData[postType]?.remove(item);
      
    } catch (e) {
      log('Error removing from watchlist: ${e.toString()}');
      rethrow;
    }
  }

  @action
  void clearWatchlist(String postType) {
    initializePostType(postType);
    watchlistData[postType]!.clear();
    currentPage[postType] = 1;
    isLastPage[postType] = false;
    hasError[postType] = false;
  }

  @action
  void clearAllWatchLists() {
    watchlistData.clear();
    currentPage.clear();
    isLastPage.clear();
    isLoading.clear();
    hasError.clear();
  }

  // Helper methods
  ObservableList<CommonDataListModel> getWatchlistByType(String postType) {
    return watchlistData[postType] ?? ObservableList<CommonDataListModel>();
  }

  bool isLoadingByType(String postType) {
    return isLoading[postType] ?? false;
  }

  bool hasErrorByType(String postType) {
    return hasError[postType] ?? false;
  }

  bool isLastPageByType(String postType) {
    return isLastPage[postType] ?? false;
  }

  int getCurrentPage(String postType) {
    return currentPage[postType] ?? 1;
  }

  bool isEmpty(String postType) {
    final list = watchlistData[postType];
    return list == null || list.isEmpty;
  }

  String getEmptyTitle(String postType) {
    return 'Your watchlist is empty';
  }
}
