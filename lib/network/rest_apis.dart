import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/auth/check_user_session_response.dart';
import 'package:streamit_flutter/models/auth/edit_profile_response.dart';
import 'package:streamit_flutter/models/auth/login_response.dart';
import 'package:streamit_flutter/models/auth/nonce_model.dart';
import 'package:streamit_flutter/models/blog/wp_comments_model.dart';
import 'package:streamit_flutter/models/blog/wp_post_response.dart';
import 'package:streamit_flutter/models/common/base_response.dart';
import 'package:streamit_flutter/models/dashboard_response.dart';
import 'package:streamit_flutter/models/genre_data.dart';
import 'package:streamit_flutter/models/live_tv/epg_data_model.dart';
import 'package:streamit_flutter/models/live_tv/live_category_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/cast_model.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/models/movie_episode/movie_detail_response.dart';
import 'package:streamit_flutter/models/movie_episode/rate_review_model.dart';
import 'package:streamit_flutter/models/movie_episode/season_detail_model.dart';
import 'package:streamit_flutter/models/notification_model.dart';
import 'package:streamit_flutter/models/notification_reminder_list_model.dart';
import 'package:streamit_flutter/models/onboarding_list_model.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/models/pmp_models/pay_per_view_orders_model.dart';
import 'package:streamit_flutter/models/pmp_models/pmp_order_model.dart';
import 'package:streamit_flutter/models/settings/core_settings_model.dart';
import 'package:streamit_flutter/models/settings/devices_model.dart';
import 'package:streamit_flutter/models/settings/settings_model.dart';
import 'package:streamit_flutter/models/view_all_response.dart';
import 'package:streamit_flutter/models/watchlist_response.dart';
import 'package:streamit_flutter/models/woo_commerce/order_model.dart';
import 'package:streamit_flutter/models/woo_commerce/product_model.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/push_notification_service.dart';

import '../models/live_tv/live_channel_detail_model.dart';
import '../screens/home_screen.dart';
import '../utils/cached_data.dart';
import 'network_utils.dart';

//region Auth & User Management
Future<LoginResponse> token(Map request) async {
  PushNotificationService().registerFCMAndTopics();
  LoginResponse res = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.login, body: request, aAuthRequired: false, method: HttpMethod.POST)));

  await clearGuestDownloads();
  await setUserData(logRes: res);

  await setValue(isLoggedIn, true);
  mIsLoggedIn = true;
  manageFirebaseToken();

  PushNotificationService().registerFCMAndTopics();
  if (coreStore.isInAppPurchaseEnabled) await InAppPurchaseService.init();
  return res;
}

Future<LoginResponse> socialLogin(Map request) async {
  PushNotificationService().registerFCMAndTopics();
  final response = await handleResponse(await buildHttpResponse(APIEndPoint.socialLogin, body: request, aAuthRequired: false, method: HttpMethod.POST));

  Map<String, dynamic> responseData;
  if (response is Map<String, dynamic>) {
    responseData = (response['data'] ?? response['user'] ?? response) as Map<String, dynamic>;
    if (response['user_id'] != null) {
      responseData['user_id'] = response['user_id'];
    }
  } else {
    responseData = {'data': response};
  }

  final login = LoginResponse.fromJson(responseData);

  login.userEmail ??= request['email']?.toString();
  login.firstName ??= request['first_name']?.toString();
  login.lastName ??= request['last_name']?.toString();
  login.profileImage ??= request['avatar_url']?.toString();
  login.loginType ??= request['login_type']?.toString();
  login.username ??= login.userEmail?.split('@').first;

  await clearGuestDownloads();
  await setUserData(logRes: login);
  await setValue(isLoggedIn, true);
  mIsLoggedIn = true;
  manageFirebaseToken();
  if (coreStore.isInAppPurchaseEnabled) await InAppPurchaseService.init();

  return login;
}

Future<void> manageFirebaseToken() async {
  Map<String, dynamic> req = {FirebaseMsgConst.firebaseToken: getStringAsync(FIREBASE_TOKEN)};
  log("Firebase token------------token-------${getStringAsync(FIREBASE_TOKEN)}");
  await handleResponse(await buildHttpResponse(APIEndPoint.manageFirebaseToken, method: HttpMethod.POST, body: req)).onError((error, stackTrace) {
    log('Manage-Firebase-Token-Error ${error.toString()}');
  });
}

Future<void> logout({bool logoutFromAll = false, bool isNewTask = false, BuildContext? context}) async {
  appStore.setLoading(true);
  if (await isNetworkAvailable()) {
    if (getStringAsync(COOKIE_HEADER).isNotEmpty) {
      await logOut().then((value) async {
        toast(language.youHaveBeenLoggedOutSuccessfully);
      });
    }
    await PushNotificationService().unsubscribeFirebaseTopic();
    removeKey(COOKIE_HEADER);
    removeKey(FIREBASE_TOKEN);
    removeKey(HAS_IN_APP_SDK_INITIALISE_AT_LEASE_ONCE);
    removeKey(SharePreferencesKey.LOGIN_EMAIL);
    removeKey(SharePreferencesKey.LOGIN_PASSWORD);
    removeKey(PASSWORD);
    removeKey(USER_EMAIL);

    appStore.setFirstName('');
    appStore.setLastName('');
    appStore.setUserProfile('');
    appStore.setLoginDevice('');
    appStore.setUserId(null);
    appStore.setUserName('');
    appStore.setUserEmail('');

    appStore.setSubscriptionPlanId("");
    appStore.setSubscriptionPlanStartDate("");
    appStore.setSubscriptionPlanExpDate("");
    appStore.setSubscriptionPlanStatus("");
    appStore.setSubscriptionPlanName("");
    appStore.setSubscriptionPlanAmount("");
    appStore.setSubscriptionTrialPlanStatus("");
    appStore.setSubscriptionTrialPlanEndDate("");
    appStore.setActiveSubscriptionIdentifier('');
    appStore.setActiveSubscriptionGoogleIdentifier('');
    appStore.setActiveSubscriptionAppleIdentifier('');

    setValue(isFirstTime, false);
    setValue(isLoggedIn, false);
    mIsLoggedIn = false;

    appStore.setLogging(false);
    appStore.setLoading(false);

    if (isNewTask) {
      appStore.setBottomNavigationIndex(0);
      HomeScreen().launch(context ?? getContext, isNewTask: true);
    }

    if (isIOS) {
      await getApplicationDocumentsDirectory().then((value) async {
        if (value.existsSync()) {
          value.deleteSync(recursive: true);
          await removeKey(DOWNLOADED_DATA);
        }
      });
    } else {
      await getDownloadsDirectory().then((value) async {
        if (value != null && value.existsSync()) {
          value.deleteSync(recursive: true);
          await removeKey(DOWNLOADED_DATA);
        }
      });
    }

    appStore.downloadedItemList.clear();
    coreStore.clear();
  } else {
    toast(errorInternetNotAvailable);
  }
}

Future<CheckUserSessionResponse> checkUserSession() async {
  final response = await buildHttpResponse(APIEndPoint.checkUser, method: HttpMethod.GET);

  if (!response.statusCode.isSuccessful()) {
    throw errorSomethingWentWrong;
  }

  final dynamic decoded = jsonDecode(response.body);

  if (decoded is Map<String, dynamic>) {
    return CheckUserSessionResponse.fromJson(decoded);
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<BaseResponseModel> forgotPassword(Map request) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.forgotPassword, body: request, aAuthRequired: false, method: HttpMethod.POST))));
}

Future register(Map request) async {
  return await handleResponse(await buildHttpResponse(APIEndPoint.registration, body: request, aAuthRequired: false, method: HttpMethod.POST));
}

Future<BaseResponseModel> changePassword(Map request) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.changePassword, body: request, method: HttpMethod.POST))));
}

Future<void> updateProfile({required String firstName, required String lastName, String? email, XFile? image}) async {
  if (await isNetworkAvailable()) {
    appStore.setLoading(true);
    var multiPartRequest = await postMultiPartRequest(APIEndPoint.profile);
    multiPartRequest.fields['first_name'] = firstName;
    multiPartRequest.fields['last_name'] = lastName;
    multiPartRequest.fields['email'] = email.validate();
    if (image != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', image.path));

    multiPartRequest.headers.addAll(await buildTokenHeader());

    log(multiPartRequest.fields.toString());

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        toast(language.profileHasBeenUpdatedSuccessfully);
        Map<String, dynamic> res = jsonDecode(data);
        log(res);
        if (res['status']) {
          EditProfileResponse profile = EditProfileResponse.fromJson(res['data']);

          appStore.setFirstName(profile.firstName);
          appStore.setLastName(profile.lastName);
          appStore.setUserEmail(profile.userEmail);

          if (profile.profileImage != null && profile.profileImage.validate().isNotEmpty) {
            appStore.setUserProfile(profile.profileImage);
          }
        } else {
          toast(res['message']);
        }

        appStore.setLoading(false);
      },
      onError: (error) {
        appStore.setLoading(false);
        log('error: ${error.toString()}');
      },
    );
  }
}

Future<void> addDevices(Map request) async {
  return await (handleResponse(await buildHttpResponse(APIEndPoint.devices, body: request, method: HttpMethod.POST)));
}

Future<DeviceModel> getDevices({Map? request}) async {
  return DeviceModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.devices, body: request, method: HttpMethod.POST), isGenre: true)));
}

Future<void> deleteDevice(Map request) async {
  return await handleResponse(await buildHttpResponse(APIEndPoint.removeDevices, body: request, method: HttpMethod.DELETE));
}

Future<void> logOut() async {
  return await handleResponse(await buildHttpResponse(APIEndPoint.logout, method: HttpMethod.POST));
}

Future<void> deleteUserAccount() async {
  await handleResponse(await buildHttpResponse(APIEndPoint.deleteAccount, aAuthRequired: true, method: HttpMethod.DELETE));
}

Future<NonceModel> getNonce({required String type}) async {
  return NonceModel.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.authNonce}?nonce_for=$type', method: HttpMethod.POST))));
}
//endregion

//region General App Settings
Future<SettingsModel> getSettings() async {
  SettingsModel value = SettingsModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.settings)));
  await appStore.setEnableLiveStreaming(value.isLiveEnabled ?? false);
  if (value.appLogo.validate().isNotEmpty) {
    await appStore.setAppLogo(value.appLogo);
  }
  await appStore.setBannerDefaultImage(value.bannerDefaultImage);
  await appStore.setPersonDefaultImage(value.personDefaultImage);
  await appStore.setSliderDefaultImage(value.sliderDefaultImage);

  return value;
}

Future<CoreSettingsResponse> getCoreSettings() async {
  final response = await handleResponse(
    await buildHttpResponse(APIEndPoint.coreSettings),
    isGenre: true,
  );

  if (response is Map<String, dynamic>) {
    return CoreSettingsResponse.fromJson(response);
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<OnBoardingListModel> getOnboardingList() async {
  try {
    final response = await handleResponse(
      await buildHttpResponse(APIEndPoint.onBoarding, method: HttpMethod.GET),
    );

    if (response is List) {
      // Wrap list into expected model format
      return OnBoardingListModel.fromJson({
        'status': true,
        'message': 'success',
        'data': response,
      });
    } else if (response is Map<String, dynamic>) {
      return OnBoardingListModel.fromJson(response);
    } else {
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }
  } catch (e) {
    log('Error fetching onboarding data: ${e.toString()}');
    return OnBoardingListModel(
      status: false,
      message: 'Failed to fetch onboarding data',
      data: [],
    );
  }
}

//endregion

//region Dashboard, Search & Discovery
Future<DashboardResponse> getDashboardData(Map request, {String type = dashboardTypeHome}) async {
  var res = DashboardResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoint.dashboard}/$type',
      body: request,
      aAuthRequired: appStore.isLogging ? true : false,
    ),
  ));

  return res;
}

Future<List<CommonDataListModel>> searchMovie(String aSearchText, {int page = 1, required List<CommonDataListModel> movies, bool isLoading = true}) async {
  appStore.setLoading(isLoading);

  try {
    String encodedSearchText = Uri.encodeComponent(aSearchText);
    String searchUrl = '${APIEndPoint.search}?search=$encodedSearchText&user_id=${appStore.userId}&paged=$page&posts_per_page=$postPerPage';

    Iterable it = await (handleResponse(await buildHttpResponse(searchUrl)));

    if (page == 1) movies.clear();

    if (it.validate().isNotEmpty) {
      movies.addAll(it.map((e) => CommonDataListModel.fromJson(e)).toList());
    }
  } catch (e) {
    throw e;
  } finally {
    appStore.setLoading(false);
  }

  return movies;
}

Future<List<RecentSearchListModel>> recentListFetch({int page = 1, required List<RecentSearchListModel> recentList, bool isLoading = true}) async {
  appStore.setLoading(isLoading);

  try {
    Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.recentSearchList}?user_id=${appStore.userId}')));

    if (page == 1) recentList.clear();

    if (it.validate().isNotEmpty) {
      recentList.addAll(it.map((e) => RecentSearchListModel.fromJson(e)).toList());
    }
  } catch (e) {
    throw e;
  } finally {
    appStore.setLoading(false);
  }

  return recentList;
}

Future<BaseResponseModel> addRecent(String title) async {
  try {
    final response = await handleResponse(await buildHttpResponse('${APIEndPoint.recentSearchAdd}?search=$title', method: HttpMethod.POST));

    if (response is List) {
      return BaseResponseModel.fromJson({
        'status': true,
        'message': 'Search added successfully',
        'data': response,
      });
    } else if (response is Map<String, dynamic>) {
      return BaseResponseModel.fromJson(response);
    } else {
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }
  } catch (e) {
    return BaseResponseModel(
      success: false,
      message: 'Failed to add recent search',
    );
  }
}

Future<BaseResponseModel> removeRecent(int id) async {
  try {
    final response = await handleResponse(await buildHttpResponse('${APIEndPoint.recentSearchRemove}?id=$id', method: HttpMethod.POST));

    if (response is Map<String, dynamic>) {
      return BaseResponseModel.fromJson(response);
    } else if (response is List) {
      return BaseResponseModel.fromJson({'status': true, 'message': 'Removed successfully', 'data': response});
    } else {
      return BaseResponseModel(success: true, message: 'Removed successfully');
    }
  } catch (e) {
    return BaseResponseModel(success: false, message: 'Failed to remove recent');
  }
}

Future<ViewAllResponse> viewAll(int index, String type, {int page = 1, List<dynamic>? list = const [], PostType postType = PostType.MOVIE}) async {
  final queryParams = {'post_type': postType.name.toLowerCase(), 'filter': type, 'paged': page.toString(), 'posts_per_page': postPerPage.toString()};

  if (list != null && list.isNotEmpty) {
    queryParams[type] = list.join(',');
  }

  final uri = Uri.parse(APIEndPoint.viewAll).replace(queryParameters: queryParams);
  final rawResponse = await buildHttpResponse(uri.toString());

  final response = await handleResponse(rawResponse, responseType: ResponseType.FULL_RESPONSE);
  final responseBody = json.decode(response.body);

  if (responseBody is Map<String, dynamic>) {
    return ViewAllResponse.fromJson(responseBody);
  } else if (responseBody is List) {
    throw Exception("Unexpected list response: Expected a JSON object.");
  } else {
    throw Exception("Invalid response structure.");
  }
}

Future<List<GenreData>> getGenreList({
  int? page = 1,
  String? type = dashboardTypeMovie,
  required List<GenreData> genreDataList,
  Function(bool)? lastPageCallback,
  bool isLast = false,
}) async {
  try {
    GenreResponse genreResponse = GenreResponse.fromJson(await handleResponse(
      await buildHttpResponse('${APIEndPoint.genre}/$type/genre?paged=$page&posts_per_page=16'),
      isGenre: true,
    ));

    if (page == 1) genreDataList.clear();

    lastPageCallback?.call(genreResponse.genreDataList.validate().length != postPerPage);
    genreDataList.addAll(genreResponse.genreDataList.validate());

    if (page == 1) {
      GenreCachedData.storeData(genreTypeKey: type.validate(), data: genreDataList.map((e) => e.toJson()).toList());
    }
    appStore.setLoading(false);
    return genreDataList;
  } catch (e) {
    appStore.setLoading(false);
    log(e.toString());
    toast(e.toString());
    return [];
  }
}

Future<List<CommonDataListModel>> getMovieListByGenre(String genre, String type, int page) async {
  Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.genre}/$type/genre/$genre?paged=$page&posts_per_page=$postPerPage')));
  return it.map((e) => CommonDataListModel.fromJson(e)).toList();
}
//endregion

//region Content Details
Future<MovieDetailResponse> movieDetail(int aId) async {
  final response = await handleResponse(await buildHttpResponse('${APIEndPoint.movieDetails}/$aId'));
  final details = response['details'];
  final adConfig = response['ad_configuration'];
  final continueWatch = response['continue_watch'];
  if (details is Map<String, dynamic>) {
    details['ad_configuration'] = adConfig;
    if (continueWatch != null) {
      details['continue_watch'] = continueWatch;
    }
  }
  return MovieDetailResponse.fromJson({
    'details': details,
    'recommended_movies': response['recommended_movies'],
    'upcoming_movies': response['upcoming_movies'],
    'upcoming_videos': response['upcoming_videos'],
    'related_videos': response['related_videos'],
    'related_movies': response['related_movies'],
  });
}

Future<MovieDetailResponse> tvShowDetail(int aId) async {
  final response = await handleResponse(await buildHttpResponse('${APIEndPoint.tvShowDetails}/$aId'));
  final details = response['details'];
  final adConfig = response['ad_configuration'];
  final continueWatch = response['continue_watch'];
  if (details is Map<String, dynamic>) {
    details['ad_configuration'] = adConfig;
    if (continueWatch != null) {
      details['continue_watch'] = continueWatch;
    }
  }
  return MovieDetailResponse.fromJson({
    'details': details,
    'recommended_movies': response['recommended_movies'],
    'upcoming_movies': response['upcoming_movies'],
    'upcoming_videos': response['upcoming_videos'],
  });
}

Future<Season> tvShowSeasonDetail({required int showId, required int seasonId, int page = 1}) async {
  final response = await handleResponse(await buildHttpResponse('${APIEndPoint.tvShowDetails}/$showId/seasons/$seasonId?page=$page&posts_per_page=$postPerPage'));
  if (response is Map<String, dynamic> && response.containsKey('data')) {
    final data = response['data'];
    if (data is List && data.isEmpty) {
      return Season(episodes: []);
    } else if (data is Map<String, dynamic>) {
      return Season.fromJson(data);
    }
  } else if (response is List && response.isEmpty) {
    return Season(episodes: []);
  }
  return Season.fromJson(response as Map<String, dynamic>);
}

Future<MovieData> getEpisodeDetail(int? aId) async {
  final httpResponse = await buildHttpResponse('${APIEndPoint.episodeDetails}/$aId?user_id=${appStore.userId}');
  final fullResponse = jsonDecode(httpResponse.body);
  final adConfig = fullResponse['ad_configuration'];
  final response = await handleResponse(httpResponse);
  final details = Map<String, dynamic>.from(response);
  details['ad_configuration'] = adConfig;
  return MovieData.fromJson(details);
}

Future<MovieDetailResponse> getVideosDetail(int id) async {
  final response = await handleResponse(await buildHttpResponse('${APIEndPoint.videoDetails}/$id'));
  final details = response['details'];
  final adConfig = response['ad_configuration'];
  final continueWatch = response['continue_watch'];
  if (details is Map<String, dynamic>) {
    details['ad_configuration'] = adConfig;
    if (continueWatch != null) {
      details['continue_watch'] = continueWatch;
    }
  }
  return MovieDetailResponse.fromJson({
    'details': details,
    'recommended_movies': response['recommended_movies'],
    'upcoming_movies': response['upcoming_movies'],
    'upcoming_videos': response['upcoming_videos'],
  });
}

Future<CastModel> getCastDetails(String castId) async {
  return CastModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.personDetails}/$castId')));
}

//endregion

//region User Interaction (Likes, Watchlist, History)
Future<LikeAndWatchListResponse> likeMovie(Map request) async {
  return LikeAndWatchListResponse.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.like, body: request, method: HttpMethod.POST))));
}

Future<List<CommonDataListModel>> getWatchList({int page = 1, String? postType}) async {
  List<String> params = [];
  params.add('posts_per_page=$postPerPage');
  params.add('page=$page');
  if (postType != null && postType.isNotEmpty) {
    params.add('post_type=$postType');
  }

  Iterable it = await (handleResponse(await buildHttpResponse('${APIEndPoint.watchlist}?${params.join('&')}', aAuthRequired: true)));

  return it.map((e) => CommonDataListModel.fromJson(e)).toList();
}

Future<List<CommonDataListModel>> getLikedContent({required String postType, int page = 1, int perPage = postPerPage}) async {
  List<String> params = [];
  params.add('post_type=$postType');
  params.add('page=$page');
  params.add('per_page=$perPage');

  final response = await handleResponse(
    await buildHttpResponse('${APIEndPoint.likedContent}?${params.join('&')}', aAuthRequired: true),
  );

  if (response is Map<String, dynamic>) {
    final data = response['data'];
    if (data is List) {
      return data.map((e) => CommonDataListModel.fromJson(e)).toList();
    }
  } else if (response is List) {
    return response.map((e) => CommonDataListModel.fromJson(e)).toList();
  }

  return [];
}

Future<LikeAndWatchListResponse> watchlistMovie(Map request) async {
  return LikeAndWatchListResponse.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.watchlist, body: request, method: HttpMethod.POST))));
}

Future<void> saveVideoContinueWatch({
  required int postId,
  required int watchedTime,
  required int watchedTotalTime,
  required PostType postType,
}) async {
  Map request = {
    "post_id": postId,
    "watched_time": watchedTime,
    "watched_total_time": watchedTotalTime,
    'post_type': postType.name.toLowerCase(),
  };
  await handleResponse(
    await buildHttpResponse(
      APIEndPoint.continueWatch,
      body: request,
      aAuthRequired: true,
      method: HttpMethod.POST,
    ),
  );
}

Future<List<CommonDataListModel>> getVideoContinueWatch({
  int? page = 1,
  String type = '',
  required List<CommonDataListModel> continueWatchList,
  Function(bool)? lastPageCallback,
}) async {
  List<String> params = [];
  params.add('page=${page}');
  params.add('per_page=${postPerPage}');
  if (type.isNotEmpty) params.add('post_type=${type}');

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.continueWatch}?${params.join('&')}', aAuthRequired: true));

  if (page == 1) continueWatchList.clear();

  lastPageCallback?.call(it.length < postPerPage);
  continueWatchList.addAll(it.map((e) => CommonDataListModel.fromJson(e)).toList());

  return continueWatchList;
}

Future<void> deleteVideoContinueWatch({required int postId, required PostType postType}) async {
  Map request = {"post_id": postId, 'post_type': postType.name.toLowerCase()};
  await handleResponse(await buildHttpResponse(APIEndPoint.continueWatch, body: request, aAuthRequired: true, method: HttpMethod.DELETE));
}
//endregion

//region Rate & Reviews
Future<RateReviewModel> getRateReviews({required String postType, required int postId, ReviewFilter filter = ReviewFilter.all}) async {
  String url = '${APIEndPoint.rate}/$postType/$postId';

  final filterQuery = filter.apiValue;

  if (filterQuery != null) {
    url += '?filter=$filterQuery';
  }

  final response = await handleResponse(
    await buildHttpResponse(url, method: HttpMethod.GET),
  );

  return RateReviewModel.fromJson({'status': true, 'message': 'Success', 'data': response});
}

Future<BaseResponseModel> addReview(Map request, String type, {String? method = ''}) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse('${APIEndPoint.rate}/$type', body: request, method: method == 'delete' ? HttpMethod.DELETE : HttpMethod.POST))));
}
//endregion

//region Playlist
Future<BaseResponseModel> createOrEditPlaylist({required Map request, String type = playlistMovie}) async {
  log('Request : $request');

  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.playlist}/$type', body: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> deletePlaylist({required Map request, String type = playlistMovie}) async {
  log('request : $request');

  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.playlist}/$type', body: request, method: HttpMethod.DELETE)));
}

// add and delete edit items to playlist
Future<BaseResponseModel> editPlaylistItems({required Map request, String type = playlistMovie, required int playListId, required isDelete}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(
    '${APIEndPoint.playlist}/$type/$playListId',
    body: request,
    method: isDelete ? HttpMethod.DELETE : HttpMethod.POST,
  )));
}

Future<List<PlaylistModel>> getPlayListByType({String type = playlistMovie, int? postId}) async {
  Response response = await buildHttpResponse(
    '${APIEndPoint.playlist}/$type${postId != null ? '?post_id=$postId' : ''}',
    aAuthRequired: true,
  );

  // Check if the response is a list or a map
  final jsonData = jsonDecode(response.body);

  if (jsonData is List) {
    return jsonData.map((item) => PlaylistModel.fromJson(item)).toList();
  } else if (jsonData is Map<String, dynamic>) {
    PlaylistResp playList = PlaylistResp.fromJson(jsonData);
    return playList.data;
  } else {
    throw Exception('Unexpected response format');
  }
}

Future<List<CommonDataListModel>> getPlayListMedia({
  required int playlistId,
  required String postType,
  int page = 1,
}) async {
  final response = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoint.playlist}/$postType/$playlistId?posts_per_page=7&page=$page',
      aAuthRequired: true,
    ),
  );

  // Handle null or non-iterable responses gracefully
  if (response == null) {
    return <CommonDataListModel>[]; // Return an empty list if the response is null
  }

  try {
    // Ensure the response is an iterable or handle unexpected formats
    Iterable it = response as Iterable? ?? [];
    return it.map((e) => CommonDataListModel.fromJson(e)).toList();
  } catch (error) {
    return <CommonDataListModel>[]; // Return an empty list on parsing failure
  }
}
//endregion

//region Membership (PMP)
Future<MembershipModel?> getMembershipLevelForUser({required int userId}) async {
  final raw = await buildHttpResponse('${MembershipAPIEndPoint.getMembershipLevelForUser}?user_id=$userId', aAuthRequired: true);
  final value = await handleResponse(raw);

  if (value == false) {
    return null;
  }

  // value is already Map<String, dynamic> per your debug
  final Map<String, dynamic> membershipMap = Map<String, dynamic>.from(value as Map);

  final MembershipModel membership = MembershipModel.fromJson(membershipMap);

  // update appStore (kept your logic, simplified slightly)
  appStore.setSubscriptionPlanStatus(userPlanStatus);
  appStore.setSubscriptionPlanName(membership.name.validate());
  appStore.setSubscriptionPlanId(membership.id.validate());
  appStore.setSubscriptionPlanStartDate(membership.startdate.validate());
  appStore.setSubscriptionPlanAmount(membership.billingAmount?.toString() ?? '');

  if (membership.enddate != null && membership.enddate! > 0) {
    final expiry = DateTime.fromMillisecondsSinceEpoch(membership.enddate! * 1000);
    appStore.setSubscriptionPlanExpDate(DateFormat(dateFormatPmp).format(expiry));
  }

  if (coreStore.isInAppPurchaseEnabled) {
    appStore.setActiveSubscriptionIdentifier(
      isIOS ? membership.appStorePlanIdentifier.validate() : membership.playStorePlanIdentifier.validate(),
    );
    appStore.setActiveSubscriptionAppleIdentifier(membership.appStorePlanIdentifier.validate());
    appStore.setActiveSubscriptionGoogleIdentifier(membership.playStorePlanIdentifier.validate());
  }

  // RETURN the model (not the raw map)
  return membership;
}

Future<List<MembershipModel>> getLevelsList({int? postId, int? page, int? commentPerPage}) async {
  Iterable it = await (handleResponse(await buildHttpResponse(MembershipAPIEndPoint.membershipLevels, aAuthRequired: true)));
  return it.map((e) => MembershipModel.fromJson(e)).toList();
}

Future<List<PmpOrderModel>> pmpOrders({int page = 1}) async {
  Iterable it = await (handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.membershipOrders}?page=$page&per_page=20', aAuthRequired: true)));
  return it.map((e) => PmpOrderModel.fromJson(e)).toList();
}

Future<PayPerViewOrdersModel> getPpvOrders({int page = 1}) async {
  final response = await buildHttpResponse('${MembershipAPIEndPoint.payPerViewOrders}?page=$page&per_page=$postPerPage', aAuthRequired: true);
  final fullResponse = await handleResponse(response, responseType: ResponseType.FULL_RESPONSE);
  return PayPerViewOrdersModel.fromJson(json.decode(fullResponse.body));
}

Future<void> cancelMembershipLevel({String? levelId}) async {
  String level = levelId == null ? "" : "&level_id=$levelId";
  await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.cancelMembershipLevel}?user_id=${appStore.userId}$level', method: HttpMethod.POST));
}

Future<PmpOrderModel> generateInAppOrder(Map request) async {
  return PmpOrderModel.fromJson(await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.membershipOrders}', body: request, method: HttpMethod.POST)));
}
//endregion

//region E-commerce (WooCommerce)
Future<ProductModel> productDetail({required int productID}) async {
  return ProductModel.fromJson(await (handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.wcProducts}/$productID', isForWoocommerce: true, requiredNonce: true, aAuthRequired: false))));
}

Future<OrderModel> createOrders({required Map request}) async {
  return OrderModel.fromJson(await handleResponse(await buildHttpResponse(
    MembershipAPIEndPoint.wcOrders,
    body: request,
    requiredNonce: true,
    aAuthRequired: false,
    isForWoocommerce: true,
    method: HttpMethod.POST,
  )));
}

Future<OrderModel> getOrderDetail({required int id}) async {
  return OrderModel.fromJson(await handleResponse(await buildHttpResponse('${MembershipAPIEndPoint.wcOrders}/$id', requiredNonce: true, aAuthRequired: false, isForWoocommerce: true)));
}

Future<List<OrderModel>> getOrderList({int page = 1}) async {
  Iterable it = await handleResponse(
      await buildHttpResponse('${MembershipAPIEndPoint.wcOrders}?customer=${appStore.userId}&page=$page&per_page=$postPerPage', requiredNonce: true, aAuthRequired: false, isForWoocommerce: true));

  return it.map((e) => OrderModel.fromJson(e)).toList();
}
//endregion

//region Blog
Future<List<WpPostResponse>> getBlogList({int? page, String? searchText}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.wpPost}?_embed&page=$page&per_page=$postPerPage&search=$searchText', method: HttpMethod.GET));
  return it.map((e) => WpPostResponse.fromJson(e)).toList();
}

Future<WpPostResponse> wpPostById({required int postId, String? password}) async {
  return WpPostResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.wpPost}/$postId?_embed${password.validate().isNotEmpty ? '&password=$password' : ''}')));
}

Future<List<WpCommentModel>> getBlogComments({int? id, int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.wpComments}?post=$id&order=asc&page=$page&per_page=$postPerPage', method: HttpMethod.GET));
  return it.map((e) => WpCommentModel.fromJson(e)).toList();
}

Future<WpCommentModel> addBlogComment({required int postId, String? content, int? parentId}) async {
  Map request = {"post": postId, "content": content, "parent": parentId};
  return WpCommentModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.wpComments}', method: HttpMethod.POST, body: request)));
}

Future<BaseResponseModel> deleteBlogComment({required int commentId}) async {
  Map request = {"id": commentId};
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.blogComment}', method: HttpMethod.DELETE, body: request)));
}

Future<WpCommentModel> updateBlogComment({required int commentId, String? content}) async {
  Map request = {"id": commentId, "content": content};
  return WpCommentModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.blogComment}', method: HttpMethod.POST, body: request)));
}
//endregion

//region Notifications
Future<List<NotificationModel>> getNotifications({int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getNotificationsList}?page=$page&per_page=$postPerPage', method: HttpMethod.POST));
  return it.map((e) => NotificationModel.fromJson(e)).toList();
}

Future<BaseResponseModel> readNotificationAdd(String id) async {
  Map request = {
    "notification_id": id,
    "is_readed": true,
  };
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getNotificationsList}', body: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> remindMeNotification(Map request) async {
  return BaseResponseModel.fromJson(await (handleResponse(await buildHttpResponse(APIEndPoint.remindMe, body: request, method: HttpMethod.POST))));
}

Future<NotificationReminderListModel> getReminderList() async {
  final response = await handleResponse(await buildHttpResponse(APIEndPoint.reminderList, method: HttpMethod.GET));
  return NotificationReminderListModel.fromJson({'data': response});
}

Future<BaseResponseModel> clearNotification() async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.clearNotification, method: HttpMethod.DELETE)));
}

Future<NotificationCount> notificationCount() async {
  return NotificationCount.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.notificationCount, method: HttpMethod.GET)));
}
//endregion

//region Live TV
Future<LiveChannelDetails> getLiveChannelDetails({required int channelId}) async {
  final response = await handleResponse(await buildHttpResponse("${APIEndPoint.liveChannelDetail}/$channelId", method: HttpMethod.GET));
  final details = response['details'];
  final recommended = response['recommended_channels'];
  final adConfig = response['ad_configuration'];

  if (details is Map<String, dynamic>) {
    return LiveChannelDetails.fromJson({...details, 'recommended_channels': recommended, 'ad_configuration': adConfig});
  } else {
    throw Exception('Invalid or missing "details" in API response');
  }
}

Future<EpgDataModel> getEPGData({required String date, required int channelId}) async {
  final cacheKey = 'epg_${channelId}_$date';
  // Try to get from cache first
  final cached = CachedData.getCachedData(cachedKey: cacheKey);
  if (cached != null) {
    return EpgDataModel.fromJson(cached);
  }
  final deviceTimezone = DateTime.now().timeZoneName;
  final response = await buildHttpResponse('${APIEndPoint.epgDetail}/$channelId?date=$date&timezone=$deviceTimezone', method: HttpMethod.GET);
  final decoded = await handleResponse(response);
  // Store in cache for future use
  await setValue(cacheKey, jsonEncode(decoded));
  return EpgDataModel.fromJson(decoded);
}

Future<AllLiveCategoryList> getLiveCategoryList() async {
  final response = await handleResponse(await buildHttpResponse(APIEndPoint.liveCategoryList, method: HttpMethod.GET));
  log('LiveCategoryList API response: ' + response.toString());
  if (response is List) {
    return AllLiveCategoryList.fromJson({"status": true, "message": "", "data": response});
  } else {
    return AllLiveCategoryList.fromJson(response);
  }
}

Future<LiveCategoryList> fetchCategoryChannels(int categoryId) async {
  final response = await handleResponse(
    await buildHttpResponse('${APIEndPoint.liveCategoryList}?category_id=$categoryId', method: HttpMethod.GET),
  );
  log('Category Channels API response: $response');
  if (response is List) {
    return LiveCategoryList.fromJson({"status": true, "message": "", "data": response});
  } else {
    return LiveCategoryList.fromJson(response);
  }
}
//endregion
