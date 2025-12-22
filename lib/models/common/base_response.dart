class BaseResponseModel {
  String? message;
  String? statusCode;
  bool? success;
  String? code;

  BaseResponseModel({
    this.message,
    this.statusCode,
    this.success,
    this.code,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    bool? parseSuccess(dynamic status) {
      if (status == null) return null;
      if (status is bool) return status;
      if (status is String) {
        return status.toLowerCase() == 'success' || status.toLowerCase() == 'true' || status == '1';
      }
      return null;
    }

    return BaseResponseModel(
      message: json['message'],
      statusCode: json['statusCode'],
      success: parseSuccess(json['status']),
      code: json['code'],

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.success;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
