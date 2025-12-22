class OnBoardingListModel {
    bool? status;
    String? message;
    List<OnBoardingData>? data;

    OnBoardingListModel({
        this.status,
        this.message,
        this.data,
    });

    factory OnBoardingListModel.fromJson(Map<String, dynamic> json) => OnBoardingListModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<OnBoardingData>.from(json["data"]!.map((x) => OnBoardingData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class OnBoardingData {
    String? image;
    String? title;
    String? description;

    OnBoardingData({
        this.image,
        this.title,
        this.description,
    });

    factory OnBoardingData.fromJson(Map<String, dynamic> json) => OnBoardingData(
        image: json["image"],
        title: json["title"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "image": image,
        "title": title,
        "description": description,
    };
}
