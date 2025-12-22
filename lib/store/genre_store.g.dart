// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GenreStore on GenreStoreBase, Store {
  Computed<String>? _$currentGenreTypeComputed;

  @override
  String get currentGenreType => (_$currentGenreTypeComputed ??=
          Computed<String>(() => super.currentGenreType,
              name: 'GenreStoreBase.currentGenreType'))
      .value;

  late final _$genreSelectedTabIndexAtom =
      Atom(name: 'GenreStoreBase.genreSelectedTabIndex', context: context);

  @override
  int get genreSelectedTabIndex {
    _$genreSelectedTabIndexAtom.reportRead();
    return super.genreSelectedTabIndex;
  }

  @override
  set genreSelectedTabIndex(int value) {
    _$genreSelectedTabIndexAtom.reportWrite(value, super.genreSelectedTabIndex,
        () {
      super.genreSelectedTabIndex = value;
    });
  }

  late final _$genreIsTabAnimatingAtom =
      Atom(name: 'GenreStoreBase.genreIsTabAnimating', context: context);

  @override
  bool get genreIsTabAnimating {
    _$genreIsTabAnimatingAtom.reportRead();
    return super.genreIsTabAnimating;
  }

  @override
  set genreIsTabAnimating(bool value) {
    _$genreIsTabAnimatingAtom.reportWrite(value, super.genreIsTabAnimating, () {
      super.genreIsTabAnimating = value;
    });
  }

  late final _$genreCurrentTypeAtom =
      Atom(name: 'GenreStoreBase.genreCurrentType', context: context);

  @override
  String get genreCurrentType {
    _$genreCurrentTypeAtom.reportRead();
    return super.genreCurrentType;
  }

  @override
  set genreCurrentType(String value) {
    _$genreCurrentTypeAtom.reportWrite(value, super.genreCurrentType, () {
      super.genreCurrentType = value;
    });
  }

  late final _$genreListDataAtom =
      Atom(name: 'GenreStoreBase.genreListData', context: context);

  @override
  ObservableMap<String, ObservableList<GenreData>> get genreListData {
    _$genreListDataAtom.reportRead();
    return super.genreListData;
  }

  @override
  set genreListData(ObservableMap<String, ObservableList<GenreData>> value) {
    _$genreListDataAtom.reportWrite(value, super.genreListData, () {
      super.genreListData = value;
    });
  }

  late final _$genreListLoadingAtom =
      Atom(name: 'GenreStoreBase.genreListLoading', context: context);

  @override
  ObservableMap<String, bool> get genreListLoading {
    _$genreListLoadingAtom.reportRead();
    return super.genreListLoading;
  }

  @override
  set genreListLoading(ObservableMap<String, bool> value) {
    _$genreListLoadingAtom.reportWrite(value, super.genreListLoading, () {
      super.genreListLoading = value;
    });
  }

  late final _$genreListLastPageAtom =
      Atom(name: 'GenreStoreBase.genreListLastPage', context: context);

  @override
  ObservableMap<String, bool> get genreListLastPage {
    _$genreListLastPageAtom.reportRead();
    return super.genreListLastPage;
  }

  @override
  set genreListLastPage(ObservableMap<String, bool> value) {
    _$genreListLastPageAtom.reportWrite(value, super.genreListLastPage, () {
      super.genreListLastPage = value;
    });
  }

  late final _$genreListCurrentPageAtom =
      Atom(name: 'GenreStoreBase.genreListCurrentPage', context: context);

  @override
  ObservableMap<String, int> get genreListCurrentPage {
    _$genreListCurrentPageAtom.reportRead();
    return super.genreListCurrentPage;
  }

  @override
  set genreListCurrentPage(ObservableMap<String, int> value) {
    _$genreListCurrentPageAtom.reportWrite(value, super.genreListCurrentPage,
        () {
      super.genreListCurrentPage = value;
    });
  }

  late final _$genreListHasErrorAtom =
      Atom(name: 'GenreStoreBase.genreListHasError', context: context);

  @override
  ObservableMap<String, bool> get genreListHasError {
    _$genreListHasErrorAtom.reportRead();
    return super.genreListHasError;
  }

  @override
  set genreListHasError(ObservableMap<String, bool> value) {
    _$genreListHasErrorAtom.reportWrite(value, super.genreListHasError, () {
      super.genreListHasError = value;
    });
  }

  late final _$genreMovieListDataAtom =
      Atom(name: 'GenreStoreBase.genreMovieListData', context: context);

  @override
  ObservableMap<String, ObservableList<CommonDataListModel>>
      get genreMovieListData {
    _$genreMovieListDataAtom.reportRead();
    return super.genreMovieListData;
  }

  @override
  set genreMovieListData(
      ObservableMap<String, ObservableList<CommonDataListModel>> value) {
    _$genreMovieListDataAtom.reportWrite(value, super.genreMovieListData, () {
      super.genreMovieListData = value;
    });
  }

  late final _$genreMovieListLoadingAtom =
      Atom(name: 'GenreStoreBase.genreMovieListLoading', context: context);

  @override
  ObservableMap<String, bool> get genreMovieListLoading {
    _$genreMovieListLoadingAtom.reportRead();
    return super.genreMovieListLoading;
  }

  @override
  set genreMovieListLoading(ObservableMap<String, bool> value) {
    _$genreMovieListLoadingAtom.reportWrite(value, super.genreMovieListLoading,
        () {
      super.genreMovieListLoading = value;
    });
  }

  late final _$genreMovieListLoadMoreAtom =
      Atom(name: 'GenreStoreBase.genreMovieListLoadMore', context: context);

  @override
  ObservableMap<String, bool> get genreMovieListLoadMore {
    _$genreMovieListLoadMoreAtom.reportRead();
    return super.genreMovieListLoadMore;
  }

  @override
  set genreMovieListLoadMore(ObservableMap<String, bool> value) {
    _$genreMovieListLoadMoreAtom
        .reportWrite(value, super.genreMovieListLoadMore, () {
      super.genreMovieListLoadMore = value;
    });
  }

  late final _$genreMovieListHasErrorAtom =
      Atom(name: 'GenreStoreBase.genreMovieListHasError', context: context);

  @override
  ObservableMap<String, bool> get genreMovieListHasError {
    _$genreMovieListHasErrorAtom.reportRead();
    return super.genreMovieListHasError;
  }

  @override
  set genreMovieListHasError(ObservableMap<String, bool> value) {
    _$genreMovieListHasErrorAtom
        .reportWrite(value, super.genreMovieListHasError, () {
      super.genreMovieListHasError = value;
    });
  }

  late final _$genreMovieListCurrentPageAtom =
      Atom(name: 'GenreStoreBase.genreMovieListCurrentPage', context: context);

  @override
  ObservableMap<String, int> get genreMovieListCurrentPage {
    _$genreMovieListCurrentPageAtom.reportRead();
    return super.genreMovieListCurrentPage;
  }

  @override
  set genreMovieListCurrentPage(ObservableMap<String, int> value) {
    _$genreMovieListCurrentPageAtom
        .reportWrite(value, super.genreMovieListCurrentPage, () {
      super.genreMovieListCurrentPage = value;
    });
  }

  late final _$GenreStoreBaseActionController =
      ActionController(name: 'GenreStoreBase', context: context);

  @override
  void setGenreSelectedTabIndex(int index) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreSelectedTabIndex');
    try {
      return super.setGenreSelectedTabIndex(index);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreTabAnimating(bool animating) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreTabAnimating');
    try {
      return super.setGenreTabAnimating(animating);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreCurrentType(String type) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreCurrentType');
    try {
      return super.setGenreCurrentType(type);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetGenreState() {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.resetGenreState');
    try {
      return super.resetGenreState();
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initializeGenreListType(String type) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.initializeGenreListType');
    try {
      return super.initializeGenreListType(type);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreListLoading(String type, bool loading) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreListLoading');
    try {
      return super.setGenreListLoading(type, loading);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreListLastPage(String type, bool isLastPage) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreListLastPage');
    try {
      return super.setGenreListLastPage(type, isLastPage);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreListCurrentPage(String type, int page) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreListCurrentPage');
    try {
      return super.setGenreListCurrentPage(type, page);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreListError(String type, bool hasError) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreListError');
    try {
      return super.setGenreListError(type, hasError);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreListData(String type, List<GenreData> data,
      {bool isRefresh = false}) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreListData');
    try {
      return super.setGenreListData(type, data, isRefresh: isRefresh);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearGenreListData(String type) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.clearGenreListData');
    try {
      return super.clearGenreListData(type);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetGenreListState(String type) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.resetGenreListState');
    try {
      return super.resetGenreListState(type);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAllGenreListStates() {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.clearAllGenreListStates');
    try {
      return super.clearAllGenreListStates();
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initializeGenreMovieListType(String key) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.initializeGenreMovieListType');
    try {
      return super.initializeGenreMovieListType(key);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreMovieListLoading(String key, bool loading) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreMovieListLoading');
    try {
      return super.setGenreMovieListLoading(key, loading);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreMovieListLoadMore(String key, bool loadMore) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreMovieListLoadMore');
    try {
      return super.setGenreMovieListLoadMore(key, loadMore);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreMovieListError(String key, bool hasError) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreMovieListError');
    try {
      return super.setGenreMovieListError(key, hasError);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreMovieListCurrentPage(String key, int page) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreMovieListCurrentPage');
    try {
      return super.setGenreMovieListCurrentPage(key, page);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGenreMovieListData(String key, List<CommonDataListModel> data,
      {bool isRefresh = false}) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.setGenreMovieListData');
    try {
      return super.setGenreMovieListData(key, data, isRefresh: isRefresh);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearGenreMovieListData(String key) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.clearGenreMovieListData');
    try {
      return super.clearGenreMovieListData(key);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetGenreMovieListState(String key) {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.resetGenreMovieListState');
    try {
      return super.resetGenreMovieListState(key);
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAllGenreMovieListStates() {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.clearAllGenreMovieListStates');
    try {
      return super.clearAllGenreMovieListStates();
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAllGenreStates() {
    final _$actionInfo = _$GenreStoreBaseActionController.startAction(
        name: 'GenreStoreBase.clearAllGenreStates');
    try {
      return super.clearAllGenreStates();
    } finally {
      _$GenreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
genreSelectedTabIndex: ${genreSelectedTabIndex},
genreIsTabAnimating: ${genreIsTabAnimating},
genreCurrentType: ${genreCurrentType},
genreListData: ${genreListData},
genreListLoading: ${genreListLoading},
genreListLastPage: ${genreListLastPage},
genreListCurrentPage: ${genreListCurrentPage},
genreListHasError: ${genreListHasError},
genreMovieListData: ${genreMovieListData},
genreMovieListLoading: ${genreMovieListLoading},
genreMovieListLoadMore: ${genreMovieListLoadMore},
genreMovieListHasError: ${genreMovieListHasError},
genreMovieListCurrentPage: ${genreMovieListCurrentPage},
currentGenreType: ${currentGenreType}
    ''';
  }
}
