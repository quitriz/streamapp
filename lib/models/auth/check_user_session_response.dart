class CheckUserSessionResponse {
  final bool status;
  final String? message;
  final String? errorCode;
  final CheckUserData? data;

  bool get isSuccess => status;

  CheckUserSessionResponse({
    required this.status,
    this.message,
    this.errorCode,
    this.data,
  });

  factory CheckUserSessionResponse.fromJson(Map<String, dynamic> json) {
    return CheckUserSessionResponse(
      status: json['status'] == true,
      message: json['message'] as String?,
      errorCode: json['error_code'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? CheckUserData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CheckUserData {
  final int? userId;
  final String? username;
  final String? email;

  CheckUserData({
    this.userId,
    this.username,
    this.email,
  });

  factory CheckUserData.fromJson(Map<String, dynamic> json) {
    return CheckUserData(
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse('${json['user_id']}'),
      username: json['username'] as String?,
      email: json['email'] as String?,
    );
  }
}

