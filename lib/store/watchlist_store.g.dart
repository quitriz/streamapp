// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$WatchlistStore on WatchlistStoreBase, Store {
  late final _$selectedTabIndexAtom =
      Atom(name: 'WatchlistStoreBase.selectedTabIndex', context: context);

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

  late final _$watchlistDataAtom =
      Atom(name: 'WatchlistStoreBase.watchlistData', context: context);

  @override
  ObservableMap<String, ObservableList<CommonDataListModel>> get watchlistData {
    _$watchlistDataAtom.reportRead();
    return super.watchlistData;
  }

  @override
  set watchlistData(
      ObservableMap<String, ObservableList<CommonDataListModel>> value) {
    _$watchlistDataAtom.reportWrite(value, super.watchlistData, () {
      super.watchlistData = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: 'WatchlistStoreBase.currentPage', context: context);

  @override
  ObservableMap<String, int> get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(ObservableMap<String, int> value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$isLastPageAtom =
      Atom(name: 'WatchlistStoreBase.isLastPage', context: context);

  @override
  ObservableMap<String, bool> get isLastPage {
    _$isLastPageAtom.reportRead();
    return super.isLastPage;
  }

  @override
  set isLastPage(ObservableMap<String, bool> value) {
    _$isLastPageAtom.reportWrite(value, super.isLastPage, () {
      super.isLastPage = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'WatchlistStoreBase.isLoading', context: context);

  @override
  ObservableMap<String, bool> get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(ObservableMap<String, bool> value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$hasErrorAtom =
      Atom(name: 'WatchlistStoreBase.hasError', context: context);

  @override
  ObservableMap<String, bool> get hasError {
    _$hasErrorAtom.reportRead();
    return super.hasError;
  }

  @override
  set hasError(ObservableMap<String, bool> value) {
    _$hasErrorAtom.reportWrite(value, super.hasError, () {
      super.hasError = value;
    });
  }

  late final _$userIdAtom =
      Atom(name: 'WatchlistStoreBase.userId', context: context);

  @override
  int get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(int value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  late final _$loadWatchlistAsyncAction =
      AsyncAction('WatchlistStoreBase.loadWatchlist', context: context);

  @override
  Future<void> loadWatchlist(String postType, {bool isRefresh = false}) {
    return _$loadWatchlistAsyncAction
        .run(() => super.loadWatchlist(postType, isRefresh: isRefresh));
  }

  late final _$loadMoreWatchlistAsyncAction =
      AsyncAction('WatchlistStoreBase.loadMoreWatchlist', context: context);

  @override
  Future<void> loadMoreWatchlist(String postType) {
    return _$loadMoreWatchlistAsyncAction
        .run(() => super.loadMoreWatchlist(postType));
  }

  late final _$refreshWatchlistAsyncAction =
      AsyncAction('WatchlistStoreBase.refreshWatchlist', context: context);

  @override
  Future<void> refreshWatchlist(String postType) {
    return _$refreshWatchlistAsyncAction
        .run(() => super.refreshWatchlist(postType));
  }

  late final _$removeFromWatchlistAsyncAction =
      AsyncAction('WatchlistStoreBase.removeFromWatchlist', context: context);

  @override
  Future<void> removeFromWatchlist(String postType, CommonDataListModel item) {
    return _$removeFromWatchlistAsyncAction
        .run(() => super.removeFromWatchlist(postType, item));
  }

  late final _$WatchlistStoreBaseActionController =
      ActionController(name: 'WatchlistStoreBase', context: context);

  @override
  void setSelectedTabIndex(int index) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.setSelectedTabIndex');
    try {
      return super.setSelectedTabIndex(index);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserId(int id) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.setUserId');
    try {
      return super.setUserId(id);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(String postType, bool loading) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.setLoading');
    try {
      return super.setLoading(postType, loading);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(String postType, bool error) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.setError');
    try {
      return super.setError(postType, error);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPage(String postType, int page) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.setPage');
    try {
      return super.setPage(postType, page);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLastPage(String postType, bool isLast) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.setLastPage');
    try {
      return super.setLastPage(postType, isLast);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initializePostType(String postType) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.initializePostType');
    try {
      return super.initializePostType(postType);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearWatchlist(String postType) {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.clearWatchlist');
    try {
      return super.clearWatchlist(postType);
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAllWatchLists() {
    final _$actionInfo = _$WatchlistStoreBaseActionController.startAction(
        name: 'WatchlistStoreBase.clearAllWatchLists');
    try {
      return super.clearAllWatchLists();
    } finally {
      _$WatchlistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedTabIndex: ${selectedTabIndex},
watchlistData: ${watchlistData},
currentPage: ${currentPage},
isLastPage: ${isLastPage},
isLoading: ${isLoading},
hasError: ${hasError},
userId: ${userId}
    ''';
  }
}
