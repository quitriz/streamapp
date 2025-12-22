// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MembershipStore on MembershipStoreBase, Store {
  Computed<bool>? _$hasPlansComputed;

  @override
  bool get hasPlans =>
      (_$hasPlansComputed ??= Computed<bool>(() => super.hasPlans,
              name: 'MembershipStoreBase.hasPlans'))
          .value;
  Computed<bool>? _$hasSelectedPlanComputed;

  @override
  bool get hasSelectedPlan =>
      (_$hasSelectedPlanComputed ??= Computed<bool>(() => super.hasSelectedPlan,
              name: 'MembershipStoreBase.hasSelectedPlan'))
          .value;
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError =>
      (_$hasErrorComputed ??= Computed<bool>(() => super.hasError,
              name: 'MembershipStoreBase.hasError'))
          .value;
  Computed<bool>? _$isAnyLoadingComputed;

  @override
  bool get isAnyLoading =>
      (_$isAnyLoadingComputed ??= Computed<bool>(() => super.isAnyLoading,
              name: 'MembershipStoreBase.isAnyLoading'))
          .value;
  Computed<bool>? _$hasInAppOfferingComputed;

  @override
  bool get hasInAppOffering => (_$hasInAppOfferingComputed ??= Computed<bool>(
          () => super.hasInAppOffering,
          name: 'MembershipStoreBase.hasInAppOffering'))
      .value;
  Computed<bool>? _$hasSelectedInAppPlanComputed;

  @override
  bool get hasSelectedInAppPlan => (_$hasSelectedInAppPlanComputed ??=
          Computed<bool>(() => super.hasSelectedInAppPlan,
              name: 'MembershipStoreBase.hasSelectedInAppPlan'))
      .value;

  late final _$plansAtom =
      Atom(name: 'MembershipStoreBase.plans', context: context);

  @override
  ObservableList<MembershipModel> get plans {
    _$plansAtom.reportRead();
    return super.plans;
  }

  @override
  set plans(ObservableList<MembershipModel> value) {
    _$plansAtom.reportWrite(value, super.plans, () {
      super.plans = value;
    });
  }

  late final _$selectedPlanAtom =
      Atom(name: 'MembershipStoreBase.selectedPlan', context: context);

  @override
  MembershipModel? get selectedPlan {
    _$selectedPlanAtom.reportRead();
    return super.selectedPlan;
  }

  @override
  set selectedPlan(MembershipModel? value) {
    _$selectedPlanAtom.reportWrite(value, super.selectedPlan, () {
      super.selectedPlan = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: 'MembershipStoreBase.isError', context: context);

  @override
  bool get isError {
    _$isErrorAtom.reportRead();
    return super.isError;
  }

  @override
  set isError(bool value) {
    _$isErrorAtom.reportWrite(value, super.isError, () {
      super.isError = value;
    });
  }

  late final _$selectedInAppPlanAtom =
      Atom(name: 'MembershipStoreBase.selectedInAppPlan', context: context);

  @override
  Package? get selectedInAppPlan {
    _$selectedInAppPlanAtom.reportRead();
    return super.selectedInAppPlan;
  }

  @override
  set selectedInAppPlan(Package? value) {
    _$selectedInAppPlanAtom.reportWrite(value, super.selectedInAppPlan, () {
      super.selectedInAppPlan = value;
    });
  }

  late final _$inAppOfferingAtom =
      Atom(name: 'MembershipStoreBase.inAppOffering', context: context);

  @override
  Offering? get inAppOffering {
    _$inAppOfferingAtom.reportRead();
    return super.inAppOffering;
  }

  @override
  set inAppOffering(Offering? value) {
    _$inAppOfferingAtom.reportWrite(value, super.inAppOffering, () {
      super.inAppOffering = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'MembershipStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isInAppLoadingAtom =
      Atom(name: 'MembershipStoreBase.isInAppLoading', context: context);

  @override
  bool get isInAppLoading {
    _$isInAppLoadingAtom.reportRead();
    return super.isInAppLoading;
  }

  @override
  set isInAppLoading(bool value) {
    _$isInAppLoadingAtom.reportWrite(value, super.isInAppLoading, () {
      super.isInAppLoading = value;
    });
  }

  late final _$isDataCachedAtom =
      Atom(name: 'MembershipStoreBase.isDataCached', context: context);

  @override
  bool get isDataCached {
    _$isDataCachedAtom.reportRead();
    return super.isDataCached;
  }

  @override
  set isDataCached(bool value) {
    _$isDataCachedAtom.reportWrite(value, super.isDataCached, () {
      super.isDataCached = value;
    });
  }

  late final _$lastCacheTimeAtom =
      Atom(name: 'MembershipStoreBase.lastCacheTime', context: context);

  @override
  DateTime? get lastCacheTime {
    _$lastCacheTimeAtom.reportRead();
    return super.lastCacheTime;
  }

  @override
  set lastCacheTime(DateTime? value) {
    _$lastCacheTimeAtom.reportWrite(value, super.lastCacheTime, () {
      super.lastCacheTime = value;
    });
  }

  late final _$userMembershipAtom =
      Atom(name: 'MembershipStoreBase.userMembership', context: context);

  @override
  MembershipModel? get userMembership {
    _$userMembershipAtom.reportRead();
    return super.userMembership;
  }

  @override
  set userMembership(MembershipModel? value) {
    _$userMembershipAtom.reportWrite(value, super.userMembership, () {
      super.userMembership = value;
    });
  }

  late final _$hasUserMembershipAtom =
      Atom(name: 'MembershipStoreBase.hasUserMembership', context: context);

  @override
  bool get hasUserMembership {
    _$hasUserMembershipAtom.reportRead();
    return super.hasUserMembership;
  }

  @override
  set hasUserMembership(bool value) {
    _$hasUserMembershipAtom.reportWrite(value, super.hasUserMembership, () {
      super.hasUserMembership = value;
    });
  }

  late final _$membershipHasErrorAtom =
      Atom(name: 'MembershipStoreBase.membershipHasError', context: context);

  @override
  bool get membershipHasError {
    _$membershipHasErrorAtom.reportRead();
    return super.membershipHasError;
  }

  @override
  set membershipHasError(bool value) {
    _$membershipHasErrorAtom.reportWrite(value, super.membershipHasError, () {
      super.membershipHasError = value;
    });
  }

  late final _$orderListAtom =
      Atom(name: 'MembershipStoreBase.orderList', context: context);

  @override
  ObservableList<PmpOrderModel> get orderList {
    _$orderListAtom.reportRead();
    return super.orderList;
  }

  @override
  set orderList(ObservableList<PmpOrderModel> value) {
    _$orderListAtom.reportWrite(value, super.orderList, () {
      super.orderList = value;
    });
  }

  late final _$orderPageAtom =
      Atom(name: 'MembershipStoreBase.orderPage', context: context);

  @override
  int get orderPage {
    _$orderPageAtom.reportRead();
    return super.orderPage;
  }

  @override
  set orderPage(int value) {
    _$orderPageAtom.reportWrite(value, super.orderPage, () {
      super.orderPage = value;
    });
  }

  late final _$orderIsLastPageAtom =
      Atom(name: 'MembershipStoreBase.orderIsLastPage', context: context);

  @override
  bool get orderIsLastPage {
    _$orderIsLastPageAtom.reportRead();
    return super.orderIsLastPage;
  }

  @override
  set orderIsLastPage(bool value) {
    _$orderIsLastPageAtom.reportWrite(value, super.orderIsLastPage, () {
      super.orderIsLastPage = value;
    });
  }

  late final _$orderHasErrorAtom =
      Atom(name: 'MembershipStoreBase.orderHasError', context: context);

  @override
  bool get orderHasError {
    _$orderHasErrorAtom.reportRead();
    return super.orderHasError;
  }

  @override
  set orderHasError(bool value) {
    _$orderHasErrorAtom.reportWrite(value, super.orderHasError, () {
      super.orderHasError = value;
    });
  }

  late final _$selectedPaymentMethodAtom =
      Atom(name: 'MembershipStoreBase.selectedPaymentMethod', context: context);

  @override
  int? get selectedPaymentMethod {
    _$selectedPaymentMethodAtom.reportRead();
    return super.selectedPaymentMethod;
  }

  @override
  set selectedPaymentMethod(int? value) {
    _$selectedPaymentMethodAtom.reportWrite(value, super.selectedPaymentMethod,
        () {
      super.selectedPaymentMethod = value;
    });
  }

  late final _$MembershipStoreBaseActionController =
      ActionController(name: 'MembershipStoreBase', context: context);

  @override
  void setPlans(List<MembershipModel> plansList) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setPlans');
    try {
      return super.setPlans(plansList);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedPlan(MembershipModel? plan) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setSelectedPlan');
    try {
      return super.setSelectedPlan(plan);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(bool error) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setError');
    try {
      return super.setError(error);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool loading) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setLoading');
    try {
      return super.setLoading(loading);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setInAppLoading(bool loading) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setInAppLoading');
    try {
      return super.setInAppLoading(loading);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setInAppOffering(Offering? offering) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setInAppOffering');
    try {
      return super.setInAppOffering(offering);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedInAppPlan(Package? package) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setSelectedInAppPlan');
    try {
      return super.setSelectedInAppPlan(package);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPlans() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.clearPlans');
    try {
      return super.clearPlans();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetState() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.resetState');
    try {
      return super.resetState();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserMembership(MembershipModel? membership) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setUserMembership');
    try {
      return super.setUserMembership(membership);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHasUserMembership(bool hasMembership) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setHasUserMembership');
    try {
      return super.setHasUserMembership(hasMembership);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMembershipError(bool hasError) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setMembershipError');
    try {
      return super.setMembershipError(hasError);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOrderList(List<PmpOrderModel> orders) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setOrderList');
    try {
      return super.setOrderList(orders);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addToOrderList(List<PmpOrderModel> orders) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.addToOrderList');
    try {
      return super.addToOrderList(orders);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOrderPage(int page) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setOrderPage');
    try {
      return super.setOrderPage(page);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOrderIsLastPage(bool isLastPage) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setOrderIsLastPage');
    try {
      return super.setOrderIsLastPage(isLastPage);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOrderError(bool hasError) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setOrderError');
    try {
      return super.setOrderError(hasError);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void incrementOrderPage() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.incrementOrderPage');
    try {
      return super.incrementOrderPage();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedPaymentMethod(int? method) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.setSelectedPaymentMethod');
    try {
      return super.setSelectedPaymentMethod(method);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetUserMembershipState() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.resetUserMembershipState');
    try {
      return super.resetUserMembershipState();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetOrderState() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.resetOrderState');
    try {
      return super.resetOrderState();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectPlan(MembershipModel plan) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.selectPlan');
    try {
      return super.selectPlan(plan);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectPlanById(String planId) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.selectPlanById');
    try {
      return super.selectPlanById(planId);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectBestRecommendedPlan(List<String>? requiredPlanIds) {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.selectBestRecommendedPlan');
    try {
      return super.selectBestRecommendedPlan(requiredPlanIds);
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void findInAppPackageForSelectedPlan() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.findInAppPackageForSelectedPlan');
    try {
      return super.findInAppPackageForSelectedPlan();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedPlan() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.clearSelectedPlan');
    try {
      return super.clearSelectedPlan();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedInAppPlan() {
    final _$actionInfo = _$MembershipStoreBaseActionController.startAction(
        name: 'MembershipStoreBase.clearSelectedInAppPlan');
    try {
      return super.clearSelectedInAppPlan();
    } finally {
      _$MembershipStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
plans: ${plans},
selectedPlan: ${selectedPlan},
isError: ${isError},
selectedInAppPlan: ${selectedInAppPlan},
inAppOffering: ${inAppOffering},
isLoading: ${isLoading},
isInAppLoading: ${isInAppLoading},
isDataCached: ${isDataCached},
lastCacheTime: ${lastCacheTime},
userMembership: ${userMembership},
hasUserMembership: ${hasUserMembership},
membershipHasError: ${membershipHasError},
orderList: ${orderList},
orderPage: ${orderPage},
orderIsLastPage: ${orderIsLastPage},
orderHasError: ${orderHasError},
selectedPaymentMethod: ${selectedPaymentMethod},
hasPlans: ${hasPlans},
hasSelectedPlan: ${hasSelectedPlan},
hasError: ${hasError},
isAnyLoading: ${isAnyLoading},
hasInAppOffering: ${hasInAppOffering},
hasSelectedInAppPlan: ${hasSelectedInAppPlan}
    ''';
  }
}
