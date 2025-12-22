
import '../common/base_response.dart';
import 'user_plan.dart';

class LoginResponse extends BaseResponseModel {
  String? firstName;
  String? lastName;
  String? profileImage;
  String? token;
  String? userEmail;
  int? userId;
  String? userNiceName;
  Subscription? plan;
  String? username;
  String? loginType;

  LoginResponse({
    this.firstName,
    this.lastName,
    this.profileImage,
    this.token,
    this.userEmail,
    this.userId,
    this.userNiceName,
    this.plan,
    this.username,
    this.loginType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      token: json['token'],
      userEmail: json['email'], // Changed from 'user_email' to 'email' to match API response
      userId: json['user_id'],
      userNiceName: json['user_nicename'],
      plan: json['plan'] != null && json['plan'].runtimeType != (List<dynamic>) ? Subscription.fromJson(json['plan']) : null,
      username: json['username'],
      loginType: json['login_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['profile_image'] = this.profileImage;
    data['token'] = this.token;
    data['user_email'] = this.userEmail;
    data['user_id'] = this.userId;
    data['user_nicename'] = this.userNiceName;
    if (data['plan'] != null) {
      data['plan'] = this.plan;
    }
    data['username'] = this.username;
    data['login_type'] = this.loginType;
    return data;
  }
}
