// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fragment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FragmentStore on FragmentStoreBase, Store {
  Computed<bool>? _$canLoadMoreNotificationsComputed;

  @override
  bool get canLoadMoreNotifications => (_$canLoadMoreNotificationsComputed ??=
          Computed<bool>(() => super.canLoadMoreNotifications,
              name: 'FragmentStoreBase.canLoadMoreNotifications'))
      .value;
  Computed<bool>? _$hasNotificationDataComputed;

  @override
  bool get hasNotificationData => (_$hasNotificationDataComputed ??=
          Computed<bool>(() => super.hasNotificationData,
              name: 'FragmentStoreBase.hasNotificationData'))
      .value;
  Computed<bool>? _$hasNotificationErrorComputed;

  @override
  bool get hasNotificationError => (_$hasNotificationErrorComputed ??=
          Computed<bool>(() => super.hasNotificationError,
              name: 'FragmentStoreBase.hasNotificationError'))
      .value;
  Computed<String?>? _$notificationErrorMessageComputed;

  @override
  String? get notificationErrorMessage =>
      (_$notificationErrorMessageComputed ??= Computed<String?>(
              () => super.notificationErrorMessage,
              name: 'FragmentStoreBase.notificationErrorMessage'))
          .value;
  Computed<int>? _$notificationDataCountComputed;

  @override
  int get notificationDataCount => (_$notificationDataCountComputed ??=
          Computed<int>(() => super.notificationDataCount,
              name: 'FragmentStoreBase.notificationDataCount'))
      .value;
  Computed<bool>? _$hasMovieDataComputed;

  @override
  bool get hasMovieData =>
      (_$hasMovieDataComputed ??= Computed<bool>(() => super.hasMovieData,
              name: 'FragmentStoreBase.hasMovieData'))
          .value;
  Computed<bool>? _$hasMovieErrorComputed;

  @override
  bool get hasMovieError =>
      (_$hasMovieErrorComputed ??= Computed<bool>(() => super.hasMovieError,
              name: 'FragmentStoreBase.hasMovieError'))
          .value;
  Computed<bool>? _$isMovieSharingComputed;

  @override
  bool get isMovieSharing =>
      (_$isMovieSharingComputed ??= Computed<bool>(() => super.isMovieSharing,
              name: 'FragmentStoreBase.isMovieSharing'))
          .value;
  Computed<bool>? _$isMovieDownloadingComputed;

  @override
  bool get isMovieDownloading => (_$isMovieDownloadingComputed ??=
          Computed<bool>(() => super.isMovieDownloading,
              name: 'FragmentStoreBase.isMovieDownloading'))
      .value;

  late final _$userNameAtom =
      Atom(name: 'FragmentStoreBase.userName', context: context);

  @override
  String get userName {
    _$userNameAtom.reportRead();
    return super.userName;
  }

  @override
  set userName(String value) {
    _$userNameAtom.reportWrite(value, super.userName, () {
      super.userName = value;
    });
  }

  late final _$userEmailAtom =
      Atom(name: 'FragmentStoreBase.userEmail', context: context);

  @override
  String get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  late final _$notificationAtom =
      Atom(name: 'FragmentStoreBase.notification', context: context);

  @override
  int get notification {
    _$notificationAtom.reportRead();
    return super.notification;
  }

  @override
  set notification(int value) {
    _$notificationAtom.reportWrite(value, super.notification, () {
      super.notification = value;
    });
  }

  late final _$isLoaderShowAtom =
      Atom(name: 'FragmentStoreBase.isLoaderShow', context: context);

  @override
  bool get isLoaderShow {
    _$isLoaderShowAtom.reportRead();
    return super.isLoaderShow;
  }

  @override
  set isLoaderShow(bool value) {
    _$isLoaderShowAtom.reportWrite(value, super.isLoaderShow, () {
      super.isLoaderShow = value;
    });
  }

  late final _$isMembershipLoadingAtom =
      Atom(name: 'FragmentStoreBase.isMembershipLoading', context: context);

  @override
  bool get isMembershipLoading {
    _$isMembershipLoadingAtom.reportRead();
    return super.isMembershipLoading;
  }

  @override
  set isMembershipLoading(bool value) {
    _$isMembershipLoadingAtom.reportWrite(value, super.isMembershipLoading, () {
      super.isMembershipLoading = value;
    });
  }

  late final _$isContinueWatchLoadingAtom =
      Atom(name: 'FragmentStoreBase.isContinueWatchLoading', context: context);

  @override
  bool get isContinueWatchLoading {
    _$isContinueWatchLoadingAtom.reportRead();
    return super.isContinueWatchLoading;
  }

  @override
  set isContinueWatchLoading(bool value) {
    _$isContinueWatchLoadingAtom
        .reportWrite(value, super.isContinueWatchLoading, () {
      super.isContinueWatchLoading = value;
    });
  }

  late final _$isWatchListLoadingAtom =
      Atom(name: 'FragmentStoreBase.isWatchListLoading', context: context);

  @override
  bool get isWatchListLoading {
    _$isWatchListLoadingAtom.reportRead();
    return super.isWatchListLoading;
  }

  @override
  set isWatchListLoading(bool value) {
    _$isWatchListLoadingAtom.reportWrite(value, super.isWatchListLoading, () {
      super.isWatchListLoading = value;
    });
  }

  late final _$isLikedContentLoadingAtom =
      Atom(name: 'FragmentStoreBase.isLikedContentLoading', context: context);

  @override
  bool get isLikedContentLoading {
    _$isLikedContentLoadingAtom.reportRead();
    return super.isLikedContentLoading;
  }

  @override
  set isLikedContentLoading(bool value) {
    _$isLikedContentLoadingAtom.reportWrite(value, super.isLikedContentLoading,
        () {
      super.isLikedContentLoading = value;
    });
  }

  late final _$isDownloadsLoadingAtom =
      Atom(name: 'FragmentStoreBase.isDownloadsLoading', context: context);

  @override
  bool get isDownloadsLoading {
    _$isDownloadsLoadingAtom.reportRead();
    return super.isDownloadsLoading;
  }

  @override
  set isDownloadsLoading(bool value) {
    _$isDownloadsLoadingAtom.reportWrite(value, super.isDownloadsLoading, () {
      super.isDownloadsLoading = value;
    });
  }

  late final _$isReminderListLoadingAtom =
      Atom(name: 'FragmentStoreBase.isReminderListLoading', context: context);

  @override
  bool get isReminderListLoading {
    _$isReminderListLoadingAtom.reportRead();
    return super.isReminderListLoading;
  }

  @override
  set isReminderListLoading(bool value) {
    _$isReminderListLoadingAtom.reportWrite(value, super.isReminderListLoading,
        () {
      super.isReminderListLoading = value;
    });
  }

  late final _$mIsLastPageAtom =
      Atom(name: 'FragmentStoreBase.mIsLastPage', context: context);

  @override
  bool get mIsLastPage {
    _$mIsLastPageAtom.reportRead();
    return super.mIsLastPage;
  }

  @override
  set mIsLastPage(bool value) {
    _$mIsLastPageAtom.reportWrite(value, super.mIsLastPage, () {
      super.mIsLastPage = value;
    });
  }

  late final _$mPageAtom =
      Atom(name: 'FragmentStoreBase.mPage', context: context);

  @override
  int get mPage {
    _$mPageAtom.reportRead();
    return super.mPage;
  }

  @override
  set mPage(int value) {
    _$mPageAtom.reportWrite(value, super.mPage, () {
      super.mPage = value;
    });
  }

  late final _$continueWatchAtom =
      Atom(name: 'FragmentStoreBase.continueWatch', context: context);

  @override
  ObservableList<CommonDataListModel> get continueWatch {
    _$continueWatchAtom.reportRead();
    return super.continueWatch;
  }

  @override
  set continueWatch(ObservableList<CommonDataListModel> value) {
    _$continueWatchAtom.reportWrite(value, super.continueWatch, () {
      super.continueWatch = value;
    });
  }

  late final _$watchListAtom =
      Atom(name: 'FragmentStoreBase.watchList', context: context);

  @override
  ObservableList<CommonDataListModel> get watchList {
    _$watchListAtom.reportRead();
    return super.watchList;
  }

  @override
  set watchList(ObservableList<CommonDataListModel> value) {
    _$watchListAtom.reportWrite(value, super.watchList, () {
      super.watchList = value;
    });
  }

  late final _$randomWatchListAtom =
      Atom(name: 'FragmentStoreBase.randomWatchList', context: context);

  @override
  ObservableList<CommonDataListModel> get randomWatchList {
    _$randomWatchListAtom.reportRead();
    return super.randomWatchList;
  }

  @override
  set randomWatchList(ObservableList<CommonDataListModel> value) {
    _$randomWatchListAtom.reportWrite(value, super.randomWatchList, () {
      super.randomWatchList = value;
    });
  }

  late final _$likedContentListAtom =
      Atom(name: 'FragmentStoreBase.likedContentList', context: context);

  @override
  ObservableList<CommonDataListModel> get likedContentList {
    _$likedContentListAtom.reportRead();
    return super.likedContentList;
  }

  @override
  set likedContentList(ObservableList<CommonDataListModel> value) {
    _$likedContentListAtom.reportWrite(value, super.likedContentList, () {
      super.likedContentList = value;
    });
  }

  late final _$reminderListAtom =
      Atom(name: 'FragmentStoreBase.reminderList', context: context);

  @override
  ObservableList<ReminderList> get reminderList {
    _$reminderListAtom.reportRead();
    return super.reminderList;
  }

  @override
  set reminderList(ObservableList<ReminderList> value) {
    _$reminderListAtom.reportWrite(value, super.reminderList, () {
      super.reminderList = value;
    });
  }

  late final _$membershipAtom =
      Atom(name: 'FragmentStoreBase.membership', context: context);

  @override
  MembershipModel? get membership {
    _$membershipAtom.reportRead();
    return super.membership;
  }

  @override
  set membership(MembershipModel? value) {
    _$membershipAtom.reportWrite(value, super.membership, () {
      super.membership = value;
    });
  }

  late final _$hasMembershipAtom =
      Atom(name: 'FragmentStoreBase.hasMembership', context: context);

  @override
  bool get hasMembership {
    _$hasMembershipAtom.reportRead();
    return super.hasMembership;
  }

  @override
  set hasMembership(bool value) {
    _$hasMembershipAtom.reportWrite(value, super.hasMembership, () {
      super.hasMembership = value;
    });
  }

  late final _$dashboardFuturesAtom =
      Atom(name: 'FragmentStoreBase.dashboardFutures', context: context);

  @override
  ObservableMap<String, Future<Model.DashboardResponse>> get dashboardFutures {
    _$dashboardFuturesAtom.reportRead();
    return super.dashboardFutures;
  }

  @override
  set dashboardFutures(
      ObservableMap<String, Future<Model.DashboardResponse>> value) {
    _$dashboardFuturesAtom.reportWrite(value, super.dashboardFutures, () {
      super.dashboardFutures = value;
    });
  }

  late final _$liveCategoryFutureAtom =
      Atom(name: 'FragmentStoreBase.liveCategoryFuture', context: context);

  @override
  Future<LiveModel.AllLiveCategoryList>? get liveCategoryFuture {
    _$liveCategoryFutureAtom.reportRead();
    return super.liveCategoryFuture;
  }

  @override
  set liveCategoryFuture(Future<LiveModel.AllLiveCategoryList>? value) {
    _$liveCategoryFutureAtom.reportWrite(value, super.liveCategoryFuture, () {
      super.liveCategoryFuture = value;
    });
  }

  late final _$homeTabIndexAtom =
      Atom(name: 'FragmentStoreBase.homeTabIndex', context: context);

  @override
  int get homeTabIndex {
    _$homeTabIndexAtom.reportRead();
    return super.homeTabIndex;
  }

  @override
  set homeTabIndex(int value) {
    _$homeTabIndexAtom.reportWrite(value, super.homeTabIndex, () {
      super.homeTabIndex = value;
    });
  }

  late final _$searchMoviesAtom =
      Atom(name: 'FragmentStoreBase.searchMovies', context: context);

  @override
  ObservableList<CommonDataListModel> get searchMovies {
    _$searchMoviesAtom.reportRead();
    return super.searchMovies;
  }

  @override
  set searchMovies(ObservableList<CommonDataListModel> value) {
    _$searchMoviesAtom.reportWrite(value, super.searchMovies, () {
      super.searchMovies = value;
    });
  }

  late final _$recentSearchesAtom =
      Atom(name: 'FragmentStoreBase.recentSearches', context: context);

  @override
  ObservableList<RecentSearchListModel> get recentSearches {
    _$recentSearchesAtom.reportRead();
    return super.recentSearches;
  }

  @override
  set recentSearches(ObservableList<RecentSearchListModel> value) {
    _$recentSearchesAtom.reportWrite(value, super.recentSearches, () {
      super.recentSearches = value;
    });
  }

  late final _$searchPageAtom =
      Atom(name: 'FragmentStoreBase.searchPage', context: context);

  @override
  int get searchPage {
    _$searchPageAtom.reportRead();
    return super.searchPage;
  }

  @override
  set searchPage(int value) {
    _$searchPageAtom.reportWrite(value, super.searchPage, () {
      super.searchPage = value;
    });
  }

  late final _$isSearchLastPageAtom =
      Atom(name: 'FragmentStoreBase.isSearchLastPage', context: context);

  @override
  bool get isSearchLastPage {
    _$isSearchLastPageAtom.reportRead();
    return super.isSearchLastPage;
  }

  @override
  set isSearchLastPage(bool value) {
    _$isSearchLastPageAtom.reportWrite(value, super.isSearchLastPage, () {
      super.isSearchLastPage = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: 'FragmentStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$searchFutureAtom =
      Atom(name: 'FragmentStoreBase.searchFuture', context: context);

  @override
  Future<List<CommonDataListModel>>? get searchFuture {
    _$searchFutureAtom.reportRead();
    return super.searchFuture;
  }

  @override
  set searchFuture(Future<List<CommonDataListModel>>? value) {
    _$searchFutureAtom.reportWrite(value, super.searchFuture, () {
      super.searchFuture = value;
    });
  }

  late final _$recentFutureAtom =
      Atom(name: 'FragmentStoreBase.recentFuture', context: context);

  @override
  Future<List<RecentSearchListModel>>? get recentFuture {
    _$recentFutureAtom.reportRead();
    return super.recentFuture;
  }

  @override
  set recentFuture(Future<List<RecentSearchListModel>>? value) {
    _$recentFutureAtom.reportWrite(value, super.recentFuture, () {
      super.recentFuture = value;
    });
  }

  late final _$isLiveEnabledAtom =
      Atom(name: 'FragmentStoreBase.isLiveEnabled', context: context);

  @override
  bool get isLiveEnabled {
    _$isLiveEnabledAtom.reportRead();
    return super.isLiveEnabled;
  }

  @override
  set isLiveEnabled(bool value) {
    _$isLiveEnabledAtom.reportWrite(value, super.isLiveEnabled, () {
      super.isLiveEnabled = value;
    });
  }

  late final _$liveChannelDetailsAtom =
      Atom(name: 'FragmentStoreBase.liveChannelDetails', context: context);

  @override
  LiveChannelDetails? get liveChannelDetails {
    _$liveChannelDetailsAtom.reportRead();
    return super.liveChannelDetails;
  }

  @override
  set liveChannelDetails(LiveChannelDetails? value) {
    _$liveChannelDetailsAtom.reportWrite(value, super.liveChannelDetails, () {
      super.liveChannelDetails = value;
    });
  }

  late final _$liveChannelsAtom =
      Atom(name: 'FragmentStoreBase.liveChannels', context: context);

  @override
  ObservableList<CommonDataListModel> get liveChannels {
    _$liveChannelsAtom.reportRead();
    return super.liveChannels;
  }

  @override
  set liveChannels(ObservableList<CommonDataListModel> value) {
    _$liveChannelsAtom.reportWrite(value, super.liveChannels, () {
      super.liveChannels = value;
    });
  }

  late final _$liveChannelsPageAtom =
      Atom(name: 'FragmentStoreBase.liveChannelsPage', context: context);

  @override
  int get liveChannelsPage {
    _$liveChannelsPageAtom.reportRead();
    return super.liveChannelsPage;
  }

  @override
  set liveChannelsPage(int value) {
    _$liveChannelsPageAtom.reportWrite(value, super.liveChannelsPage, () {
      super.liveChannelsPage = value;
    });
  }

  late final _$liveChannelsIsLastPageAtom =
      Atom(name: 'FragmentStoreBase.liveChannelsIsLastPage', context: context);

  @override
  bool get liveChannelsIsLastPage {
    _$liveChannelsIsLastPageAtom.reportRead();
    return super.liveChannelsIsLastPage;
  }

  @override
  set liveChannelsIsLastPage(bool value) {
    _$liveChannelsIsLastPageAtom
        .reportWrite(value, super.liveChannelsIsLastPage, () {
      super.liveChannelsIsLastPage = value;
    });
  }

  late final _$liveChannelsFutureAtom =
      Atom(name: 'FragmentStoreBase.liveChannelsFuture', context: context);

  @override
  Future<ViewAllModel.ViewAllResponse>? get liveChannelsFuture {
    _$liveChannelsFutureAtom.reportRead();
    return super.liveChannelsFuture;
  }

  @override
  set liveChannelsFuture(Future<ViewAllModel.ViewAllResponse>? value) {
    _$liveChannelsFutureAtom.reportWrite(value, super.liveChannelsFuture, () {
      super.liveChannelsFuture = value;
    });
  }

  late final _$isRecommendedLoadingAtom =
      Atom(name: 'FragmentStoreBase.isRecommendedLoading', context: context);

  @override
  bool get isRecommendedLoading {
    _$isRecommendedLoadingAtom.reportRead();
    return super.isRecommendedLoading;
  }

  @override
  set isRecommendedLoading(bool value) {
    _$isRecommendedLoadingAtom.reportWrite(value, super.isRecommendedLoading,
        () {
      super.isRecommendedLoading = value;
    });
  }

  late final _$recommendedChannelsAtom =
      Atom(name: 'FragmentStoreBase.recommendedChannels', context: context);

  @override
  ObservableList<RecommendedChannel> get recommendedChannels {
    _$recommendedChannelsAtom.reportRead();
    return super.recommendedChannels;
  }

  @override
  set recommendedChannels(ObservableList<RecommendedChannel> value) {
    _$recommendedChannelsAtom.reportWrite(value, super.recommendedChannels, () {
      super.recommendedChannels = value;
    });
  }

  late final _$notificationListAtom =
      Atom(name: 'FragmentStoreBase.notificationList', context: context);

  @override
  ObservableList<NotificationModel> get notificationList {
    _$notificationListAtom.reportRead();
    return super.notificationList;
  }

  @override
  set notificationList(ObservableList<NotificationModel> value) {
    _$notificationListAtom.reportWrite(value, super.notificationList, () {
      super.notificationList = value;
    });
  }

  late final _$notificationPageAtom =
      Atom(name: 'FragmentStoreBase.notificationPage', context: context);

  @override
  int get notificationPage {
    _$notificationPageAtom.reportRead();
    return super.notificationPage;
  }

  @override
  set notificationPage(int value) {
    _$notificationPageAtom.reportWrite(value, super.notificationPage, () {
      super.notificationPage = value;
    });
  }

  late final _$notificationIsLastPageAtom =
      Atom(name: 'FragmentStoreBase.notificationIsLastPage', context: context);

  @override
  bool get notificationIsLastPage {
    _$notificationIsLastPageAtom.reportRead();
    return super.notificationIsLastPage;
  }

  @override
  set notificationIsLastPage(bool value) {
    _$notificationIsLastPageAtom
        .reportWrite(value, super.notificationIsLastPage, () {
      super.notificationIsLastPage = value;
    });
  }

  late final _$notificationIsLoadingAtom =
      Atom(name: 'FragmentStoreBase.notificationIsLoading', context: context);

  @override
  bool get notificationIsLoading {
    _$notificationIsLoadingAtom.reportRead();
    return super.notificationIsLoading;
  }

  @override
  set notificationIsLoading(bool value) {
    _$notificationIsLoadingAtom.reportWrite(value, super.notificationIsLoading,
        () {
      super.notificationIsLoading = value;
    });
  }

  late final _$notificationHasErrorAtom =
      Atom(name: 'FragmentStoreBase.notificationHasError', context: context);

  @override
  bool get notificationHasError {
    _$notificationHasErrorAtom.reportRead();
    return super.notificationHasError;
  }

  @override
  set notificationHasError(bool value) {
    _$notificationHasErrorAtom.reportWrite(value, super.notificationHasError,
        () {
      super.notificationHasError = value;
    });
  }

  late final _$notificationErrorAtom =
      Atom(name: 'FragmentStoreBase.notificationError', context: context);

  @override
  String? get notificationError {
    _$notificationErrorAtom.reportRead();
    return super.notificationError;
  }

  @override
  set notificationError(String? value) {
    _$notificationErrorAtom.reportWrite(value, super.notificationError, () {
      super.notificationError = value;
    });
  }

  late final _$currentMovieAtom =
      Atom(name: 'FragmentStoreBase.currentMovie', context: context);

  @override
  MovieData? get currentMovie {
    _$currentMovieAtom.reportRead();
    return super.currentMovie;
  }

  @override
  set currentMovie(MovieData? value) {
    _$currentMovieAtom.reportWrite(value, super.currentMovie, () {
      super.currentMovie = value;
    });
  }

  late final _$movieResponseAtom =
      Atom(name: 'FragmentStoreBase.movieResponse', context: context);

  @override
  MovieDetailResponse? get movieResponse {
    _$movieResponseAtom.reportRead();
    return super.movieResponse;
  }

  @override
  set movieResponse(MovieDetailResponse? value) {
    _$movieResponseAtom.reportWrite(value, super.movieResponse, () {
      super.movieResponse = value;
    });
  }

  late final _$selectedIndexAtom =
      Atom(name: 'FragmentStoreBase.selectedIndex', context: context);

  @override
  int get selectedIndex {
    _$selectedIndexAtom.reportRead();
    return super.selectedIndex;
  }

  @override
  set selectedIndex(int value) {
    _$selectedIndexAtom.reportWrite(value, super.selectedIndex, () {
      super.selectedIndex = value;
    });
  }

  late final _$currentIndexAtom =
      Atom(name: 'FragmentStoreBase.currentIndex', context: context);

  @override
  int get currentIndex {
    _$currentIndexAtom.reportRead();
    return super.currentIndex;
  }

  @override
  set currentIndex(int value) {
    _$currentIndexAtom.reportWrite(value, super.currentIndex, () {
      super.currentIndex = value;
    });
  }

  late final _$genreAtom =
      Atom(name: 'FragmentStoreBase.genre', context: context);

  @override
  String get genre {
    _$genreAtom.reportRead();
    return super.genre;
  }

  @override
  set genre(String value) {
    _$genreAtom.reportWrite(value, super.genre, () {
      super.genre = value;
    });
  }

  late final _$restrictedPlansAtom =
      Atom(name: 'FragmentStoreBase.restrictedPlans', context: context);

  @override
  String get restrictedPlans {
    _$restrictedPlansAtom.reportRead();
    return super.restrictedPlans;
  }

  @override
  set restrictedPlans(String value) {
    _$restrictedPlansAtom.reportWrite(value, super.restrictedPlans, () {
      super.restrictedPlans = value;
    });
  }

  late final _$selectedSourceUrlAtom =
      Atom(name: 'FragmentStoreBase.selectedSourceUrl', context: context);

  @override
  String? get selectedSourceUrl {
    _$selectedSourceUrlAtom.reportRead();
    return super.selectedSourceUrl;
  }

  @override
  set selectedSourceUrl(String? value) {
    _$selectedSourceUrlAtom.reportWrite(value, super.selectedSourceUrl, () {
      super.selectedSourceUrl = value;
    });
  }

  late final _$selectedSourceChoiceAtom =
      Atom(name: 'FragmentStoreBase.selectedSourceChoice', context: context);

  @override
  String? get selectedSourceChoice {
    _$selectedSourceChoiceAtom.reportRead();
    return super.selectedSourceChoice;
  }

  @override
  set selectedSourceChoice(String? value) {
    _$selectedSourceChoiceAtom.reportWrite(value, super.selectedSourceChoice,
        () {
      super.selectedSourceChoice = value;
    });
  }

  late final _$selectedEmbedContentAtom =
      Atom(name: 'FragmentStoreBase.selectedEmbedContent', context: context);

  @override
  String? get selectedEmbedContent {
    _$selectedEmbedContentAtom.reportRead();
    return super.selectedEmbedContent;
  }

  @override
  set selectedEmbedContent(String? value) {
    _$selectedEmbedContentAtom.reportWrite(value, super.selectedEmbedContent,
        () {
      super.selectedEmbedContent = value;
    });
  }

  late final _$postTypeAtom =
      Atom(name: 'FragmentStoreBase.postType', context: context);

  @override
  PostType? get postType {
    _$postTypeAtom.reportRead();
    return super.postType;
  }

  @override
  set postType(PostType? value) {
    _$postTypeAtom.reportWrite(value, super.postType, () {
      super.postType = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: 'FragmentStoreBase.isError', context: context);

  @override
  bool get isError {
    _$isErrorAtom.reportRead();
    return super.isError;
  }

  @override
  set isError(bool value) {
    _$isErrorAtom.reportWrite(value, super.isError, () {
      super.isError = value;
    });
  }

  late final _$hasDataAtom =
      Atom(name: 'FragmentStoreBase.hasData', context: context);

  @override
  bool get hasData {
    _$hasDataAtom.reportRead();
    return super.hasData;
  }

  @override
  set hasData(bool value) {
    _$hasDataAtom.reportWrite(value, super.hasData, () {
      super.hasData = value;
    });
  }

  late final _$isSharingAtom =
      Atom(name: 'FragmentStoreBase.isSharing', context: context);

  @override
  bool get isSharing {
    _$isSharingAtom.reportRead();
    return super.isSharing;
  }

  @override
  set isSharing(bool value) {
    _$isSharingAtom.reportWrite(value, super.isSharing, () {
      super.isSharing = value;
    });
  }

  late final _$isDownloadingAtom =
      Atom(name: 'FragmentStoreBase.isDownloading', context: context);

  @override
  bool get isDownloading {
    _$isDownloadingAtom.reportRead();
    return super.isDownloading;
  }

  @override
  set isDownloading(bool value) {
    _$isDownloadingAtom.reportWrite(value, super.isDownloading, () {
      super.isDownloading = value;
    });
  }

  late final _$showDetailsAtom =
      Atom(name: 'FragmentStoreBase.showDetails', context: context);

  @override
  MovieData? get showDetails {
    _$showDetailsAtom.reportRead();
    return super.showDetails;
  }

  @override
  set showDetails(MovieData? value) {
    _$showDetailsAtom.reportWrite(value, super.showDetails, () {
      super.showDetails = value;
    });
  }

  late final _$selectedEpisodeAtom =
      Atom(name: 'FragmentStoreBase.selectedEpisode', context: context);

  @override
  MovieData? get selectedEpisode {
    _$selectedEpisodeAtom.reportRead();
    return super.selectedEpisode;
  }

  @override
  set selectedEpisode(MovieData? value) {
    _$selectedEpisodeAtom.reportWrite(value, super.selectedEpisode, () {
      super.selectedEpisode = value;
    });
  }

  late final _$allEpisodesAtom =
      Atom(name: 'FragmentStoreBase.allEpisodes', context: context);

  @override
  ObservableList<MovieData> get allEpisodes {
    _$allEpisodesAtom.reportRead();
    return super.allEpisodes;
  }

  @override
  set allEpisodes(ObservableList<MovieData> value) {
    _$allEpisodesAtom.reportWrite(value, super.allEpisodes, () {
      super.allEpisodes = value;
    });
  }

  late final _$selectedEpisodeIndexAtom =
      Atom(name: 'FragmentStoreBase.selectedEpisodeIndex', context: context);

  @override
  int? get selectedEpisodeIndex {
    _$selectedEpisodeIndexAtom.reportRead();
    return super.selectedEpisodeIndex;
  }

  @override
  set selectedEpisodeIndex(int? value) {
    _$selectedEpisodeIndexAtom.reportWrite(value, super.selectedEpisodeIndex,
        () {
      super.selectedEpisodeIndex = value;
    });
  }

  late final _$selectedSeasonNumberAtom =
      Atom(name: 'FragmentStoreBase.selectedSeasonNumber', context: context);

  @override
  int? get selectedSeasonNumber {
    _$selectedSeasonNumberAtom.reportRead();
    return super.selectedSeasonNumber;
  }

  @override
  set selectedSeasonNumber(int? value) {
    _$selectedSeasonNumberAtom.reportWrite(value, super.selectedSeasonNumber,
        () {
      super.selectedSeasonNumber = value;
    });
  }

  late final _$selectedSeasonAtom =
      Atom(name: 'FragmentStoreBase.selectedSeason', context: context);

  @override
  CommonDataDetailsModel? get selectedSeason {
    _$selectedSeasonAtom.reportRead();
    return super.selectedSeason;
  }

  @override
  set selectedSeason(CommonDataDetailsModel? value) {
    _$selectedSeasonAtom.reportWrite(value, super.selectedSeason, () {
      super.selectedSeason = value;
    });
  }

  late final _$visibleEpisodesAtom =
      Atom(name: 'FragmentStoreBase.visibleEpisodes', context: context);

  @override
  ObservableList<MovieData> get visibleEpisodes {
    _$visibleEpisodesAtom.reportRead();
    return super.visibleEpisodes;
  }

  @override
  set visibleEpisodes(ObservableList<MovieData> value) {
    _$visibleEpisodesAtom.reportWrite(value, super.visibleEpisodes, () {
      super.visibleEpisodes = value;
    });
  }

  late final _$isSeasonLoadingAtom =
      Atom(name: 'FragmentStoreBase.isSeasonLoading', context: context);

  @override
  bool get isSeasonLoading {
    _$isSeasonLoadingAtom.reportRead();
    return super.isSeasonLoading;
  }

  @override
  set isSeasonLoading(bool value) {
    _$isSeasonLoadingAtom.reportWrite(value, super.isSeasonLoading, () {
      super.isSeasonLoading = value;
    });
  }

  late final _$isSeasonExpandedAtom =
      Atom(name: 'FragmentStoreBase.isSeasonExpanded', context: context);

  @override
  bool get isSeasonExpanded {
    _$isSeasonExpandedAtom.reportRead();
    return super.isSeasonExpanded;
  }

  @override
  set isSeasonExpanded(bool value) {
    _$isSeasonExpandedAtom.reportWrite(value, super.isSeasonExpanded, () {
      super.isSeasonExpanded = value;
    });
  }

  late final _$episodeExpandedStatesAtom =
      Atom(name: 'FragmentStoreBase.episodeExpandedStates', context: context);

  @override
  Map<int, bool> get episodeExpandedStates {
    _$episodeExpandedStatesAtom.reportRead();
    return super.episodeExpandedStates;
  }

  @override
  set episodeExpandedStates(Map<int, bool> value) {
    _$episodeExpandedStatesAtom.reportWrite(value, super.episodeExpandedStates,
        () {
      super.episodeExpandedStates = value;
    });
  }

  late final _$deviceListAtom =
      Atom(name: 'FragmentStoreBase.deviceList', context: context);

  @override
  ObservableList<DeviceData> get deviceList {
    _$deviceListAtom.reportRead();
    return super.deviceList;
  }

  @override
  set deviceList(ObservableList<DeviceData> value) {
    _$deviceListAtom.reportWrite(value, super.deviceList, () {
      super.deviceList = value;
    });
  }

  late final _$deviceStatsAtom =
      Atom(name: 'FragmentStoreBase.deviceStats', context: context);

  @override
  Stats? get deviceStats {
    _$deviceStatsAtom.reportRead();
    return super.deviceStats;
  }

  @override
  set deviceStats(Stats? value) {
    _$deviceStatsAtom.reportWrite(value, super.deviceStats, () {
      super.deviceStats = value;
    });
  }

  late final _$deviceUserLevelAtom =
      Atom(name: 'FragmentStoreBase.deviceUserLevel', context: context);

  @override
  String? get deviceUserLevel {
    _$deviceUserLevelAtom.reportRead();
    return super.deviceUserLevel;
  }

  @override
  set deviceUserLevel(String? value) {
    _$deviceUserLevelAtom.reportWrite(value, super.deviceUserLevel, () {
      super.deviceUserLevel = value;
    });
  }

  late final _$deviceHasErrorAtom =
      Atom(name: 'FragmentStoreBase.deviceHasError', context: context);

  @override
  bool get deviceHasError {
    _$deviceHasErrorAtom.reportRead();
    return super.deviceHasError;
  }

  @override
  set deviceHasError(bool value) {
    _$deviceHasErrorAtom.reportWrite(value, super.deviceHasError, () {
      super.deviceHasError = value;
    });
  }

  late final _$setEnableLiveStreamingAsyncAction =
      AsyncAction('FragmentStoreBase.setEnableLiveStreaming', context: context);

  @override
  Future<void> setEnableLiveStreaming(bool liveStreaming) {
    return _$setEnableLiveStreamingAsyncAction
        .run(() => super.setEnableLiveStreaming(liveStreaming));
  }

  late final _$FragmentStoreBaseActionController =
      ActionController(name: 'FragmentStoreBase', context: context);

  @override
  void setMembershipLoading(bool val) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setMembershipLoading');
    try {
      return super.setMembershipLoading(val);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserName(String value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setUserName');
    try {
      return super.setUserName(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserEmail(String value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setUserEmail');
    try {
      return super.setUserEmail(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotification(int value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setNotification');
    try {
      return super.setNotification(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoaderShow(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLoaderShow');
    try {
      return super.setLoaderShow(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setContinueWatchLoading(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setContinueWatchLoading');
    try {
      return super.setContinueWatchLoading(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWatchListLoading(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setWatchListLoading');
    try {
      return super.setWatchListLoading(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLikedContentLoading(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLikedContentLoading');
    try {
      return super.setLikedContentLoading(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDownloadsLoading(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setDownloadsLoading');
    try {
      return super.setDownloadsLoading(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReminderListLoading(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setReminderListLoading');
    try {
      return super.setReminderListLoading(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLastPage(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLastPage');
    try {
      return super.setLastPage(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPage(int value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setPage');
    try {
      return super.setPage(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setContinueWatch(List<CommonDataListModel> list) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setContinueWatch');
    try {
      return super.setContinueWatch(list);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWatchList(List<CommonDataListModel> list) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setWatchList');
    try {
      return super.setWatchList(list);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRandomWatchList(List<CommonDataListModel> list) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setRandomWatchList');
    try {
      return super.setRandomWatchList(list);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLikedContentList(List<CommonDataListModel> list) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLikedContentList');
    try {
      return super.setLikedContentList(list);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReminderList(List<ReminderList> list) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setReminderList');
    try {
      return super.setReminderList(list);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMembership(MembershipModel? value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setMembership');
    try {
      return super.setMembership(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHasMembership(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setHasMembership');
    try {
      return super.setHasMembership(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearContinueWatch() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.clearContinueWatch');
    try {
      return super.clearContinueWatch();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFromContinueWatch(CommonDataListModel data) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.removeFromContinueWatch');
    try {
      return super.removeFromContinueWatch(data);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearWatchList() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.clearWatchList');
    try {
      return super.clearWatchList();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearRandomWatchList() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.clearRandomWatchList');
    try {
      return super.clearRandomWatchList();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearLikedContentList() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.clearLikedContentList');
    try {
      return super.clearLikedContentList();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearReminderList() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.clearReminderList');
    try {
      return super.clearReminderList();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetLoadingStates() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.resetLoadingStates');
    try {
      return super.resetLoadingStates();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDashboardFuture(String key, Future<Model.DashboardResponse> future) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setDashboardFuture');
    try {
      return super.setDashboardFuture(key, future);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHomeTabIndex(int value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setHomeTabIndex');
    try {
      return super.setHomeTabIndex(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchQuery(String value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchPage(int value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSearchPage');
    try {
      return super.setSearchPage(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsSearchLastPage(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setIsSearchLastPage');
    try {
      return super.setIsSearchLastPage(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchMovies(List<CommonDataListModel> list,
      {bool isRefresh = false}) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSearchMovies');
    try {
      return super.setSearchMovies(list, isRefresh: isRefresh);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSearchMovies() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.clearSearchMovies');
    try {
      return super.clearSearchMovies();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRecentSearches(List<RecentSearchListModel> list,
      {bool isRefresh = false}) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setRecentSearches');
    try {
      return super.setRecentSearches(list, isRefresh: isRefresh);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeRecentById(int id) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.removeRecentById');
    try {
      return super.removeRecentById(id);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchFuture(Future<List<CommonDataListModel>>? future) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSearchFuture');
    try {
      return super.setSearchFuture(future);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRecentFuture(Future<List<RecentSearchListModel>>? future) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setRecentFuture');
    try {
      return super.setRecentFuture(future);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLiveChannelsPage(int value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLiveChannelsPage');
    try {
      return super.setLiveChannelsPage(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLiveChannelsIsLastPage(bool value) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLiveChannelsIsLastPage');
    try {
      return super.setLiveChannelsIsLastPage(value);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLiveChannelsFuture(Future<ViewAllModel.ViewAllResponse>? future) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLiveChannelsFuture');
    try {
      return super.setLiveChannelsFuture(future);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLiveChannels(List<CommonDataListModel> list,
      {bool isRefresh = false}) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setLiveChannels');
    try {
      return super.setLiveChannels(list, isRefresh: isRefresh);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRecommendedChannels(List<RecommendedChannel> list,
      {bool isRefresh = true}) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setRecommendedChannels');
    try {
      return super.setRecommendedChannels(list, isRefresh: isRefresh);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRecommendedLoading(bool val) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setRecommendedLoading');
    try {
      return super.setRecommendedLoading(val);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotificationPage(int page) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setNotificationPage');
    try {
      return super.setNotificationPage(page);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotificationIsLastPage(bool isLastPage) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setNotificationIsLastPage');
    try {
      return super.setNotificationIsLastPage(isLastPage);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotificationIsLoading(bool loading) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setNotificationIsLoading');
    try {
      return super.setNotificationIsLoading(loading);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotificationHasError(bool hasError) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setNotificationHasError');
    try {
      return super.setNotificationHasError(hasError);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotificationError(String? error) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setNotificationError');
    try {
      return super.setNotificationError(error);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotificationList(List<NotificationModel> list,
      {bool isRefresh = false}) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setNotificationList');
    try {
      return super.setNotificationList(list, isRefresh: isRefresh);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearNotificationList() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.clearNotificationList');
    try {
      return super.clearNotificationList();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetNotificationState() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.resetNotificationState');
    try {
      return super.resetNotificationState();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void incrementNotificationPage() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.incrementNotificationPage');
    try {
      return super.incrementNotificationPage();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentMovie(MovieData? movie) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setCurrentMovie');
    try {
      return super.setCurrentMovie(movie);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMovieResponse(MovieDetailResponse? response) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setMovieResponse');
    try {
      return super.setMovieResponse(response);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedIndex(int index) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedIndex');
    try {
      return super.setSelectedIndex(index);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentIndex(int index) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setCurrentIndex');
    try {
      return super.setCurrentIndex(index);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenre(String genre) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setGenre');
    try {
      return super.setGenre(genre);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRestrictedPlans(String plans) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setRestrictedPlans');
    try {
      return super.setRestrictedPlans(plans);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedSourceUrl(String? url) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedSourceUrl');
    try {
      return super.setSelectedSourceUrl(url);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedSourceChoice(String? choice) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedSourceChoice');
    try {
      return super.setSelectedSourceChoice(choice);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedEmbedContent(String? content) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedEmbedContent');
    try {
      return super.setSelectedEmbedContent(content);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPostType(PostType? type) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setPostType');
    try {
      return super.setPostType(type);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMovieDetailError(bool error) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setMovieDetailError');
    try {
      return super.setMovieDetailError(error);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHasData(bool hasData) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setHasData');
    try {
      return super.setHasData(hasData);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsSharing(bool sharing) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setIsSharing');
    try {
      return super.setIsSharing(sharing);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsDownloading(bool downloading) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setIsDownloading');
    try {
      return super.setIsDownloading(downloading);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetMovieDetailState() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.resetMovieDetailState');
    try {
      return super.resetMovieDetailState();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setShowDetails(MovieData? show) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setShowDetails');
    try {
      return super.setShowDetails(show);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedEpisode(MovieData? episode) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedEpisode');
    try {
      return super.setSelectedEpisode(episode);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAllEpisodes(List<MovieData> episodes) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setAllEpisodes');
    try {
      return super.setAllEpisodes(episodes);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedEpisodeIndex(int? index) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedEpisodeIndex');
    try {
      return super.setSelectedEpisodeIndex(index);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedSeasonNumber(int? seasonNumber) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedSeasonNumber');
    try {
      return super.setSelectedSeasonNumber(seasonNumber);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedSeason(CommonDataDetailsModel? season) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSelectedSeason');
    try {
      return super.setSelectedSeason(season);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVisibleEpisodes(List<MovieData> episodes) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setVisibleEpisodes');
    try {
      return super.setVisibleEpisodes(episodes);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addVisibleEpisode(MovieData episode) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.addVisibleEpisode');
    try {
      return super.addVisibleEpisode(episode);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSeasonLoading(bool loading) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSeasonLoading');
    try {
      return super.setSeasonLoading(loading);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSeasonExpanded(bool expanded) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setSeasonExpanded');
    try {
      return super.setSeasonExpanded(expanded);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEpisodeExpanded(int episodeId, bool expanded) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setEpisodeExpanded');
    try {
      return super.setEpisodeExpanded(episodeId, expanded);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetTvShowState() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.resetTvShowState');
    try {
      return super.resetTvShowState();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDeviceList(List<DeviceData> devices) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setDeviceList');
    try {
      return super.setDeviceList(devices);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDeviceStats(Stats? stats) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setDeviceStats');
    try {
      return super.setDeviceStats(stats);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDeviceUserLevel(String? userLevel) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setDeviceUserLevel');
    try {
      return super.setDeviceUserLevel(userLevel);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDeviceError(bool hasError) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.setDeviceError');
    try {
      return super.setDeviceError(hasError);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeDeviceFromList(String deviceId) {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.removeDeviceFromList');
    try {
      return super.removeDeviceFromList(deviceId);
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetDeviceState() {
    final _$actionInfo = _$FragmentStoreBaseActionController.startAction(
        name: 'FragmentStoreBase.resetDeviceState');
    try {
      return super.resetDeviceState();
    } finally {
      _$FragmentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
userName: ${userName},
userEmail: ${userEmail},
notification: ${notification},
isLoaderShow: ${isLoaderShow},
isMembershipLoading: ${isMembershipLoading},
isContinueWatchLoading: ${isContinueWatchLoading},
isWatchListLoading: ${isWatchListLoading},
isLikedContentLoading: ${isLikedContentLoading},
isDownloadsLoading: ${isDownloadsLoading},
isReminderListLoading: ${isReminderListLoading},
mIsLastPage: ${mIsLastPage},
mPage: ${mPage},
continueWatch: ${continueWatch},
watchList: ${watchList},
randomWatchList: ${randomWatchList},
likedContentList: ${likedContentList},
reminderList: ${reminderList},
membership: ${membership},
hasMembership: ${hasMembership},
dashboardFutures: ${dashboardFutures},
liveCategoryFuture: ${liveCategoryFuture},
homeTabIndex: ${homeTabIndex},
searchMovies: ${searchMovies},
recentSearches: ${recentSearches},
searchPage: ${searchPage},
isSearchLastPage: ${isSearchLastPage},
searchQuery: ${searchQuery},
searchFuture: ${searchFuture},
recentFuture: ${recentFuture},
isLiveEnabled: ${isLiveEnabled},
liveChannelDetails: ${liveChannelDetails},
liveChannels: ${liveChannels},
liveChannelsPage: ${liveChannelsPage},
liveChannelsIsLastPage: ${liveChannelsIsLastPage},
liveChannelsFuture: ${liveChannelsFuture},
isRecommendedLoading: ${isRecommendedLoading},
recommendedChannels: ${recommendedChannels},
notificationList: ${notificationList},
notificationPage: ${notificationPage},
notificationIsLastPage: ${notificationIsLastPage},
notificationIsLoading: ${notificationIsLoading},
notificationHasError: ${notificationHasError},
notificationError: ${notificationError},
currentMovie: ${currentMovie},
movieResponse: ${movieResponse},
selectedIndex: ${selectedIndex},
currentIndex: ${currentIndex},
genre: ${genre},
restrictedPlans: ${restrictedPlans},
selectedSourceUrl: ${selectedSourceUrl},
selectedSourceChoice: ${selectedSourceChoice},
selectedEmbedContent: ${selectedEmbedContent},
postType: ${postType},
isError: ${isError},
hasData: ${hasData},
isSharing: ${isSharing},
isDownloading: ${isDownloading},
showDetails: ${showDetails},
selectedEpisode: ${selectedEpisode},
allEpisodes: ${allEpisodes},
selectedEpisodeIndex: ${selectedEpisodeIndex},
selectedSeasonNumber: ${selectedSeasonNumber},
selectedSeason: ${selectedSeason},
visibleEpisodes: ${visibleEpisodes},
isSeasonLoading: ${isSeasonLoading},
isSeasonExpanded: ${isSeasonExpanded},
episodeExpandedStates: ${episodeExpandedStates},
deviceList: ${deviceList},
deviceStats: ${deviceStats},
deviceUserLevel: ${deviceUserLevel},
deviceHasError: ${deviceHasError},
canLoadMoreNotifications: ${canLoadMoreNotifications},
hasNotificationData: ${hasNotificationData},
hasNotificationError: ${hasNotificationError},
notificationErrorMessage: ${notificationErrorMessage},
notificationDataCount: ${notificationDataCount},
hasMovieData: ${hasMovieData},
hasMovieError: ${hasMovieError},
isMovieSharing: ${isMovieSharing},
isMovieDownloading: ${isMovieDownloading}
    ''';
  }
}
