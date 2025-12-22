import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';

part 'liked_content_store.g.dart';

class LikedContentStore = LikedContentStoreBase with _$LikedContentStore;

abstract class LikedContentStoreBase with Store {
  @observable
  int selectedTabIndex = 0;

  @observable
  ObservableMap<String, ObservableList<CommonDataListModel>> likedData = ObservableMap<String, ObservableList<CommonDataListModel>>();

  @observable
  ObservableMap<String, int> currentPage = ObservableMap<String, int>();

  @observable
  ObservableMap<String, bool> isLastPage = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> isLoading = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> hasError = ObservableMap<String, bool>();

  @observable
  int userId = 0;

  @action
  void setUserId(int id) {
    userId = id;
  }

  @action
  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
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
    if (!likedData.containsKey(postType)) {
      likedData[postType] = ObservableList<CommonDataListModel>();
      currentPage[postType] = 1;
      isLastPage[postType] = false;
      isLoading[postType] = false;
      hasError[postType] = false;
    }
  }

  @action
  Future<void> loadLikedContent(String postType, {bool isRefresh = false}) async {
    try {
      initializePostType(postType);

      if (isRefresh) {
        currentPage[postType] = 1;
        hasError[postType] = false;
      }

      setLoading(postType, true);

      final page = currentPage[postType] ?? 1;
      final data = await getLikedContent(postType: postType, page: page);

      setLastPage(postType, data.length != postPerPage);

      if (page == 1) {
        likedData[postType]!.clear();
      }

      likedData[postType]!.addAll(data);
      setLoading(postType, false);
    } catch (e) {
      setError(postType, true);
      setLoading(postType, false);
      log('Error loading liked content: ${e.toString()}');
      rethrow;
    }
  }

  @action
  Future<void> loadMoreLikedContent(String postType) async {
    if (isLastPage[postType] == true || isLoading[postType] == true) return;

    final nextPage = (currentPage[postType] ?? 1) + 1;
    setPage(postType, nextPage);
    await loadLikedContent(postType);
  }

  @action
  Future<void> refreshLikedContent(String postType) async {
    await loadLikedContent(postType, isRefresh: true);
  }

  @action
  Future<void> removeFromLikedContent(String postType, CommonDataListModel item) async {
    try {
      final actionPostType = _mapPostType(item.postType);
      Map request = {
        'post_id': item.id.validate(),
        'user_id': userId,
        'post_type': actionPostType,
        'action': 'dislike',
      };

      await likeMovie(request);

      likedData[postType]?.remove(item);
    } catch (e) {
      log('Error removing liked content: ${e.toString()}');
      rethrow;
    }
  }

  @action
  void clearLikedContent(String postType) {
    initializePostType(postType);
    likedData[postType]!.clear();
    currentPage[postType] = 1;
    isLastPage[postType] = false;
    hasError[postType] = false;
  }

  @action
  void clearAll() {
    likedData.clear();
    currentPage.clear();
    isLastPage.clear();
    isLoading.clear();
    hasError.clear();
  }

  ObservableList<CommonDataListModel> getLikedContentByType(String postType) {
    return likedData[postType] ?? ObservableList<CommonDataListModel>();
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

  String _mapPostType(PostType? postType) {
    switch (postType) {
      case PostType.MOVIE:
        return ReviewConst.reviewTypeMovie;
      case PostType.TV_SHOW:
        return ReviewConst.reviewTypeTvShow;
      case PostType.EPISODE:
        return ReviewConst.reviewTypeEpisode;
      case PostType.VIDEO:
        return ReviewConst.reviewTypeVideo;
      default:
        return ReviewConst.reviewTypeMovie;
    }
  }
}



