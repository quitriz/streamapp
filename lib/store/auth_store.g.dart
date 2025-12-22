// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on AuthStoreBase, Store {
  Computed<bool>? _$isOldPasswordValidComputed;

  @override
  bool get isOldPasswordValid => (_$isOldPasswordValidComputed ??=
          Computed<bool>(() => super.isOldPasswordValid,
              name: 'AuthStoreBase.isOldPasswordValid'))
      .value;
  Computed<bool>? _$isNewPasswordValidComputed;

  @override
  bool get isNewPasswordValid => (_$isNewPasswordValidComputed ??=
          Computed<bool>(() => super.isNewPasswordValid,
              name: 'AuthStoreBase.isNewPasswordValid'))
      .value;
  Computed<bool>? _$isConfirmPasswordValidComputed;

  @override
  bool get isConfirmPasswordValid => (_$isConfirmPasswordValidComputed ??=
          Computed<bool>(() => super.isConfirmPasswordValid,
              name: 'AuthStoreBase.isConfirmPasswordValid'))
      .value;
  Computed<bool>? _$canSubmitChangePasswordComputed;

  @override
  bool get canSubmitChangePassword => (_$canSubmitChangePasswordComputed ??=
          Computed<bool>(() => super.canSubmitChangePassword,
              name: 'AuthStoreBase.canSubmitChangePassword'))
      .value;

  late final _$isFirstTimeAtom =
      Atom(name: 'AuthStoreBase.isFirstTime', context: context);

  @override
  bool get isFirstTime {
    _$isFirstTimeAtom.reportRead();
    return super.isFirstTime;
  }

  @override
  set isFirstTime(bool value) {
    _$isFirstTimeAtom.reportWrite(value, super.isFirstTime, () {
      super.isFirstTime = value;
    });
  }

  late final _$signInEmailAtom =
      Atom(name: 'AuthStoreBase.signInEmail', context: context);

  @override
  String get signInEmail {
    _$signInEmailAtom.reportRead();
    return super.signInEmail;
  }

  @override
  set signInEmail(String value) {
    _$signInEmailAtom.reportWrite(value, super.signInEmail, () {
      super.signInEmail = value;
    });
  }

  late final _$signInPasswordAtom =
      Atom(name: 'AuthStoreBase.signInPassword', context: context);

  @override
  String get signInPassword {
    _$signInPasswordAtom.reportRead();
    return super.signInPassword;
  }

  @override
  set signInPassword(String value) {
    _$signInPasswordAtom.reportWrite(value, super.signInPassword, () {
      super.signInPassword = value;
    });
  }

  late final _$doRememberAtom =
      Atom(name: 'AuthStoreBase.doRemember', context: context);

  @override
  bool get doRemember {
    _$doRememberAtom.reportRead();
    return super.doRemember;
  }

  @override
  set doRemember(bool value) {
    _$doRememberAtom.reportWrite(value, super.doRemember, () {
      super.doRemember = value;
    });
  }

  late final _$otpPhoneNumberAtom =
      Atom(name: 'AuthStoreBase.otpPhoneNumber', context: context);

  @override
  String get otpPhoneNumber {
    _$otpPhoneNumberAtom.reportRead();
    return super.otpPhoneNumber;
  }

  @override
  set otpPhoneNumber(String value) {
    _$otpPhoneNumberAtom.reportWrite(value, super.otpPhoneNumber, () {
      super.otpPhoneNumber = value;
    });
  }

  late final _$otpCountryCodeAtom =
      Atom(name: 'AuthStoreBase.otpCountryCode', context: context);

  @override
  String get otpCountryCode {
    _$otpCountryCodeAtom.reportRead();
    return super.otpCountryCode;
  }

  @override
  set otpCountryCode(String value) {
    _$otpCountryCodeAtom.reportWrite(value, super.otpCountryCode, () {
      super.otpCountryCode = value;
    });
  }

  late final _$otpCountryNameAtom =
      Atom(name: 'AuthStoreBase.otpCountryName', context: context);

  @override
  String get otpCountryName {
    _$otpCountryNameAtom.reportRead();
    return super.otpCountryName;
  }

  @override
  set otpCountryName(String value) {
    _$otpCountryNameAtom.reportWrite(value, super.otpCountryName, () {
      super.otpCountryName = value;
    });
  }

  late final _$otpCountryFlagAtom =
      Atom(name: 'AuthStoreBase.otpCountryFlag', context: context);

  @override
  String get otpCountryFlag {
    _$otpCountryFlagAtom.reportRead();
    return super.otpCountryFlag;
  }

  @override
  set otpCountryFlag(String value) {
    _$otpCountryFlagAtom.reportWrite(value, super.otpCountryFlag, () {
      super.otpCountryFlag = value;
    });
  }

  late final _$isOtpSentAtom =
      Atom(name: 'AuthStoreBase.isOtpSent', context: context);

  @override
  bool get isOtpSent {
    _$isOtpSentAtom.reportRead();
    return super.isOtpSent;
  }

  @override
  set isOtpSent(bool value) {
    _$isOtpSentAtom.reportWrite(value, super.isOtpSent, () {
      super.isOtpSent = value;
    });
  }

  late final _$isOtpVerifiedAtom =
      Atom(name: 'AuthStoreBase.isOtpVerified', context: context);

  @override
  bool get isOtpVerified {
    _$isOtpVerifiedAtom.reportRead();
    return super.isOtpVerified;
  }

  @override
  set isOtpVerified(bool value) {
    _$isOtpVerifiedAtom.reportWrite(value, super.isOtpVerified, () {
      super.isOtpVerified = value;
    });
  }

  late final _$otpScreenIsFirstTimeAtom =
      Atom(name: 'AuthStoreBase.otpScreenIsFirstTime', context: context);

  @override
  bool get otpScreenIsFirstTime {
    _$otpScreenIsFirstTimeAtom.reportRead();
    return super.otpScreenIsFirstTime;
  }

  @override
  set otpScreenIsFirstTime(bool value) {
    _$otpScreenIsFirstTimeAtom.reportWrite(value, super.otpScreenIsFirstTime,
        () {
      super.otpScreenIsFirstTime = value;
    });
  }

  late final _$otpRemainingTimeAtom =
      Atom(name: 'AuthStoreBase.otpRemainingTime', context: context);

  @override
  int get otpRemainingTime {
    _$otpRemainingTimeAtom.reportRead();
    return super.otpRemainingTime;
  }

  @override
  set otpRemainingTime(int value) {
    _$otpRemainingTimeAtom.reportWrite(value, super.otpRemainingTime, () {
      super.otpRemainingTime = value;
    });
  }

  late final _$otpCurrentCodeAtom =
      Atom(name: 'AuthStoreBase.otpCurrentCode', context: context);

  @override
  String get otpCurrentCode {
    _$otpCurrentCodeAtom.reportRead();
    return super.otpCurrentCode;
  }

  @override
  set otpCurrentCode(String value) {
    _$otpCurrentCodeAtom.reportWrite(value, super.otpCurrentCode, () {
      super.otpCurrentCode = value;
    });
  }

  late final _$oldPasswordAtom =
      Atom(name: 'AuthStoreBase.oldPassword', context: context);

  @override
  String get oldPassword {
    _$oldPasswordAtom.reportRead();
    return super.oldPassword;
  }

  @override
  set oldPassword(String value) {
    _$oldPasswordAtom.reportWrite(value, super.oldPassword, () {
      super.oldPassword = value;
    });
  }

  late final _$newPasswordAtom =
      Atom(name: 'AuthStoreBase.newPassword', context: context);

  @override
  String get newPassword {
    _$newPasswordAtom.reportRead();
    return super.newPassword;
  }

  @override
  set newPassword(String value) {
    _$newPasswordAtom.reportWrite(value, super.newPassword, () {
      super.newPassword = value;
    });
  }

  late final _$confirmPasswordAtom =
      Atom(name: 'AuthStoreBase.confirmPassword', context: context);

  @override
  String get confirmPassword {
    _$confirmPasswordAtom.reportRead();
    return super.confirmPassword;
  }

  @override
  set confirmPassword(String value) {
    _$confirmPasswordAtom.reportWrite(value, super.confirmPassword, () {
      super.confirmPassword = value;
    });
  }

  late final _$isChangePasswordLoadingAtom =
      Atom(name: 'AuthStoreBase.isChangePasswordLoading', context: context);

  @override
  bool get isChangePasswordLoading {
    _$isChangePasswordLoadingAtom.reportRead();
    return super.isChangePasswordLoading;
  }

  @override
  set isChangePasswordLoading(bool value) {
    _$isChangePasswordLoadingAtom
        .reportWrite(value, super.isChangePasswordLoading, () {
      super.isChangePasswordLoading = value;
    });
  }

  late final _$changePasswordFormIsValidAtom =
      Atom(name: 'AuthStoreBase.changePasswordFormIsValid', context: context);

  @override
  bool get changePasswordFormIsValid {
    _$changePasswordFormIsValidAtom.reportRead();
    return super.changePasswordFormIsValid;
  }

  @override
  set changePasswordFormIsValid(bool value) {
    _$changePasswordFormIsValidAtom
        .reportWrite(value, super.changePasswordFormIsValid, () {
      super.changePasswordFormIsValid = value;
    });
  }

  late final _$setRememberAsyncAction =
      AsyncAction('AuthStoreBase.setRemember', context: context);

  @override
  Future<void> setRemember(bool val) {
    return _$setRememberAsyncAction.run(() => super.setRemember(val));
  }

  late final _$AuthStoreBaseActionController =
      ActionController(name: 'AuthStoreBase', context: context);

  @override
  void setIsFirstTime(bool value) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setIsFirstTime');
    try {
      return super.setIsFirstTime(value);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSignInEmail(String email) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setSignInEmail');
    try {
      return super.setSignInEmail(email);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSignInPassword(String password) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setSignInPassword');
    try {
      return super.setSignInPassword(password);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetSignInForm() {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.resetSignInForm');
    try {
      return super.resetSignInForm();
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpPhoneNumber(String phoneNumber) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpPhoneNumber');
    try {
      return super.setOtpPhoneNumber(phoneNumber);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpCountryCode(String countryCode) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpCountryCode');
    try {
      return super.setOtpCountryCode(countryCode);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpCountryName(String countryName) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpCountryName');
    try {
      return super.setOtpCountryName(countryName);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpCountryFlag(String countryFlag) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpCountryFlag');
    try {
      return super.setOtpCountryFlag(countryFlag);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpCountry(
      String countryCode, String countryName, String countryFlag) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpCountry');
    try {
      return super.setOtpCountry(countryCode, countryName, countryFlag);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpSent(bool sent) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpSent');
    try {
      return super.setOtpSent(sent);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpVerified(bool verified) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpVerified');
    try {
      return super.setOtpVerified(verified);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpScreenIsFirstTime(bool value) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpScreenIsFirstTime');
    try {
      return super.setOtpScreenIsFirstTime(value);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpRemainingTime(int time) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpRemainingTime');
    try {
      return super.setOtpRemainingTime(time);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpCurrentCode(String code) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOtpCurrentCode');
    try {
      return super.setOtpCurrentCode(code);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetOtpState() {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.resetOtpState');
    try {
      return super.resetOtpState();
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOldPassword(String password) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setOldPassword');
    try {
      return super.setOldPassword(password);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewPassword(String password) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setNewPassword');
    try {
      return super.setNewPassword(password);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setConfirmPassword(String password) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setConfirmPassword');
    try {
      return super.setConfirmPassword(password);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChangePasswordLoading(bool loading) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setChangePasswordLoading');
    try {
      return super.setChangePasswordLoading(loading);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _validateChangePasswordForm() {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase._validateChangePasswordForm');
    try {
      return super._validateChangePasswordForm();
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetChangePasswordForm() {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.resetChangePasswordForm');
    try {
      return super.resetChangePasswordForm();
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isFirstTime: ${isFirstTime},
signInEmail: ${signInEmail},
signInPassword: ${signInPassword},
doRemember: ${doRemember},
otpPhoneNumber: ${otpPhoneNumber},
otpCountryCode: ${otpCountryCode},
otpCountryName: ${otpCountryName},
otpCountryFlag: ${otpCountryFlag},
isOtpSent: ${isOtpSent},
isOtpVerified: ${isOtpVerified},
otpScreenIsFirstTime: ${otpScreenIsFirstTime},
otpRemainingTime: ${otpRemainingTime},
otpCurrentCode: ${otpCurrentCode},
oldPassword: ${oldPassword},
newPassword: ${newPassword},
confirmPassword: ${confirmPassword},
isChangePasswordLoading: ${isChangePasswordLoading},
changePasswordFormIsValid: ${changePasswordFormIsValid},
isOldPasswordValid: ${isOldPasswordValid},
isNewPasswordValid: ${isNewPasswordValid},
isConfirmPasswordValid: ${isConfirmPasswordValid},
canSubmitChangePassword: ${canSubmitChangePassword}
    ''';
  }
}
