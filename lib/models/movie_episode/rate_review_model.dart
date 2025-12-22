class RateReviewModel {
  bool? status;
  String? message;
  Data? data;

  RateReviewModel({
    this.status,
    this.message,
    this.data,
  });

  factory RateReviewModel.fromJson(Map<String, dynamic> json) => RateReviewModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  List<Review>? reviews;
  RatingSummary? ratingSummary;

  Data({
    this.reviews,
    this.ratingSummary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        reviews: json["reviews"] == null ? [] : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
        ratingSummary: json["rating_summary"] == null ? null : RatingSummary.fromJson(json["rating_summary"]),
      );

  Map<String, dynamic> toJson() => {
        "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x.toJson())),
        "rating_summary": ratingSummary?.toJson(),
      };
}

class RatingSummary {
  num? overallRating;
  int? totalRatings;
  RatingDistribution? ratingDistribution;

  RatingSummary({
    this.overallRating,
    this.totalRatings,
    this.ratingDistribution,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) => RatingSummary(
        overallRating: json["overall_rating"],
        totalRatings: json["total_ratings"],
        ratingDistribution: json["rating_distribution"] == null ? null : RatingDistribution.fromJson(json["rating_distribution"]),
      );

  Map<String, dynamic> toJson() => {
        "overall_rating": overallRating,
        "total_ratings": totalRatings,
        "rating_distribution": ratingDistribution?.toJson(),
      };
}

class RatingDistribution {
  int? the5Stars;
  int? the4Stars;
  int? the3Stars;
  int? the2Stars;
  int? the1Star;

  RatingDistribution({
    this.the5Stars,
    this.the4Stars,
    this.the3Stars,
    this.the2Stars,
    this.the1Star,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) => RatingDistribution(
        the5Stars: json["5_stars"],
        the4Stars: json["4_stars"],
        the3Stars: json["3_stars"],
        the2Stars: json["2_stars"],
        the1Star: json["1_star"],
      );

  Map<String, dynamic> toJson() => {
        "5_stars": the5Stars,
        "4_stars": the4Stars,
        "3_stars": the3Stars,
        "2_stars": the2Stars,
        "1_star": the1Star,
      };
}

class Review {
  String? userImage;
  String? userName;
  String? rateContent;
  int? rate;
  String? date;
  int? rateId;
  int? userId;

  Review({
    this.userImage,
    this.userName,
    this.rateContent,
    this.rate,
    this.date,
    this.rateId,
    this.userId,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        userImage: json["user_image"],
        userName: json["user_name"],
        rateContent: json["rate_content"],
        rate: json["rate"],
        date: json["date"],
        rateId: json["rate_id"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_image": userImage,
        "user_name": userName,
        "rate_content": rateContent,
        "rate": rate,
        "date": date,
        "rate_id": rateId,
        "user_id": userId,
      };
}
