// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlaylistStore on PlaylistStoreBase, Store {
  Computed<Future<List<PlaylistModel>>?>? _$currentPlaylistFutureComputed;

  @override
  Future<List<PlaylistModel>>? get currentPlaylistFuture =>
      (_$currentPlaylistFutureComputed ??=
              Computed<Future<List<PlaylistModel>>?>(
                  () => super.currentPlaylistFuture,
                  name: 'PlaylistStoreBase.currentPlaylistFuture'))
          .value;
  Computed<List<PlaylistModel>>? _$currentPlaylistDataComputed;

  @override
  List<PlaylistModel> get currentPlaylistData =>
      (_$currentPlaylistDataComputed ??= Computed<List<PlaylistModel>>(
              () => super.currentPlaylistData,
              name: 'PlaylistStoreBase.currentPlaylistData'))
          .value;
  Computed<String>? _$currentNoDataTitleComputed;

  @override
  String get currentNoDataTitle => (_$currentNoDataTitleComputed ??=
          Computed<String>(() => super.currentNoDataTitle,
              name: 'PlaylistStoreBase.currentNoDataTitle'))
      .value;

  late final _$selectedTabIndexAtom =
      Atom(name: 'PlaylistStoreBase.selectedTabIndex', context: context);

  @override
  int get selectedTabIndex {
    _$selectedTabIndexAtom.reportRead();
    return super.selectedTabIndex;
  }

  @override
  set selectedTabIndex(int value) {
    _$selectedTabIndexAtom.reportWrite(value, super.selectedTabIndex, () {
      super.selectedTabIndex = value;
    });
  }

  late final _$selectedPlaylistTypeAtom =
      Atom(name: 'PlaylistStoreBase.selectedPlaylistType', context: context);

  @override
  String get selectedPlaylistType {
    _$selectedPlaylistTypeAtom.reportRead();
    return super.selectedPlaylistType;
  }

  @override
  set selectedPlaylistType(String value) {
    _$selectedPlaylistTypeAtom.reportWrite(value, super.selectedPlaylistType,
        () {
      super.selectedPlaylistType = value;
    });
  }

  late final _$selectedPlaylistTypeModelAtom = Atom(
      name: 'PlaylistStoreBase.selectedPlaylistTypeModel', context: context);

  @override
  DataModel? get selectedPlaylistTypeModel {
    _$selectedPlaylistTypeModelAtom.reportRead();
    return super.selectedPlaylistTypeModel;
  }

  @override
  set selectedPlaylistTypeModel(DataModel? value) {
    _$selectedPlaylistTypeModelAtom
        .reportWrite(value, super.selectedPlaylistTypeModel, () {
      super.selectedPlaylistTypeModel = value;
    });
  }

  late final _$playListTypeListAtom =
      Atom(name: 'PlaylistStoreBase.playListTypeList', context: context);

  @override
  ObservableList<DataModel> get playListTypeList {
    _$playListTypeListAtom.reportRead();
    return super.playListTypeList;
  }

  @override
  set playListTypeList(ObservableList<DataModel> value) {
    _$playListTypeListAtom.reportWrite(value, super.playListTypeList, () {
      super.playListTypeList = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'PlaylistStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isCreatingPlaylistAtom =
      Atom(name: 'PlaylistStoreBase.isCreatingPlaylist', context: context);

  @override
  bool get isCreatingPlaylist {
    _$isCreatingPlaylistAtom.reportRead();
    return super.isCreatingPlaylist;
  }

  @override
  set isCreatingPlaylist(bool value) {
    _$isCreatingPlaylistAtom.reportWrite(value, super.isCreatingPlaylist, () {
      super.isCreatingPlaylist = value;
    });
  }

  late final _$playlistFuturesAtom =
      Atom(name: 'PlaylistStoreBase.playlistFutures', context: context);

  @override
  ObservableMap<String, Future<List<PlaylistModel>>> get playlistFutures {
    _$playlistFuturesAtom.reportRead();
    return super.playlistFutures;
  }

  @override
  set playlistFutures(
      ObservableMap<String, Future<List<PlaylistModel>>> value) {
    _$playlistFuturesAtom.reportWrite(value, super.playlistFutures, () {
      super.playlistFutures = value;
    });
  }

  late final _$playlistDataAtom =
      Atom(name: 'PlaylistStoreBase.playlistData', context: context);

  @override
  ObservableMap<String, List<PlaylistModel>> get playlistData {
    _$playlistDataAtom.reportRead();
    return super.playlistData;
  }

  @override
  set playlistData(ObservableMap<String, List<PlaylistModel>> value) {
    _$playlistDataAtom.reportWrite(value, super.playlistData, () {
      super.playlistData = value;
    });
  }

  late final _$playlistMediaDataAtom =
      Atom(name: 'PlaylistStoreBase.playlistMediaData', context: context);

  @override
  ObservableMap<String, ObservableList<CommonDataListModel>>
      get playlistMediaData {
    _$playlistMediaDataAtom.reportRead();
    return super.playlistMediaData;
  }

  @override
  set playlistMediaData(
      ObservableMap<String, ObservableList<CommonDataListModel>> value) {
    _$playlistMediaDataAtom.reportWrite(value, super.playlistMediaData, () {
      super.playlistMediaData = value;
    });
  }

  late final _$playlistMediaLoadingAtom =
      Atom(name: 'PlaylistStoreBase.playlistMediaLoading', context: context);

  @override
  ObservableMap<String, bool> get playlistMediaLoading {
    _$playlistMediaLoadingAtom.reportRead();
    return super.playlistMediaLoading;
  }

  @override
  set playlistMediaLoading(ObservableMap<String, bool> value) {
    _$playlistMediaLoadingAtom.reportWrite(value, super.playlistMediaLoading,
        () {
      super.playlistMediaLoading = value;
    });
  }

  late final _$playlistMediaLastPageAtom =
      Atom(name: 'PlaylistStoreBase.playlistMediaLastPage', context: context);

  @override
  ObservableMap<String, bool> get playlistMediaLastPage {
    _$playlistMediaLastPageAtom.reportRead();
    return super.playlistMediaLastPage;
  }

  @override
  set playlistMediaLastPage(ObservableMap<String, bool> value) {
    _$playlistMediaLastPageAtom.reportWrite(value, super.playlistMediaLastPage,
        () {
      super.playlistMediaLastPage = value;
    });
  }

  late final _$playlistMediaCurrentPageAtom = Atom(
      name: 'PlaylistStoreBase.playlistMediaCurrentPage', context: context);

  @override
  ObservableMap<String, int> get playlistMediaCurrentPage {
    _$playlistMediaCurrentPageAtom.reportRead();
    return super.playlistMediaCurrentPage;
  }

  @override
  set playlistMediaCurrentPage(ObservableMap<String, int> value) {
    _$playlistMediaCurrentPageAtom
        .reportWrite(value, super.playlistMediaCurrentPage, () {
      super.playlistMediaCurrentPage = value;
    });
  }

  late final _$playlistMediaHasErrorAtom =
      Atom(name: 'PlaylistStoreBase.playlistMediaHasError', context: context);

  @override
  ObservableMap<String, bool> get playlistMediaHasError {
    _$playlistMediaHasErrorAtom.reportRead();
    return super.playlistMediaHasError;
  }

  @override
  set playlistMediaHasError(ObservableMap<String, bool> value) {
    _$playlistMediaHasErrorAtom.reportWrite(value, super.playlistMediaHasError,
        () {
      super.playlistMediaHasError = value;
    });
  }

  late final _$playlistListFuturesAtom =
      Atom(name: 'PlaylistStoreBase.playlistListFutures', context: context);

  @override
  ObservableMap<String, Future<List<PlaylistModel>>> get playlistListFutures {
    _$playlistListFuturesAtom.reportRead();
    return super.playlistListFutures;
  }

  @override
  set playlistListFutures(
      ObservableMap<String, Future<List<PlaylistModel>>> value) {
    _$playlistListFuturesAtom.reportWrite(value, super.playlistListFutures, () {
      super.playlistListFutures = value;
    });
  }

  late final _$playlistListDataAtom =
      Atom(name: 'PlaylistStoreBase.playlistListData', context: context);

  @override
  ObservableMap<String, List<PlaylistModel>> get playlistListData {
    _$playlistListDataAtom.reportRead();
    return super.playlistListData;
  }

  @override
  set playlistListData(ObservableMap<String, List<PlaylistModel>> value) {
    _$playlistListDataAtom.reportWrite(value, super.playlistListData, () {
      super.playlistListData = value;
    });
  }

  late final _$playlistListLoadingAtom =
      Atom(name: 'PlaylistStoreBase.playlistListLoading', context: context);

  @override
  ObservableMap<String, bool> get playlistListLoading {
    _$playlistListLoadingAtom.reportRead();
    return super.playlistListLoading;
  }

  @override
  set playlistListLoading(ObservableMap<String, bool> value) {
    _$playlistListLoadingAtom.reportWrite(value, super.playlistListLoading, () {
      super.playlistListLoading = value;
    });
  }

  late final _$loadPlaylistByTypeAsyncAction =
      AsyncAction('PlaylistStoreBase.loadPlaylistByType', context: context);

  @override
  Future<void> loadPlaylistByType(String type) {
    return _$loadPlaylistByTypeAsyncAction
        .run(() => super.loadPlaylistByType(type));
  }

  late final _$refreshPlaylistAsyncAction =
      AsyncAction('PlaylistStoreBase.refreshPlaylist', context: context);

  @override
  Future<void> refreshPlaylist(String type) {
    return _$refreshPlaylistAsyncAction.run(() => super.refreshPlaylist(type));
  }

  late final _$refreshAllPlaylistsAsyncAction =
      AsyncAction('PlaylistStoreBase.refreshAllPlaylists', context: context);

  @override
  Future<void> refreshAllPlaylists() {
    return _$refreshAllPlaylistsAsyncAction
        .run(() => super.refreshAllPlaylists());
  }

  late final _$createPlaylistAsyncAction =
      AsyncAction('PlaylistStoreBase.createPlaylist', context: context);

  @override
  Future<bool> createPlaylist(
      {required String playlistName, required String playlistType}) {
    return _$createPlaylistAsyncAction.run(() => super.createPlaylist(
        playlistName: playlistName, playlistType: playlistType));
  }

  late final _$editPlaylistAsyncAction =
      AsyncAction('PlaylistStoreBase.editPlaylist', context: context);

  @override
  Future<bool> editPlaylist(
      {required int playlistId,
      required String playlistName,
      required String playlistType}) {
    return _$editPlaylistAsyncAction.run(() => super.editPlaylist(
        playlistId: playlistId,
        playlistName: playlistName,
        playlistType: playlistType));
  }

  late final _$deletePlaylistAsyncAction =
      AsyncAction('PlaylistStoreBase.deletePlaylist', context: context);

  @override
  Future<bool> deletePlaylist(
      {required int playlistId, required String playlistType}) {
    return _$deletePlaylistAsyncAction.run(() => super
        .deletePlaylist(playlistId: playlistId, playlistType: playlistType));
  }

  late final _$loadPlaylistForPostAsyncAction =
      AsyncAction('PlaylistStoreBase.loadPlaylistForPost', context: context);

  @override
  Future<void> loadPlaylistForPost(
      {required String playlistType, required int postId}) {
    return _$loadPlaylistForPostAsyncAction.run(() =>
        super.loadPlaylistForPost(playlistType: playlistType, postId: postId));
  }

  late final _$refreshPlaylistForPostAsyncAction =
      AsyncAction('PlaylistStoreBase.refreshPlaylistForPost', context: context);

  @override
  Future<void> refreshPlaylistForPost(
      {required String playlistType, required int postId}) {
    return _$refreshPlaylistForPostAsyncAction.run(() => super
        .refreshPlaylistForPost(playlistType: playlistType, postId: postId));
  }

  late final _$PlaylistStoreBaseActionController =
      ActionController(name: 'PlaylistStoreBase', context: context);

  @override
  void setSelectedTabIndex(int index) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setSelectedTabIndex');
    try {
      return super.setSelectedTabIndex(index);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedPlaylistType(String type) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setSelectedPlaylistType');
    try {
      return super.setSelectedPlaylistType(type);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedPlaylistTypeModel(DataModel? model) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setSelectedPlaylistTypeModel');
    try {
      return super.setSelectedPlaylistTypeModel(model);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool loading) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setLoading');
    try {
      return super.setLoading(loading);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCreatingPlaylist(bool creating) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setCreatingPlaylist');
    try {
      return super.setCreatingPlaylist(creating);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initializePlaylistTypes() {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.initializePlaylistTypes');
    try {
      return super.initializePlaylistTypes();
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initializePlaylistMediaKey(String key) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.initializePlaylistMediaKey');
    try {
      return super.initializePlaylistMediaKey(key);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPlaylistMediaLoading(String key, bool loading) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setPlaylistMediaLoading');
    try {
      return super.setPlaylistMediaLoading(key, loading);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPlaylistMediaLastPage(String key, bool isLastPage) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setPlaylistMediaLastPage');
    try {
      return super.setPlaylistMediaLastPage(key, isLastPage);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPlaylistMediaCurrentPage(String key, int page) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setPlaylistMediaCurrentPage');
    try {
      return super.setPlaylistMediaCurrentPage(key, page);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPlaylistMediaError(String key, bool hasError) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setPlaylistMediaError');
    try {
      return super.setPlaylistMediaError(key, hasError);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPlaylistMediaData(String key, List<CommonDataListModel> data,
      {bool isRefresh = false}) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setPlaylistMediaData');
    try {
      return super.setPlaylistMediaData(key, data, isRefresh: isRefresh);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removePlaylistMediaItem(String key, CommonDataListModel item) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.removePlaylistMediaItem');
    try {
      return super.removePlaylistMediaItem(key, item);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPlaylistMediaData(String key) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.clearPlaylistMediaData');
    try {
      return super.clearPlaylistMediaData(key);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetPlaylistMediaState(String key) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.resetPlaylistMediaState');
    try {
      return super.resetPlaylistMediaState(key);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPlaylistListLoading(String key, bool loading) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.setPlaylistListLoading');
    try {
      return super.setPlaylistListLoading(key, loading);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updatePlaylistItemStatus(String key, int playlistId, bool isInPlaylist) {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.updatePlaylistItemStatus');
    try {
      return super.updatePlaylistItemStatus(key, playlistId, isInPlaylist);
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAllPlaylistStates() {
    final _$actionInfo = _$PlaylistStoreBaseActionController.startAction(
        name: 'PlaylistStoreBase.clearAllPlaylistStates');
    try {
      return super.clearAllPlaylistStates();
    } finally {
      _$PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedTabIndex: ${selectedTabIndex},
selectedPlaylistType: ${selectedPlaylistType},
selectedPlaylistTypeModel: ${selectedPlaylistTypeModel},
playListTypeList: ${playListTypeList},
isLoading: ${isLoading},
isCreatingPlaylist: ${isCreatingPlaylist},
playlistFutures: ${playlistFutures},
playlistData: ${playlistData},
playlistMediaData: ${playlistMediaData},
playlistMediaLoading: ${playlistMediaLoading},
playlistMediaLastPage: ${playlistMediaLastPage},
playlistMediaCurrentPage: ${playlistMediaCurrentPage},
playlistMediaHasError: ${playlistMediaHasError},
playlistListFutures: ${playlistListFutures},
playlistListData: ${playlistListData},
playlistListLoading: ${playlistListLoading},
currentPlaylistFuture: ${currentPlaylistFuture},
currentPlaylistData: ${currentPlaylistData},
currentNoDataTitle: ${currentNoDataTitle}
    ''';
  }
}
