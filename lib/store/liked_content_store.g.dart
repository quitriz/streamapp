// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liked_content_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LikedContentStore on LikedContentStoreBase, Store {
  late final _$selectedTabIndexAtom =
      Atom(name: 'LikedContentStoreBase.selectedTabIndex', context: context);

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

  late final _$likedDataAtom =
      Atom(name: 'LikedContentStoreBase.likedData', context: context);

  @override
  ObservableMap<String, ObservableList<CommonDataListModel>> get likedData {
    _$likedDataAtom.reportRead();
    return super.likedData;
  }

  @override
  set likedData(
      ObservableMap<String, ObservableList<CommonDataListModel>> value) {
    _$likedDataAtom.reportWrite(value, super.likedData, () {
      super.likedData = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: 'LikedContentStoreBase.currentPage', context: context);

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
      Atom(name: 'LikedContentStoreBase.isLastPage', context: context);

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
      Atom(name: 'LikedContentStoreBase.isLoading', context: context);

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
      Atom(name: 'LikedContentStoreBase.hasError', context: context);

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
      Atom(name: 'LikedContentStoreBase.userId', context: context);

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

  late final _$loadLikedContentAsyncAction =
      AsyncAction('LikedContentStoreBase.loadLikedContent', context: context);

  @override
  Future<void> loadLikedContent(String postType, {bool isRefresh = false}) {
    return _$loadLikedContentAsyncAction
        .run(() => super.loadLikedContent(postType, isRefresh: isRefresh));
  }

  late final _$loadMoreLikedContentAsyncAction = AsyncAction(
      'LikedContentStoreBase.loadMoreLikedContent',
      context: context);

  @override
  Future<void> loadMoreLikedContent(String postType) {
    return _$loadMoreLikedContentAsyncAction
        .run(() => super.loadMoreLikedContent(postType));
  }

  late final _$refreshLikedContentAsyncAction = AsyncAction(
      'LikedContentStoreBase.refreshLikedContent',
      context: context);

  @override
  Future<void> refreshLikedContent(String postType) {
    return _$refreshLikedContentAsyncAction
        .run(() => super.refreshLikedContent(postType));
  }

  late final _$removeFromLikedContentAsyncAction = AsyncAction(
      'LikedContentStoreBase.removeFromLikedContent',
      context: context);

  @override
  Future<void> removeFromLikedContent(
      String postType, CommonDataListModel item) {
    return _$removeFromLikedContentAsyncAction
        .run(() => super.removeFromLikedContent(postType, item));
  }

  late final _$LikedContentStoreBaseActionController =
      ActionController(name: 'LikedContentStoreBase', context: context);

  @override
  void setUserId(int id) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.setUserId');
    try {
      return super.setUserId(id);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedTabIndex(int index) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.setSelectedTabIndex');
    try {
      return super.setSelectedTabIndex(index);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(String postType, bool loading) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.setLoading');
    try {
      return super.setLoading(postType, loading);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(String postType, bool error) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.setError');
    try {
      return super.setError(postType, error);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPage(String postType, int page) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.setPage');
    try {
      return super.setPage(postType, page);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLastPage(String postType, bool isLast) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.setLastPage');
    try {
      return super.setLastPage(postType, isLast);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initializePostType(String postType) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.initializePostType');
    try {
      return super.initializePostType(postType);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearLikedContent(String postType) {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.clearLikedContent');
    try {
      return super.clearLikedContent(postType);
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAll() {
    final _$actionInfo = _$LikedContentStoreBaseActionController.startAction(
        name: 'LikedContentStoreBase.clearAll');
    try {
      return super.clearAll();
    } finally {
      _$LikedContentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedTabIndex: ${selectedTabIndex},
likedData: ${likedData},
currentPage: ${currentPage},
isLastPage: ${isLastPage},
isLoading: ${isLoading},
hasError: ${hasError},
userId: ${userId}
    ''';
  }
}
