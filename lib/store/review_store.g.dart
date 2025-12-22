// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ReviewStore on ReviewStoreBase, Store {
  Computed<bool>? _$hasUserReviewedComputed;

  @override
  bool get hasUserReviewed =>
      (_$hasUserReviewedComputed ??= Computed<bool>(() => super.hasUserReviewed,
              name: 'ReviewStoreBase.hasUserReviewed'))
          .value;
  Computed<Review?>? _$currentUserReviewComputed;

  @override
  Review? get currentUserReview => (_$currentUserReviewComputed ??=
          Computed<Review?>(() => super.currentUserReview,
              name: 'ReviewStoreBase.currentUserReview'))
      .value;
  Computed<List<Review>>? _$otherUserReviewsComputed;

  @override
  List<Review> get otherUserReviews => (_$otherUserReviewsComputed ??=
          Computed<List<Review>>(() => super.otherUserReviews,
              name: 'ReviewStoreBase.otherUserReviews'))
      .value;
  Computed<double>? _$averageRatingComputed;

  @override
  double get averageRating =>
      (_$averageRatingComputed ??= Computed<double>(() => super.averageRating,
              name: 'ReviewStoreBase.averageRating'))
          .value;
  Computed<Map<int, int>>? _$starCountsComputed;

  @override
  Map<int, int> get starCounts =>
      (_$starCountsComputed ??= Computed<Map<int, int>>(() => super.starCounts,
              name: 'ReviewStoreBase.starCounts'))
          .value;
  Computed<bool>? _$canSubmitReviewComputed;

  @override
  bool get canSubmitReview =>
      (_$canSubmitReviewComputed ??= Computed<bool>(() => super.canSubmitReview,
              name: 'ReviewStoreBase.canSubmitReview'))
          .value;
  Computed<bool>? _$hasReviewsComputed;

  @override
  bool get hasReviews =>
      (_$hasReviewsComputed ??= Computed<bool>(() => super.hasReviews,
              name: 'ReviewStoreBase.hasReviews'))
          .value;

  late final _$reviewListAtom =
      Atom(name: 'ReviewStoreBase.reviewList', context: context);

  @override
  ObservableList<Review> get reviewList {
    _$reviewListAtom.reportRead();
    return super.reviewList;
  }

  @override
  set reviewList(ObservableList<Review> value) {
    _$reviewListAtom.reportWrite(value, super.reviewList, () {
      super.reviewList = value;
    });
  }

  late final _$selectedFilterAtom =
      Atom(name: 'ReviewStoreBase.selectedFilter', context: context);

  @override
  ReviewFilter get selectedFilter {
    _$selectedFilterAtom.reportRead();
    return super.selectedFilter;
  }

  @override
  set selectedFilter(ReviewFilter value) {
    _$selectedFilterAtom.reportWrite(value, super.selectedFilter, () {
      super.selectedFilter = value;
    });
  }

  late final _$selectedRatingAtom =
      Atom(name: 'ReviewStoreBase.selectedRating', context: context);

  @override
  double get selectedRating {
    _$selectedRatingAtom.reportRead();
    return super.selectedRating;
  }

  @override
  set selectedRating(double value) {
    _$selectedRatingAtom.reportWrite(value, super.selectedRating, () {
      super.selectedRating = value;
    });
  }

  late final _$reviewTextControllerAtom =
      Atom(name: 'ReviewStoreBase.reviewTextController', context: context);

  @override
  TextEditingController get reviewTextController {
    _$reviewTextControllerAtom.reportRead();
    return super.reviewTextController;
  }

  @override
  set reviewTextController(TextEditingController value) {
    _$reviewTextControllerAtom.reportWrite(value, super.reviewTextController,
        () {
      super.reviewTextController = value;
    });
  }

  late final _$isSubmittingReviewAtom =
      Atom(name: 'ReviewStoreBase.isSubmittingReview', context: context);

  @override
  bool get isSubmittingReview {
    _$isSubmittingReviewAtom.reportRead();
    return super.isSubmittingReview;
  }

  @override
  set isSubmittingReview(bool value) {
    _$isSubmittingReviewAtom.reportWrite(value, super.isSubmittingReview, () {
      super.isSubmittingReview = value;
    });
  }

  late final _$isLoadingReviewsAtom =
      Atom(name: 'ReviewStoreBase.isLoadingReviews', context: context);

  @override
  bool get isLoadingReviews {
    _$isLoadingReviewsAtom.reportRead();
    return super.isLoadingReviews;
  }

  @override
  set isLoadingReviews(bool value) {
    _$isLoadingReviewsAtom.reportWrite(value, super.isLoadingReviews, () {
      super.isLoadingReviews = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'ReviewStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$overallRatingAtom =
      Atom(name: 'ReviewStoreBase.overallRating', context: context);

  @override
  double? get overallRating {
    _$overallRatingAtom.reportRead();
    return super.overallRating;
  }

  @override
  set overallRating(double? value) {
    _$overallRatingAtom.reportWrite(value, super.overallRating, () {
      super.overallRating = value;
    });
  }

  late final _$fetchReviewsAsyncAction =
      AsyncAction('ReviewStoreBase.fetchReviews', context: context);

  @override
  Future<void> fetchReviews(
      {required String postType, required int postId, ReviewFilter? filter}) {
    return _$fetchReviewsAsyncAction.run(() =>
        super.fetchReviews(postType: postType, postId: postId, filter: filter));
  }

  late final _$submitReviewAsyncAction =
      AsyncAction('ReviewStoreBase.submitReview', context: context);

  @override
  Future<bool> submitReview(
      {required int postId,
      required String postType,
      required String userName,
      required String userEmail}) {
    return _$submitReviewAsyncAction.run(() => super.submitReview(
        postId: postId,
        postType: postType,
        userName: userName,
        userEmail: userEmail));
  }

  late final _$updateReviewAsyncAction =
      AsyncAction('ReviewStoreBase.updateReview', context: context);

  @override
  Future<bool> updateReview(
      {required int postId,
      required String postType,
      required String userName,
      required String userEmail,
      required int rateId,
      required double rating,
      required String reviewText}) {
    return _$updateReviewAsyncAction.run(() => super.updateReview(
        postId: postId,
        postType: postType,
        userName: userName,
        userEmail: userEmail,
        rateId: rateId,
        rating: rating,
        reviewText: reviewText));
  }

  late final _$deleteReviewAsyncAction =
      AsyncAction('ReviewStoreBase.deleteReview', context: context);

  @override
  Future<bool> deleteReview(
      {required int postId, required String postType, required int rateId}) {
    return _$deleteReviewAsyncAction.run(() =>
        super.deleteReview(postId: postId, postType: postType, rateId: rateId));
  }

  late final _$ReviewStoreBaseActionController =
      ActionController(name: 'ReviewStoreBase', context: context);

  @override
  void setSelectedFilter(ReviewFilter filter) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setSelectedFilter');
    try {
      return super.setSelectedFilter(filter);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedRating(double rating) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setSelectedRating');
    try {
      return super.setSelectedRating(rating);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReviewText(String text) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setReviewText');
    try {
      return super.setReviewText(text);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsSubmittingReview(bool value) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setIsSubmittingReview');
    try {
      return super.setIsSubmittingReview(value);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsLoadingReviews(bool value) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setIsLoadingReviews');
    try {
      return super.setIsLoadingReviews(value);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setErrorMessage(String? message) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setErrorMessage');
    try {
      return super.setErrorMessage(message);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOverallRating(double? rating) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setOverallRating');
    try {
      return super.setOverallRating(rating);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearReviewForm() {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.clearReviewForm');
    try {
      return super.clearReviewForm();
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReviewList(List<Review> reviews) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.setReviewList');
    try {
      return super.setReviewList(reviews);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addReviewToList(Review review) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.addReviewToList');
    try {
      return super.addReviewToList(review);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateReviewInList(Review updatedReview) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.updateReviewInList');
    try {
      return super.updateReviewInList(updatedReview);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeReviewFromList(int rateId) {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.removeReviewFromList');
    try {
      return super.removeReviewFromList(rateId);
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$ReviewStoreBaseActionController.startAction(
        name: 'ReviewStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$ReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
reviewList: ${reviewList},
selectedFilter: ${selectedFilter},
selectedRating: ${selectedRating},
reviewTextController: ${reviewTextController},
isSubmittingReview: ${isSubmittingReview},
isLoadingReviews: ${isLoadingReviews},
errorMessage: ${errorMessage},
overallRating: ${overallRating},
hasUserReviewed: ${hasUserReviewed},
currentUserReview: ${currentUserReview},
otherUserReviews: ${otherUserReviews},
averageRating: ${averageRating},
starCounts: ${starCounts},
canSubmitReview: ${canSubmitReview},
hasReviews: ${hasReviews}
    ''';
  }
}
