import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/dashboard_response.dart' as Model;
import 'package:streamit_flutter/models/live_tv/live_category_list_model.dart' as LiveModel;
import 'package:streamit_flutter/models/live_tv/live_channel_detail_model.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_common_models.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_response.dart';
import 'package:streamit_flutter/models/notification_model.dart';
import 'package:streamit_flutter/models/notification_reminder_list_model.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/models/settings/devices_model.dart';
import 'package:streamit_flutter/models/view_all_response.dart' as ViewAllModel;
import 'package:streamit_flutter/utils/constants.dart';

part 'fragment_store.g.dart';

class FragmentStore = FragmentStoreBase with _$FragmentStore;

abstract class FragmentStoreBase with Store {
  // User Info
  @observable
  String userName = "";

  @observable
  String userEmail = "";

  @observable
  int notification = 0;

  // Loading States
  @observable
  bool isLoaderShow = true;

  @observable
  bool isMembershipLoading = false;

  @action
  void setMembershipLoading(bool val) => isMembershipLoading = val;

  @observable
  bool isContinueWatchLoading = true;

  @observable
  bool isWatchListLoading = true;

  @observable
  bool isLikedContentLoading = true;

  @observable
  bool isDownloadsLoading = true;

  @observable
  bool isReminderListLoading = true;

  // Pagination
  @observable
  bool mIsLastPage = false;

  @observable
  int mPage = 1;

  // Data Lists
  @observable
  ObservableList<CommonDataListModel> continueWatch = ObservableList<CommonDataListModel>();

  @observable
  ObservableList<CommonDataListModel> watchList = ObservableList<CommonDataListModel>();

  @observable
  ObservableList<CommonDataListModel> randomWatchList = ObservableList<CommonDataListModel>();

  @observable
  ObservableList<CommonDataListModel> likedContentList = ObservableList<CommonDataListModel>();

  @observable
  ObservableList<ReminderList> reminderList = ObservableList<ReminderList>();

  // Membership
  @observable
  MembershipModel? membership;

  @observable
  bool hasMembership = false;

  // Dashboard futures keyed by type (e.g., home/movie/tv/video)
  @observable
  ObservableMap<String, Future<Model.DashboardResponse>> dashboardFutures = ObservableMap.of({});
  @observable
  Future<LiveModel.AllLiveCategoryList>? liveCategoryFuture;

  // Actions
  @action
  void setUserName(String value) {
    userName = value;
  }

  @action
  void setUserEmail(String value) {
    userEmail = value;
  }

  @action
  void setNotification(int value) {
    notification = value;
  }

  @action
  void setLoaderShow(bool value) {
    isLoaderShow = value;
  }

  @action
  void setContinueWatchLoading(bool value) {
    isContinueWatchLoading = value;
  }

  @action
  void setWatchListLoading(bool value) {
    isWatchListLoading = value;
  }

  @action
  void setLikedContentLoading(bool value) {
    isLikedContentLoading = value;
  }

  @action
  void setDownloadsLoading(bool value) {
    isDownloadsLoading = value;
  }

  @action
  void setReminderListLoading(bool value) {
    isReminderListLoading = value;
  }

  @action
  void setLastPage(bool value) {
    mIsLastPage = value;
  }

  @action
  void setPage(int value) {
    mPage = value;
  }

  @action
  void setContinueWatch(List<CommonDataListModel> list) {
    continueWatch.clear();
    continueWatch.addAll(list);
  }

  @action
  void setWatchList(List<CommonDataListModel> list) {
    watchList.clear();
    watchList.addAll(list);
  }

  @action
  void setRandomWatchList(List<CommonDataListModel> list) {
    randomWatchList.clear();
    randomWatchList.addAll(list);
  }

  @action
  void setLikedContentList(List<CommonDataListModel> list) {
    likedContentList
      ..clear()
      ..addAll(list);
  }

  @action
  void setReminderList(List<ReminderList> list) {
    reminderList.clear();
    reminderList.addAll(list);
  }

  @action
  void setMembership(MembershipModel? value) {
    membership = value;
  }

  @action
  void setHasMembership(bool value) {
    hasMembership = value;
  }

  @action
  void clearContinueWatch() {
    continueWatch.clear();
  }

  @action
  void removeFromContinueWatch(CommonDataListModel data) {
    continueWatch.remove(data);
  }

  @action
  void clearWatchList() {
    watchList.clear();
  }

  @action
  void clearRandomWatchList() {
    randomWatchList.clear();
  }

  @action
  void clearLikedContentList() {
    likedContentList.clear();
  }

  @action
  void clearReminderList() {
    reminderList.clear();
  }

  @action
  void resetLoadingStates() {
    isContinueWatchLoading = true;
    isWatchListLoading = true;
    isDownloadsLoading = true;
    isReminderListLoading = true;
  }  

  // Dashboard future setters/getters
  @action
  void setDashboardFuture(String key, Future<Model.DashboardResponse> future) {
    dashboardFutures[key] = future;
  }

  Future<Model.DashboardResponse>? getDashboardFuture(String key) {
    return dashboardFutures[key];
  }

//region HomeFragment
  @observable
  int homeTabIndex = 0;

  @action
  void setHomeTabIndex(int value) {
    homeTabIndex = value;
  }
//endregion HomeFragment

//region SearchFragment
  @observable
  ObservableList<CommonDataListModel> searchMovies = ObservableList<CommonDataListModel>();

  @observable
  ObservableList<RecentSearchListModel> recentSearches = ObservableList<RecentSearchListModel>();

  @observable
  int searchPage = 1;

  @observable
  bool isSearchLastPage = false;

  @observable
  String searchQuery = '';

  @observable
  Future<List<CommonDataListModel>>? searchFuture;

  @observable
  Future<List<RecentSearchListModel>>? recentFuture;

  @action
  void setSearchQuery(String value) {
    searchQuery = value;
  }

  @action
  void setSearchPage(int value) {
    searchPage = value;
  }

  @action
  void setIsSearchLastPage(bool value) {
    isSearchLastPage = value;
  }

  @action
  void setSearchMovies(List<CommonDataListModel> list, {bool isRefresh = false}) {
    if (isRefresh) searchMovies.clear();
    searchMovies.addAll(list);
  }

  @action
  void clearSearchMovies() {
    searchMovies.clear();
  }

  @action
  void setRecentSearches(List<RecentSearchListModel> list, {bool isRefresh = false}) {
    if (isRefresh) recentSearches.clear();
    recentSearches
      ..clear()
      ..addAll(list);
  }

  @action
  void removeRecentById(int id) {
    recentSearches.removeWhere((e) => e.id == id);
  }

  @action
  void setSearchFuture(Future<List<CommonDataListModel>>? future) {
    searchFuture = future;
  }

  @action
  void setRecentFuture(Future<List<RecentSearchListModel>>? future) {
    recentFuture = future;
  }
//endregion SearchFragment

//region LiveFragment

  @observable
  bool isLiveEnabled = false;

  @action
  Future<void> setEnableLiveStreaming(bool liveStreaming) async {
    isLiveEnabled = liveStreaming;
    await setValue(IS_LIVE_STREAMING_ENABLED, liveStreaming);
  }

  @observable
  LiveChannelDetails? liveChannelDetails;

  @observable
  ObservableList<CommonDataListModel> liveChannels = ObservableList<CommonDataListModel>();

  @observable
  int liveChannelsPage = 1;

  @observable
  bool liveChannelsIsLastPage = false;

  @observable
  Future<ViewAllModel.ViewAllResponse>? liveChannelsFuture;

  @action
  void setLiveChannelsPage(int value) => liveChannelsPage = value;

  @action
  void setLiveChannelsIsLastPage(bool value) => liveChannelsIsLastPage = value;

  @action
  void setLiveChannelsFuture(Future<ViewAllModel.ViewAllResponse>? future) => liveChannelsFuture = future;

  @action
  void setLiveChannels(List<CommonDataListModel> list, {bool isRefresh = false}) {
    if (isRefresh) liveChannels.clear();
    liveChannels.addAll(list);
  }

  // Recommended Channels (View All)
  @observable
  bool isRecommendedLoading = true;

  @observable
  ObservableList<RecommendedChannel> recommendedChannels = ObservableList<RecommendedChannel>();

  @action
  void setRecommendedChannels(List<RecommendedChannel> list, {bool isRefresh = true}) {
    if (isRefresh) recommendedChannels.clear();
    recommendedChannels.addAll(list);
  }

  @action
  void setRecommendedLoading(bool val) => isRecommendedLoading = val;

//endregion

//region Notification Management

  @observable
  ObservableList<NotificationModel> notificationList = ObservableList<NotificationModel>();

  @observable
  int notificationPage = 1;

  @observable
  bool notificationIsLastPage = false;

  @observable
  bool notificationIsLoading = false;

  @observable
  bool notificationHasError = false;

  @observable
  String? notificationError;

  @action
  void setNotificationPage(int page) => notificationPage = page;

  @action
  void setNotificationIsLastPage(bool isLastPage) => notificationIsLastPage = isLastPage;

  @action
  void setNotificationIsLoading(bool loading) => notificationIsLoading = loading;

  @action
  void setNotificationHasError(bool hasError) => notificationHasError = hasError;

  @action
  void setNotificationError(String? error) => notificationError = error;

  @action
  void setNotificationList(List<NotificationModel> list, {bool isRefresh = false}) {
    if (isRefresh) notificationList.clear();
    notificationList.addAll(list);
  }

  @action
  void clearNotificationList() => notificationList.clear();

  @action
  void resetNotificationState() {
    notificationPage = 1;
    notificationIsLastPage = false;
    notificationIsLoading = false;
    notificationHasError = false;
    notificationError = null;
    notificationList.clear();
  }

  @action
  void incrementNotificationPage() {
    if (!notificationIsLastPage) {
      setNotificationPage(notificationPage + 1);
    }
  }

  // Computed properties for notifications
  @computed
  bool get canLoadMoreNotifications => !notificationIsLastPage && !notificationIsLoading;

  @computed
  bool get hasNotificationData => notificationList.isNotEmpty;

  @computed
  bool get hasNotificationError => notificationHasError;

  @computed
  String? get notificationErrorMessage => notificationError;

  @computed
  int get notificationDataCount => notificationList.length;

//endregion

//region Movie Detail State Management

  @observable
  MovieData? currentMovie;

  @observable
  MovieDetailResponse? movieResponse;

  @observable
  int selectedIndex = 0;

  @observable
  int currentIndex = 0;

  @observable
  String genre = '';

  @observable
  String restrictedPlans = '';

  @observable
  String? selectedSourceUrl;

  @observable
  String? selectedSourceChoice;

  @observable
  String? selectedEmbedContent;

  @observable
  PostType? postType;

  @observable
  bool isError = false;

  @observable
  bool hasData = false;

  @observable
  bool isSharing = false;

  @observable
  bool isDownloading = false;

  // TV Show specific observables
  @observable
  MovieData? showDetails;

  @observable
  MovieData? selectedEpisode;

  @observable
  ObservableList<MovieData> allEpisodes = ObservableList<MovieData>();

  @observable
  int? selectedEpisodeIndex;

  @observable
  int? selectedSeasonNumber;

  @action
  void setCurrentMovie(MovieData? movie) => currentMovie = movie;

  @action
  void setMovieResponse(MovieDetailResponse? response) => movieResponse = response;

  @action
  void setSelectedIndex(int index) => selectedIndex = index;

  @action
  void setCurrentIndex(int index) => currentIndex = index;

  @action
  void setGenre(String genre) => this.genre = genre;

  @action
  void setRestrictedPlans(String plans) => restrictedPlans = plans;

  @action
  void setSelectedSourceUrl(String? url) => selectedSourceUrl = url;

  @action
  void setSelectedSourceChoice(String? choice) => selectedSourceChoice = choice;

  @action
  void setSelectedEmbedContent(String? content) => selectedEmbedContent = content;

  @action
  void setPostType(PostType? type) => postType = type;

  @action
  void setMovieDetailError(bool error) => isError = error;

  @action
  void setHasData(bool hasData) => this.hasData = hasData;

  @action
  void setIsSharing(bool sharing) => isSharing = sharing;

  @action
  void setIsDownloading(bool downloading) => isDownloading = downloading;

  @action
  void resetMovieDetailState() {
    currentMovie = null;
    movieResponse = null;
    selectedIndex = 0;
    currentIndex = 0;
    genre = '';
    restrictedPlans = '';
    selectedSourceUrl = null;
    selectedSourceChoice = null;
    selectedEmbedContent = null;
    postType = null;
    isError = false;
    hasData = false;
    isSharing = false;
    isDownloading = false;
  }

  // TV Show specific actions
  @action
  void setShowDetails(MovieData? show) => showDetails = show;

  @action
  void setSelectedEpisode(MovieData? episode) => selectedEpisode = episode;

  @action
  void setAllEpisodes(List<MovieData> episodes) {
    allEpisodes.clear();
    allEpisodes.addAll(episodes);
  }

  @action
  void setSelectedEpisodeIndex(int? index) => selectedEpisodeIndex = index;

  @action
  void setSelectedSeasonNumber(int? seasonNumber) => selectedSeasonNumber = seasonNumber;

  // Season and Episode management observables
  @observable
  CommonDataDetailsModel? selectedSeason;

  @observable
  ObservableList<MovieData> visibleEpisodes = ObservableList<MovieData>();

  @observable
  bool isSeasonLoading = false;

  @observable
  bool isSeasonExpanded = false;

  @observable
  Map<int, bool> episodeExpandedStates = {};

  /// Tracks reminder state for each episode. Using ObservableMap so widgets can react without codegen.
  final ObservableMap<int, bool> episodeReminderStates = ObservableMap<int, bool>();

  @action
  void setSelectedSeason(CommonDataDetailsModel? season) => selectedSeason = season;

  @action
  void setVisibleEpisodes(List<MovieData> episodes) {
    visibleEpisodes.clear();
    visibleEpisodes.addAll(episodes);
  }

  @action
  void addVisibleEpisode(MovieData episode) => visibleEpisodes.add(episode);

  @action
  void setSeasonLoading(bool loading) => isSeasonLoading = loading;

  @action
  void setSeasonExpanded(bool expanded) => isSeasonExpanded = expanded;

  @action
  void setEpisodeExpanded(int episodeId, bool expanded) => episodeExpandedStates[episodeId] = expanded;

  bool getEpisodeReminderState(int episodeId, {bool fallback = false}) {
    if (episodeReminderStates.containsKey(episodeId)) {
      return episodeReminderStates[episodeId]!;
    }
    return fallback;
  }

  void setEpisodeReminderState(int episodeId, bool isRemind) {
    episodeReminderStates[episodeId] = isRemind;
  }

  void removeEpisodeReminderState(int episodeId) {
    episodeReminderStates.remove(episodeId);
  }

  void clearEpisodeReminderStates() {
    episodeReminderStates.clear();
  }

  @action
  void resetTvShowState() {
    showDetails = null;
    selectedEpisode = null;
    allEpisodes.clear();
    visibleEpisodes.clear();
    selectedEpisodeIndex = null;
    selectedSeasonNumber = null;
    // Use setter to ensure proper type handling
    setSelectedSeason(null);
    isSeasonLoading = false;
    isSeasonExpanded = false;
    episodeExpandedStates.clear();
    clearEpisodeReminderStates();
  }

  // Device Management observables
  @observable
  ObservableList<DeviceData> deviceList = ObservableList<DeviceData>();

  @observable
  Stats? deviceStats;

  @observable
  String? deviceUserLevel;

  @observable
  bool deviceHasError = false;

  // Device Management actions
  @action
  void setDeviceList(List<DeviceData> devices) {
    deviceList.clear();
    deviceList.addAll(devices);
  }

  @action
  void setDeviceStats(Stats? stats) => deviceStats = stats;

  @action
  void setDeviceUserLevel(String? userLevel) => deviceUserLevel = userLevel;

  @action
  void setDeviceError(bool hasError) => deviceHasError = hasError;

  @action
  void removeDeviceFromList(String deviceId) {
    deviceList.removeWhere((device) => device.deviceId == deviceId);
  }

  @action
  void resetDeviceState() {
    deviceList.clear();
    deviceStats = null;
    deviceUserLevel = null;
    deviceHasError = false;
  }

  // Computed properties for movie detail
  @computed
  bool get hasMovieData => hasData && currentMovie != null;

  @computed
  bool get hasMovieError => isError;

  @computed
  bool get isMovieSharing => isSharing;

  @computed
  bool get isMovieDownloading => isDownloading;

//endregion
}
