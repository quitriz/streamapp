import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/movie_episode/rate_review_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';

part 'review_store.g.dart';

class ReviewStore = ReviewStoreBase with _$ReviewStore;

abstract class ReviewStoreBase with Store {
  //region Observable Properties

  @observable
  ObservableList<Review> reviewList = ObservableList<Review>();

  @observable
  ReviewFilter selectedFilter = ReviewFilter.all;

  @observable
  double selectedRating = 0.0;

  @observable
  TextEditingController reviewTextController = TextEditingController();

  @observable
  bool isSubmittingReview = false;

  @observable
  bool isLoadingReviews = false;

  @observable
  String? errorMessage;

  @observable
  double? overallRating;

  //endregion

  //region Actions

  @action
  void setSelectedFilter(ReviewFilter filter) {
    selectedFilter = filter;
  }

  @action
  void setSelectedRating(double rating) {
    selectedRating = rating;
  }

  @action
  void setReviewText(String text) {
    reviewTextController.text = text;
  }

  @action
  void setIsSubmittingReview(bool value) {
    isSubmittingReview = value;
  }

  @action
  void setIsLoadingReviews(bool value) {
    isLoadingReviews = value;
  }

  @action
  void setErrorMessage(String? message) {
    errorMessage = message;
  }

  @action
  void setOverallRating(double? rating) {
    overallRating = rating;
  }

  @action
  void clearReviewForm() {
    selectedRating = 0.0;
    reviewTextController.clear();
    errorMessage = null;
  }

  @action
  void setReviewList(List<Review> reviews) {
    reviewList.clear();
    reviewList.addAll(reviews);
  }

  @action
  void addReviewToList(Review review) {
    // Remove existing review by same user if exists
    reviewList.removeWhere((r) => r.userId == review.userId);
    reviewList.insert(0, review);
  }

  @action
  void updateReviewInList(Review updatedReview) {
    final index = reviewList.indexWhere((r) => r.rateId == updatedReview.rateId);
    if (index != -1) {
      reviewList[index] = updatedReview;
    }
  }

  @action
  void removeReviewFromList(int rateId) {
    reviewList.removeWhere((r) => r.rateId == rateId);
  }

  //endregion

  //region Computed Properties

  @computed
  bool get hasUserReviewed {
    final currentUserId = getIntAsync(USER_ID);
    return reviewList.any((review) => review.userId == currentUserId);
  }

  @computed
  Review? get currentUserReview {
    final currentUserId = getIntAsync(USER_ID);
    try {
      return reviewList.firstWhere((review) => review.userId == currentUserId);
    } catch (e) {
      return null;
    }
  }

  @computed
  List<Review> get otherUserReviews {
    final currentUserId = getIntAsync(USER_ID);
    return reviewList.where((review) => review.userId != currentUserId).toList();
  }

  @computed
  double get averageRating {
    if (reviewList.isEmpty) return 0.0;
    final totalRating = reviewList.map((r) => r.rate ?? 0).fold(0, (prev, rate) => prev + rate);
    return totalRating / reviewList.length;
  }

  @computed
  Map<int, int> get starCounts {
    final counts = <int, int>{};
    for (int i = 5; i >= 1; i--) {
      counts[i] = reviewList.where((r) => r.rate == i).length;
    }
    return counts;
  }

  @computed
  bool get canSubmitReview {
    return (selectedRating > 0 || reviewTextController.text.trim().isNotEmpty) &&
        !isSubmittingReview &&
        !hasUserReviewed;
  }

  @computed
  bool get hasReviews => reviewList.isNotEmpty;

  //endregion

  //region Methods

  /// Fetches reviews from the API based on the selected filter
  @action
  Future<void> fetchReviews({
    required String postType,
    required int postId,
    ReviewFilter? filter,
  }) async {
    setIsLoadingReviews(true);
    setErrorMessage(null);

    try {
      final res = await getRateReviews(
        postType: postType,
        postId: postId,
        filter: filter ?? selectedFilter,
      );

      if (res.data?.reviews != null) {
        setReviewList(res.data!.reviews!);
      } else {
        setReviewList([]);
        log('No reviews found in response for filter: ${(filter ?? selectedFilter).name}');
      }
    } catch (e) {
      setErrorMessage('Failed to fetch reviews: $e');
      log('Failed to fetch reviews: $e');
    } finally {
      setIsLoadingReviews(false);
    }
  }

  /// Submits a new review
  @action
  Future<bool> submitReview({
    required int postId,
    required String postType,
    required String userName,
    required String userEmail,
  }) async {
    if (!canSubmitReview) return false;

    setIsSubmittingReview(true);
    setErrorMessage(null);

    try {
      final request = {
        'post_id': postId,
        'user_name': userName,
        'user_email': userEmail,
        'rating': selectedRating,
        'cm_details': reviewTextController.text.trim(),
      };

      await addReview(request, postType.toLowerCase());

      // Clear form on success
      clearReviewForm();

      return true;
    } catch (e) {
      setErrorMessage('Failed to submit review: $e');
      log('Failed to submit review: $e');
      return false;
    } finally {
      setIsSubmittingReview(false);
    }
  }

  /// Updates an existing review
  @action
  Future<bool> updateReview({
    required int postId,
    required String postType,
    required String userName,
    required String userEmail,
    required int rateId,
    required double rating,
    required String reviewText,
  }) async {
    setIsSubmittingReview(true);
    setErrorMessage(null);

    try {
      final request = {
        'post_id': postId,
        'user_name': userName,
        'user_email': userEmail,
        'rating': rating,
        'cm_details': reviewText,
        'rate_id': rateId,
      };

      await addReview(request, postType.toLowerCase());

      return true;
    } catch (e) {
      setErrorMessage('Failed to update review: $e');
      log('Failed to update review: $e');
      return false;
    } finally {
      setIsSubmittingReview(false);
    }
  }

  /// Deletes a review
  @action
  Future<bool> deleteReview({
    required int postId,
    required String postType,
    required int rateId,
  }) async {
    setIsSubmittingReview(true);
    setErrorMessage(null);

    try {
      final request = {
        'post_id': postId,
        'user_id': getIntAsync(USER_ID).toString(),
        'rate_id': rateId,
      };

      await addReview(request, postType.toLowerCase(), method: "delete");

      return true;
    } catch (e) {
      setErrorMessage('Failed to delete review: $e');
      log('Failed to delete review: $e');
      return false;
    } finally {
      setIsSubmittingReview(false);
    }
  }

  /// Resets the store state
  @action
  void reset() {
    reviewList.clear();
    selectedFilter = ReviewFilter.all;
    clearReviewForm();
    setIsLoadingReviews(false);
    setIsSubmittingReview(false);
    setErrorMessage(null);
  }

  //endregion
}
