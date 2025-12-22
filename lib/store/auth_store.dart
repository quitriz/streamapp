import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/utils/constants.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  
  //region Sign In State

  @observable
  bool isFirstTime = true;

  @observable
  String signInEmail = '';

  @observable
  String signInPassword = '';

  @observable
  bool doRemember = false;

  @action
  void setIsFirstTime(bool value) {
    isFirstTime = value;
  }

  @action
  void setSignInEmail(String email) {
    signInEmail = email;
  }

  @action
  void setSignInPassword(String password) {
    signInPassword = password;
  }

  @action
  Future<void> setRemember(bool val) async {
    doRemember = val;
    await setValue('REMEMBER_ME', val);
  }

  @action
  void resetSignInForm() {
    isFirstTime = true;
    signInEmail = '';
    signInPassword = '';
  }

  //endregion

  //region OTP Login State

  @observable
  String otpPhoneNumber = '';

  @observable
  String otpCountryCode = '+91';

  @observable
  String otpCountryName = 'India';

  @observable
  String otpCountryFlag = '🇮🇳';

  @observable
  bool isOtpSent = false;

  @observable
  bool isOtpVerified = false;

  @observable
  bool otpScreenIsFirstTime = true;

  @observable
  int otpRemainingTime = 60;

  @observable
  String otpCurrentCode = '';

  @action
  void setOtpPhoneNumber(String phoneNumber) {
    otpPhoneNumber = phoneNumber;
  }

  @action
  void setOtpCountryCode(String countryCode) {
    otpCountryCode = countryCode;
  }

  @action
  void setOtpCountryName(String countryName) {
    otpCountryName = countryName;
  }

  @action
  void setOtpCountryFlag(String countryFlag) {
    otpCountryFlag = countryFlag;
  }

  @action
  void setOtpCountry(String countryCode, String countryName, String countryFlag) {
    otpCountryCode = countryCode;
    otpCountryName = countryName;
    otpCountryFlag = countryFlag;
  }

  @action
  void setOtpSent(bool sent) {
    isOtpSent = sent;
  }

  @action
  void setOtpVerified(bool verified) {
    isOtpVerified = verified;
  }

  @action
  void setOtpScreenIsFirstTime(bool value) {
    otpScreenIsFirstTime = value;
  }

  @action
  void setOtpRemainingTime(int time) {
    otpRemainingTime = time;
  }

  @action
  void setOtpCurrentCode(String code) {
    otpCurrentCode = code;
  }

  @action
  void resetOtpState() {
    otpPhoneNumber = DEFAULT_PHONE;
    otpCountryCode = '+91';
    otpCountryName = 'India';
    otpCountryFlag = '🇮🇳';
    isOtpSent = false;
    isOtpVerified = false;
    otpScreenIsFirstTime = true;
    otpRemainingTime = 60;
    otpCurrentCode = '';
  }

  //endregion

  //region Change Password State

  @observable
  String oldPassword = '';

  @observable
  String newPassword = '';

  @observable
  String confirmPassword = '';

  @observable
  bool isChangePasswordLoading = false;

  @observable
  bool changePasswordFormIsValid = false;

  @action
  void setOldPassword(String password) {
    oldPassword = password;
    _validateChangePasswordForm();
  }

  @action
  void setNewPassword(String password) {
    newPassword = password;
    _validateChangePasswordForm();
  }

  @action
  void setConfirmPassword(String password) {
    confirmPassword = password;
    _validateChangePasswordForm();
  }

  @action
  void setChangePasswordLoading(bool loading) {
    isChangePasswordLoading = loading;
  }

  @action
  void _validateChangePasswordForm() {
    changePasswordFormIsValid = oldPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword.length >= passwordLength &&
        confirmPassword.length >= passwordLength &&
        newPassword == confirmPassword &&
        oldPassword != newPassword;
  }

  @action
  void resetChangePasswordForm() {
    oldPassword = '';
    newPassword = '';
    confirmPassword = '';
    isChangePasswordLoading = false;
    changePasswordFormIsValid = false;
  }

  // Computed getters for validation
  @computed
  bool get isOldPasswordValid => oldPassword.isNotEmpty && oldPassword.length >= passwordLength;

  @computed
  bool get isNewPasswordValid => newPassword.isNotEmpty && newPassword.length >= passwordLength && newPassword != oldPassword;

  @computed
  bool get isConfirmPasswordValid => confirmPassword.isNotEmpty && confirmPassword.length >= passwordLength && confirmPassword == newPassword;

  @computed
  bool get canSubmitChangePassword => changePasswordFormIsValid && !isChangePasswordLoading;

  //endregion
}
