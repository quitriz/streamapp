import 'package:cast/cast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/local/app_localizations.dart';
import 'package:streamit_flutter/local/base_language.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/models/resume_video_model.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/constants.dart';

import '../models/blog/wp_comments_model.dart' as BlogCommentModel;
import '../models/blog/wp_post_response.dart' as BlogModel;

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  String userNonce = '';

  @observable
  String wooNonce = '';

  @observable
  bool showItemName = false;

  @observable
  bool showPIP = false;

  @observable
  bool isPIPOn = false;

  // Voice Search observables
  @observable
  bool isListening = false;

  @observable
  String voiceText = '';

  @observable
  bool showVoiceButton = false;

//region Continue Watch

  @observable
  var continueWatchList = ObservableList<ContinueWatchModel>();

  @observable
  int continueWatchCurrentTabIndex = 0;

  @observable
  int continueWatchPage = 1;

  @observable
  bool continueWatchIsLastPage = false;

  @observable
  bool continueWatchIsLoading = false;

  @observable
  String? continueWatchError;

  @observable
  Future<List<CommonDataListModel>>? continueWatchFuture;

  @observable
  ObservableList<CommonDataListModel> continueWatchDataList = ObservableList<CommonDataListModel>();

  @action
  void addToWatchContinue(ContinueWatchModel data) => continueWatchList.add(data);

  @action
  void setContinueWatchCurrentTabIndex(int index) => continueWatchCurrentTabIndex = index;

  @action
  void setContinueWatchPage(int page) => continueWatchPage = page;

  @action
  void setContinueWatchIsLastPage(bool isLastPage) => continueWatchIsLastPage = isLastPage;

  @action
  void setContinueWatchIsLoading(bool loading) => continueWatchIsLoading = loading;

  @action
  void setContinueWatchError(String? error) => continueWatchError = error;

  // Voice Search actions
  @action
  void setListening(bool listening) => isListening = listening;

  @action
  void setVoiceText(String text) => voiceText = text;

  @action
  void setShowVoiceButton(bool show) => showVoiceButton = show;

  @action
  void resetVoiceSearch() {
    isListening = false;
    voiceText = '';
    showVoiceButton = false;
  }

  @action
  void setContinueWatchFuture(Future<List<CommonDataListModel>>? future) => continueWatchFuture = future;

  @action
  void setContinueWatchDataList(List<CommonDataListModel> dataList, {bool isRefresh = false}) {
    if (isRefresh) continueWatchDataList.clear();
    continueWatchDataList.addAll(dataList);
  }

  @action
  void addToContinueWatchDataList(CommonDataListModel data) => continueWatchDataList.add(data);

  @action
  void removeFromContinueWatchDataList(CommonDataListModel data) => continueWatchDataList.remove(data);

  @action
  void clearContinueWatchDataList() => continueWatchDataList.clear();

  @action
  void resetContinueWatchState() {
    continueWatchCurrentTabIndex = 0;
    continueWatchPage = 1;
    continueWatchIsLastPage = false;
    continueWatchIsLoading = false;
    continueWatchError = null;
    continueWatchDataList.clear();
  }

  // Computed properties for continue watch
  @computed
  List<String> get continueWatchPostTypeList => [
        dashboardTypeMovie,
        dashboardTypeEpisode,
        dashboardTypeVideo,
      ];

  @computed
  bool get hasContinueWatchData => continueWatchDataList.isNotEmpty;

  @computed
  String get currentContinueWatchPostType => continueWatchPostTypeList[continueWatchCurrentTabIndex];

  @computed
  bool get isContinueWatchLoading => continueWatchIsLoading;

  @computed
  bool get hasContinueWatchError => continueWatchError != null;

  @computed
  String? get continueWatchErrorMessage => continueWatchError;

  @computed
  int get continueWatchDataCount => continueWatchDataList.length;

  @computed
  bool get canLoadMoreContinueWatch => !continueWatchIsLastPage && !continueWatchIsLoading;

  @computed
  List<CommonDataListModel> get currentTabContinueWatchData {
    return continueWatchDataList.where((item) => item.postType == currentContinueWatchPostType).toList();
  }

  @action
  void startContinueWatchLoading() {
    setContinueWatchIsLoading(true);
    setContinueWatchError(null);
  }

  @action
  void stopContinueWatchLoading() {
    setContinueWatchIsLoading(false);
  }

  @action
  void updateContinueWatchFuture(Future<List<CommonDataListModel>>? future) {
    this.continueWatchFuture = future;
  }

  @action
  void refreshContinueWatchState() {
    setContinueWatchPage(1);
  }

  @action
  void incrementContinueWatchPage() {
    if (!continueWatchIsLastPage) {
      setContinueWatchPage(continueWatchPage + 1);
    }
  }

  @action
  void changeContinueWatchTab(int index) {
    setContinueWatchCurrentTabIndex(index);
    setContinueWatchPage(1);
  }

  //region Blogs
  @observable
  ObservableList<BlogModel.WpPostResponse> blogList = ObservableList<BlogModel.WpPostResponse>();

  @observable
  int blogPage = 1;

  @observable
  bool blogIsLastPage = false;

  @observable
  bool blogIsError = false;

  @observable
  bool blogHasShowClearTextIcon = false;

  @observable
  String blogSearchText = '';

  @observable
  Future<List<BlogModel.WpPostResponse>>? blogFuture;

  @action
  void setBlogPage(int value) => blogPage = value;

  @action
  void setBlogIsLastPage(bool value) => blogIsLastPage = value;

  @action
  void setBlogIsError(bool value) => blogIsError = value;

  @action
  void setBlogHasShowClearTextIcon(bool value) => blogHasShowClearTextIcon = value;

  @action
  void setBlogSearchText(String value) => blogSearchText = value;

  @action
  void setBlogFuture(Future<List<BlogModel.WpPostResponse>>? future) => blogFuture = future;

  @action
  void setBlogList(List<BlogModel.WpPostResponse> list, {bool isRefresh = false}) {
    if (isRefresh) blogList.clear();
    blogList.addAll(list);
  }

  // Detail
  @observable
  BlogModel.WpPostResponse? currentBlog;

  @observable
  ObservableList<BlogCommentModel.WpCommentModel> commentList = ObservableList<BlogCommentModel.WpCommentModel>();

  @observable
  int commentsPage = 1;

  @observable
  bool commentsIsLastPage = false;

  @observable
  Future<List<BlogCommentModel.WpCommentModel>>? commentsFuture;

  @action
  void setCurrentBlog(BlogModel.WpPostResponse blog) => currentBlog = blog;

  @action
  void setCommentsPage(int value) => commentsPage = value;

  @action
  void setCommentsIsLastPage(bool value) => commentsIsLastPage = value;

  @action
  void setCommentsFuture(Future<List<BlogCommentModel.WpCommentModel>>? future) => commentsFuture = future;

  @action
  void setCommentList(List<BlogCommentModel.WpCommentModel> list, {bool isRefresh = false}) {
    if (isRefresh) commentList.clear();
    commentList.addAll(list);
  }

  @action
  void addComment(BlogCommentModel.WpCommentModel value) {
    commentList.add(value);
  }

  //endregion Blogs

  @action
  void removeFromWatchContinue(ContinueWatchModel data) => continueWatchList.remove(data);

  @action
  void clearWatchContinue() => continueWatchList.clear();

// endregion

//region User Details

  @observable
  String? loginDevice = '';

  @observable
  int? userId = getIntAsync(USER_ID);

  @observable
  String? userName = getStringAsync(USERNAME);

  @observable
  String? userEmail = getStringAsync(USER_EMAIL);

  @observable
  String? userProfileImage = getStringAsync(USER_PROFILE);

  @observable
  String? userFirstName = getStringAsync(NAME);

  @observable
  String? userLastName = getStringAsync(LAST_NAME);

  @observable
  bool isLoading = false;

  @observable
  String? appLogo = getStringAsync(APP_LOGO);

  @observable
  String? bannerDefaultImage = getStringAsync(BANNER_DEFAULT_IMAGE);

  @observable
  String? personDefaultImage = getStringAsync(PERSON_DEFAULT_IMAGE);

  @observable
  String? sliderDefaultImage = getStringAsync(SLIDER_DEFAULT_IMAGE);

  @action
  Future<void> setShowItemName(bool val) async {
    showItemName = val;
  }

  @action
  Future<void> setWooNonce(String val) async {
    wooNonce = val;
    await setValue(WOO_NONCE, '$val');
  }

  @action
  Future<void> setUserNonce(String val) async {
    userNonce = val;
    await setValue(USER_NONCE, '$val');
  }

  @action
  Future<void> setLoginDevice(String? deviceId) async {
    loginDevice = deviceId;
    await setValue(DEVICE_ID, deviceId);
  }

  @action
  Future<void> setUserId(int? id) async {
    userId = id;
    await setValue(USER_ID, id);
  }

  @action
  Future<void> setUserName(String? name) async {
    userName = name;
    await setValue(USERNAME, name);
  }

  @action
  Future<void> setUserEmail(String? value) async {
    userEmail = value;
    await setValue(USER_EMAIL, value);
  }

  @action
  Future<void> setUserProfile(String? image) async {
    userProfileImage = image;
    await setValue(USER_PROFILE, image);
  }

  @action
  Future<void> setFirstName(String? name) async {
    userFirstName = name;
    await setValue(NAME, name);
  }

  @action
  Future<void> setLastName(String? name) async {
    userLastName = name;
    await setValue(LAST_NAME, name);
  }

  @action
  Future<void> setAppLogo(String? logo) async {
    appLogo = logo;
    await setValue(APP_LOGO, logo);
  }

  @action
  Future<void> setBannerDefaultImage(String? image) async {
    bannerDefaultImage = image;
    await setValue(BANNER_DEFAULT_IMAGE, image);
  }

  @action
  Future<void> setPersonDefaultImage(String? image) async {
    personDefaultImage = image;
    await setValue(PERSON_DEFAULT_IMAGE, image);
  }

  @action
  Future<void> setSliderDefaultImage(String? image) async {
    sliderDefaultImage = image;
    await setValue(SLIDER_DEFAULT_IMAGE, image);
  }

  /// Returns true if app logo from API exists and is a valid URL
  bool get hasValidApiLogo {
    return appLogo.validate().isNotEmpty && (appLogo.validate().startsWith('http://') || appLogo.validate().startsWith('https://'));
  }

  /// Returns true if banner default image from API exists and is a valid URL
  bool get hasValidBannerDefaultImage {
    return bannerDefaultImage.validate().isNotEmpty && (bannerDefaultImage.validate().startsWith('http://') || bannerDefaultImage.validate().startsWith('https://'));
  }

  /// Returns true if person default image from API exists and is a valid URL
  bool get hasValidPersonDefaultImage {
    return personDefaultImage.validate().isNotEmpty && (personDefaultImage.validate().startsWith('http://') || personDefaultImage.validate().startsWith('https://'));
  }

  /// Returns true if slider default image from API exists and is a valid URL
  bool get hasValidSliderDefaultImage {
    return sliderDefaultImage.validate().isNotEmpty && (sliderDefaultImage.validate().startsWith('http://') || sliderDefaultImage.validate().startsWith('https://'));
  }

//endregion

//region Subscription Plan Details
  @observable
  String subscriptionPlanId = "";

  @observable
  String subscriptionPlanStartDate = "";

  @observable
  String subscriptionPlanExpDate = "";

  @observable
  String subscriptionPlanStatus = "";

  @observable
  String subscriptionPlanTrialStatus = "";

  @observable
  String subscriptionPlanName = "";

  @observable
  String subscriptionPlanAmount = "";

  @observable
  String subscriptionTrialPlanEndDate = "";

  @observable
  String subscriptionTrialPlanStatus = "";

  @observable
  int downloadPercentage = 0;

  @observable
  bool hasErrorWhenDownload = false;

  @observable
  ObservableList<DownloadData> downloadedItemList = ObservableList.of(<DownloadData>[]);

  @observable
  bool isDownloading = false;

  @observable
  bool isTrailerVideoPlaying = false;

  @action
  void setTrailerVideoPlayer(bool value) {
    isTrailerVideoPlaying = value;
  }

  @action
  void setDownloading(bool val) {
    isDownloading = val;
  }

  @action
  void setDownloadError(bool val) {
    hasErrorWhenDownload = val;
  }

  @action
  void setDownloadPercentage(int val) {
    downloadPercentage = val;
  }

  @action
  Future<void> setSubscriptionPlanId(String id) async {
    subscriptionPlanId = id;
    await setValue(SUBSCRIPTION_PLAN_ID, id);
  }

  @action
  Future<void> setSubscriptionTrialPlanStatus(String trialStatus) async {
    subscriptionTrialPlanStatus = trialStatus;
    await setValue(SUBSCRIPTION_PLAN_TRIAL_STATUS, trialStatus);
  }

  @action
  Future<void> setSubscriptionPlanStartDate(String date) async {
    subscriptionPlanStartDate = date;
    await setValue(SUBSCRIPTION_PLAN_START_DATE, date);
  }

  @action
  Future<void> setSubscriptionPlanExpDate(String date) async {
    subscriptionPlanExpDate = date;
    await setValue(SUBSCRIPTION_PLAN_EXP_DATE, date);
  }

  @action
  Future<void> setSubscriptionPlanStatus(String status) async {
    subscriptionPlanStatus = status;
    await setValue(SUBSCRIPTION_PLAN_STATUS, status);
  }

  @action
  Future<void> setSubscriptionPlanName(String name) async {
    subscriptionPlanName = name;
    await setValue(SUBSCRIPTION_PLAN_NAME, name);
  }

  @action
  Future<void> setSubscriptionPlanAmount(String amount) async {
    subscriptionPlanAmount = amount;
    await setValue(SUBSCRIPTION_PLAN_AMOUNT, amount);
  }

  @action
  Future<void> setSubscriptionTrialPlanEndDate(String planEndDate) async {
    subscriptionTrialPlanEndDate = planEndDate;
    await setValue(SUBSCRIPTION_PLAN_TRIAL_END_DATE, planEndDate);
  }

  /// Apply membership model values to the store (DRY helper).
  @action
  Future<void> applyMembershipToStore(MembershipModel membership) async {
    try {
      await setSubscriptionPlanStatus(userPlanStatus);
      await setSubscriptionPlanName(membership.name.validate());
      await setSubscriptionPlanId(membership.id.validate());
      await setSubscriptionPlanStartDate(membership.startdate.validate());
      await setSubscriptionPlanAmount(membership.billingAmount?.toString() ?? '');

      // Expiry date (membership.enddate is expected in seconds)
      final int? endSec = membership.enddate;
      if (endSec != null && endSec > 0) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(endSec * 1000);
        await setSubscriptionPlanExpDate(DateFormat(dateFormatPmp).format(expiry));
      } else {
        // If you prefer to not overwrite when invalid, remove this line
        await setSubscriptionPlanExpDate('');
      }

      /// In-app purchase identifiers
      if (coreStore.isInAppPurchaseEnabled) {
        final String appleId = membership.appStorePlanIdentifier.validate();
        final String playId = membership.playStorePlanIdentifier.validate();
        final String activeId = isIOS ? appleId : playId;

        await setActiveSubscriptionIdentifier(activeId);
        await setActiveSubscriptionAppleIdentifier(appleId);
        await setActiveSubscriptionGoogleIdentifier(playId);
      }
    } catch (e, st) {
      log('applyMembershipToStore error: $e\n$st');
    }
  }

  //endregion

//region App setting
  @observable
  bool hasInFullScreen = false;

  @observable
  String selectedLanguageCode = defaultLanguage;

  @observable
  LanguageDataModel? selectedLanguageDataModel;

  @observable
  String currentLanguageName = '';

  @observable
  BaseLanguage? currentLanguage;

  @observable
  bool isLogging = false;

  @observable
  int bottomNavigationCurrentIndex = 0;

  @observable
  bool isLiveEnabled = false;

  @action
  Future<void> setEnableLiveStreaming(bool liveStreaming) async {
    isLiveEnabled = liveStreaming;
    await setValue(IS_LIVE_STREAMING_ENABLED, liveStreaming);
  }

  @action
  Future<void> setLogging(bool value) async {
    isLogging = value;
    await setValue(isLoggedIn, value);
  }

  @action
  Future<void> setToFullScreen(bool value) async {
    hasInFullScreen = value;
  }

  @action
  void setLoading(bool aIsLoading) {
    isLoading = aIsLoading;
  }

  @action
  void setPIPOn(bool value) {
    isPIPOn = value;
  }

  @action
  void setShowPIP(bool value) {
    showPIP = value;
  }

  @action
  Future<void> setLanguage(String val) async {
    print('setLanguage called with: $val');
    selectedLanguageCode = val;
    selectedLanguageDataModel = getSelectedLanguageModel();

    await setValue(SELECTED_LANGUAGE_CODE, selectedLanguageCode);

    language = await AppLocalizations().load(Locale(selectedLanguageCode));
    currentLanguage = language;
    currentLanguageName = language.language;

    print('Language loaded: ${language.language}');
    print('Current language name: $currentLanguageName');
    print('Current language object: ${currentLanguage?.language}');

    errorInternetNotAvailable = language.yourInterNetNotWorking;
    errorMessage = language.pleaseTryAgain;
    errorSomethingWentWrong = language.somethingWentWrong;
    errorThisFieldRequired = language.thisFieldIsRequired;
  }

  @action
  void setSelectedLanguageDataModel(LanguageDataModel? model) {
    selectedLanguageDataModel = model;
  }

  // Computed values for language management
  @computed
  List<LanguageDataModel> get availableLanguages {
    return languageList();
  }

  @computed
  String get currentLanguageDisplayName {
    return currentLanguageName.isNotEmpty ? currentLanguageName : (currentLanguage?.language ?? language.language);
  }

  @computed
  BaseLanguage get currentLanguageObject {
    return currentLanguage ?? language;
  }

  bool isLanguageSelected(String languageCode) {
    return selectedLanguageCode == languageCode;
  }

  @action
  void setBottomNavigationIndex(int val) {
    bottomNavigationCurrentIndex = val;
  }

//endregion

//region InApp Purchase
  @observable
  String filterType = FirebaseMsgConst.notificationTypeUnread;

  @observable
  String activeSubscriptionIdentifier = getStringAsync(SUBSCRIPTION_PLAN_IDENTIFIER);

  @observable
  String activeSubscriptionGoogleIdentifier = getStringAsync(SUBSCRIPTION_PLAN_GOOGLE_IDENTIFIER);

  @observable
  String activeSubscriptionAppleIdentifier = getStringAsync(SUBSCRIPTION_PLAN_APPLE_IDENTIFIER);

  Future<void> setActiveSubscriptionIdentifier(String value) async {
    activeSubscriptionIdentifier = value;
    setValue(SUBSCRIPTION_PLAN_IDENTIFIER, value);
  }

  Future<void> setActiveSubscriptionGoogleIdentifier(String value) async {
    activeSubscriptionGoogleIdentifier = value;
    setValue(SUBSCRIPTION_PLAN_GOOGLE_IDENTIFIER, value);
  }

  Future<void> setActiveSubscriptionAppleIdentifier(String value) async {
    activeSubscriptionAppleIdentifier = value;
    setValue(SUBSCRIPTION_PLAN_APPLE_IDENTIFIER, value);
  }

//endregion

//region Download State Management

  @observable
  Map<String, int> downloadProgress = <String, int>{};

  @observable
  Map<String, bool> downloadCompleted = <String, bool>{};

  @observable
  Map<String, bool> downloadFailed = <String, bool>{};

  @observable
  Map<String, String> downloadTaskIds = <String, String>{};

  @observable
  Map<String, DownloadData> downloadDataMap = <String, DownloadData>{};

  @action
  void setDownloadProgress(String videoId, int progress) {
    downloadProgress[videoId] = progress;
    downloadCompleted[videoId] = false;
    downloadFailed[videoId] = false;
  }

  @action
  void setDownloadCompleted(String videoId) {
    downloadCompleted[videoId] = true;
    downloadProgress.remove(videoId);
    downloadFailed[videoId] = false;
  }

  @action
  void setDownloadFailed(String videoId) {
    downloadFailed[videoId] = true;
    downloadProgress.remove(videoId);
    downloadCompleted[videoId] = false;
  }

  @action
  void setDownloadTaskId(String videoId, String taskId) {
    downloadTaskIds[videoId] = taskId;
  }

  @action
  void setDownloadData(String videoId, DownloadData data) {
    downloadDataMap[videoId] = data;
  }

  @action
  void clearDownloadProgress(String videoId) {
    downloadProgress.remove(videoId);
    downloadCompleted.remove(videoId);
    downloadFailed.remove(videoId);
    downloadTaskIds.remove(videoId);
    downloadDataMap.remove(videoId);
  }

  @action
  void resetDownloadState(String videoId) {
    downloadProgress.remove(videoId);
    downloadCompleted[videoId] = false;
    downloadFailed[videoId] = false;
  }

  // Helper methods for download state
  bool isVideoDownloading(String videoId) {
    return downloadProgress.containsKey(videoId) && downloadProgress[videoId] != null;
  }

  bool isDownloadCompleted(String videoId) {
    return downloadCompleted[videoId] == true;
  }

  bool isDownloadFailed(String videoId) {
    return downloadFailed[videoId] == true;
  }

  int? getDownloadProgress(String videoId) {
    return downloadProgress[videoId];
  }

  DownloadData? getDownloadData(String videoId) {
    return downloadDataMap[videoId];
  }

  String? getDownloadTaskId(String videoId) {
    return downloadTaskIds[videoId];
  }

//endregion

//region Movie Detail State Management

  @observable
  ObservableMap<String, bool> movieLikeStates = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> movieWatchlistStates = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, int> movieLikeCounts = ObservableMap<String, int>();

  @observable
  ObservableMap<String, bool> movieDetailDownloadStates = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> movieDetailDownloadFailedStates = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, bool> movieDetailDownloadCompletedStates = ObservableMap<String, bool>();

  @observable
  ObservableMap<String, int> movieDetailDownloadProgress = ObservableMap<String, int>();

  @observable
  ObservableMap<String, String> movieDetailDownloadTaskIds = ObservableMap<String, String>();

  @observable
  ObservableMap<String, DownloadData> movieDetailDownloadData = ObservableMap<String, DownloadData>();

  // Actions for movie like functionality
  @action
  void setMovieLikeState(String postId, bool isLiked) {
    movieLikeStates[postId] = isLiked;
  }

  @action
  void setMovieLikeCount(String postId, int count) {
    movieLikeCounts[postId] = count;
  }

  @action
  void toggleMovieLike(String postId) {
    bool currentState = movieLikeStates[postId] ?? false;
    int currentCount = movieLikeCounts[postId] ?? 0;

    movieLikeStates[postId] = !currentState;
    if (!currentState) {
      movieLikeCounts[postId] = currentCount + 1;
    } else {
      movieLikeCounts[postId] = currentCount - 1;
    }
  }

  @action
  void revertMovieLike(String postId) {
    bool currentState = movieLikeStates[postId] ?? false;
    int currentCount = movieLikeCounts[postId] ?? 0;

    movieLikeStates[postId] = !currentState;
    if (currentState) {
      movieLikeCounts[postId] = currentCount + 1;
    } else {
      movieLikeCounts[postId] = currentCount - 1;
    }
  }

  // Actions for movie watchlist functionality
  @action
  void setMovieWatchlistState(String postId, bool isInWatchlist) {
    movieWatchlistStates[postId] = isInWatchlist;
  }

  @action
  void toggleMovieWatchlist(String postId) {
    bool currentState = movieWatchlistStates[postId] ?? false;
    movieWatchlistStates[postId] = !currentState;
  }

  @action
  void revertMovieWatchlist(String postId) {
    bool currentState = movieWatchlistStates[postId] ?? false;
    movieWatchlistStates[postId] = !currentState;
  }

  // Actions for movie detail download functionality
  @action
  void setMovieDetailDownloadState(String postId, bool isDownloading) {
    movieDetailDownloadStates[postId] = isDownloading;
    if (isDownloading) {
      movieDetailDownloadFailedStates[postId] = false;
      movieDetailDownloadCompletedStates[postId] = false;
    }
  }

  @action
  void setMovieDetailDownloadProgress(String postId, int progress) {
    movieDetailDownloadProgress[postId] = progress;
  }

  @action
  void setMovieDetailDownloadCompleted(String postId) {
    movieDetailDownloadCompletedStates[postId] = true;
    movieDetailDownloadStates[postId] = false;
    movieDetailDownloadFailedStates[postId] = false;
    movieDetailDownloadProgress.remove(postId);
  }

  @action
  void setMovieDetailDownloadFailed(String postId) {
    movieDetailDownloadFailedStates[postId] = true;
    movieDetailDownloadStates[postId] = false;
    movieDetailDownloadCompletedStates[postId] = false;
    movieDetailDownloadProgress.remove(postId);
  }

  @action
  void setMovieDetailDownloadTaskId(String postId, String taskId) {
    movieDetailDownloadTaskIds[postId] = taskId;
  }

  @action
  void setMovieDetailDownloadData(String postId, DownloadData data) {
    movieDetailDownloadData[postId] = data;
  }

  @action
  void clearMovieDetailDownloadState(String postId) {
    movieDetailDownloadStates.remove(postId);
    movieDetailDownloadFailedStates.remove(postId);
    movieDetailDownloadCompletedStates.remove(postId);
    movieDetailDownloadProgress.remove(postId);
    movieDetailDownloadTaskIds.remove(postId);
    movieDetailDownloadData.remove(postId);
  }

  @action
  void resetMovieDetailDownloadState(String postId) {
    movieDetailDownloadStates[postId] = false;
    movieDetailDownloadFailedStates[postId] = false;
    movieDetailDownloadCompletedStates[postId] = false;
    movieDetailDownloadProgress.remove(postId);
  }

  // Helper methods for movie detail state
  bool isMovieLiked(String postId) {
    return movieLikeStates[postId] ?? false;
  }

  bool isMovieInWatchlist(String postId) {
    return movieWatchlistStates[postId] ?? false;
  }

  int getMovieLikeCount(String postId) {
    return movieLikeCounts[postId] ?? 0;
  }

  bool isMovieDetailDownloading(String postId) {
    return movieDetailDownloadStates[postId] ?? false;
  }

  bool isMovieDetailDownloadCompleted(String postId) {
    return movieDetailDownloadCompletedStates[postId] ?? false;
  }

  bool isMovieDetailDownloadFailed(String postId) {
    return movieDetailDownloadFailedStates[postId] ?? false;
  }

  int? getMovieDetailDownloadProgress(String postId) {
    return movieDetailDownloadProgress[postId];
  }

  DownloadData? getMovieDetailDownloadData(String postId) {
    return movieDetailDownloadData[postId];
  }

  String? getMovieDetailDownloadTaskId(String postId) {
    return movieDetailDownloadTaskIds[postId];
  }

//endregion

//region Onboarding State

  @observable
  int currentOnboardingPageIndex = 0;

  @action
  void setCurrentOnboardingPageIndex(int index) {
    currentOnboardingPageIndex = index;
  }

  @observable
  ObservableList<Widget> onboardingWidgets = ObservableList<Widget>();

  @action
  void setOnboardingWidgets(List<Widget> widgets) {
    onboardingWidgets
      ..clear()
      ..addAll(widgets);
  }

//endregion

//region Dashboard Slider State

  @observable
  int dashboardCurrentPage = 0;

  @observable
  bool dashboardShowVideo = false;

  @observable
  ObservableList<CommonDataListModel> dashboardSliderList = ObservableList<CommonDataListModel>();

  @observable
  bool dashboardAutoPlay = true;

  @observable
  bool dashboardIsVideoLoading = false;

  @action
  void setDashboardCurrentPage(int page) {
    dashboardCurrentPage = page;
  }

  @action
  void setDashboardShowVideo(bool show) {
    dashboardShowVideo = show;
  }

  @action
  void setDashboardSliderList(List<CommonDataListModel> sliders) {
    dashboardSliderList
      ..clear()
      ..addAll(sliders);
  }

  @action
  void setDashboardAutoPlay(bool autoPlay) {
    dashboardAutoPlay = autoPlay;
  }

  @action
  void setDashboardVideoLoading(bool loading) {
    dashboardIsVideoLoading = loading;
  }

  @action
  void resetDashboardVideoState() {
    dashboardShowVideo = false;
    dashboardIsVideoLoading = false;
  }

  @action
  void nextDashboardPage() {
    if (dashboardSliderList.isNotEmpty) {
      dashboardCurrentPage = (dashboardCurrentPage + 1) % dashboardSliderList.length;
    }
  }

  @action
  void refreshDashboardSlider() {
    // This action can be used to trigger UI refresh when returning from detail screens
    // The Observer will automatically rebuild when any observable changes
  }

//endregion

//region View All Movies State Management

  @observable
  ObservableList<CommonDataListModel> viewAllMoviesList = ObservableList<CommonDataListModel>();

  @observable
  int viewAllMoviesPage = 1;

  @observable
  bool viewAllMoviesIsLastPage = false;

  @observable
  bool viewAllMoviesIsLoading = false;

  @observable
  bool viewAllMoviesHasError = false;

  @observable
  String viewAllMoviesTitle = '';

  @observable
  String? viewAllMoviesError;

  @action
  void setViewAllMoviesPage(int page) => viewAllMoviesPage = page;

  @action
  void setViewAllMoviesIsLastPage(bool isLastPage) => viewAllMoviesIsLastPage = isLastPage;

  @action
  void setViewAllMoviesIsLoading(bool loading) => viewAllMoviesIsLoading = loading;

  @action
  void setViewAllMoviesHasError(bool hasError) => viewAllMoviesHasError = hasError;

  @action
  void setViewAllMoviesTitle(String title) => viewAllMoviesTitle = title;

  @action
  void setViewAllMoviesError(String? error) => viewAllMoviesError = error;

  @action
  void setViewAllMoviesList(List<CommonDataListModel> list, {bool isRefresh = false}) {
    if (isRefresh) viewAllMoviesList.clear();
    viewAllMoviesList.addAll(list);
  }

  @action
  void clearViewAllMoviesList() => viewAllMoviesList.clear();

  @action
  void resetViewAllMoviesState() {
    viewAllMoviesPage = 1;
    viewAllMoviesIsLastPage = false;
    viewAllMoviesIsLoading = false;
    viewAllMoviesHasError = false;
    viewAllMoviesError = null;
    viewAllMoviesList.clear();
  }

  @action
  void incrementViewAllMoviesPage() {
    if (!viewAllMoviesIsLastPage) {
      setViewAllMoviesPage(viewAllMoviesPage + 1);
    }
  }

  // Computed properties for view all movies
  @computed
  bool get canLoadMoreViewAllMovies => !viewAllMoviesIsLastPage && !viewAllMoviesIsLoading;

  @computed
  bool get hasViewAllMoviesData => viewAllMoviesList.isNotEmpty;

  @computed
  bool get hasViewAllMoviesError => viewAllMoviesHasError;

  @computed
  String? get viewAllMoviesErrorMessage => viewAllMoviesError;

  @computed
  int get viewAllMoviesDataCount => viewAllMoviesList.length;

//endregion

//region Cast Device State Management

  @observable
  CastDevice? castDevice;

  @observable
  CastSession? castSession;

  @observable
  bool isCastConnecting = false;

  @observable
  bool isCastConnected = false;

  @observable
  bool isCastDisconnecting = false;

  @observable
  String? castConnectionError;

  @observable
  ObservableList<CastDevice> availableCastDevices = ObservableList<CastDevice>();

  @observable
  bool isSearchingCastDevices = false;

  @observable
  String? castSearchError;

  // Cast device actions
  @action
  void setCastDevice(CastDevice? device) => castDevice = device;

  @action
  void setCastSession(CastSession? session) => castSession = session;

  @action
  void setCastConnecting(bool connecting) => isCastConnecting = connecting;

  @action
  void setCastConnected(bool connected) => isCastConnected = connected;

  @action
  void setCastDisconnecting(bool disconnecting) => isCastDisconnecting = disconnecting;

  @action
  void setCastConnectionError(String? error) => castConnectionError = error;

  @action
  void setAvailableCastDevices(List<CastDevice> devices) {
    availableCastDevices.clear();
    availableCastDevices.addAll(devices);
  }

  @action
  void setSearchingCastDevices(bool searching) => isSearchingCastDevices = searching;

  @action
  void setCastSearchError(String? error) => castSearchError = error;

  @action
  void clearCastDevices() => availableCastDevices.clear();

  @action
  void resetCastState() {
    castDevice = null;
    castSession = null;
    isCastConnecting = false;
    isCastConnected = false;
    isCastDisconnecting = false;
    castConnectionError = null;
    availableCastDevices.clear();
    isSearchingCastDevices = false;
    castSearchError = null;
  }

  // Computed properties for cast state
  @computed
  bool get hasCastDevice => castDevice != null;

  @computed
  bool get isCastSessionActive => castSession != null;

  @computed
  bool get hasAvailableCastDevices => availableCastDevices.isNotEmpty;

  @computed
  bool get hasCastError => castConnectionError != null || castSearchError != null;

  @computed
  String? get castErrorMessage => castConnectionError ?? castSearchError;

  @computed
  bool get canConnectToCast => hasAvailableCastDevices && !isCastConnecting && !isCastConnected;

  @computed
  bool get canDisconnectFromCast => isCastConnected && !isCastDisconnecting;

//endregion
}
