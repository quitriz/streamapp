import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/models/pmp_models/pmp_order_model.dart';
import 'package:streamit_flutter/main.dart';

part 'membership_store.g.dart';

class MembershipStore = MembershipStoreBase with _$MembershipStore;

abstract class MembershipStoreBase with Store {
  // Plans data
  @observable
  ObservableList<MembershipModel> plans = ObservableList<MembershipModel>();

  @observable
  MembershipModel? selectedPlan;

  @observable
  bool isError = false;

  // In-app purchase data
  @observable
  Package? selectedInAppPlan;

  @observable
  Offering? inAppOffering;

  // Loading states
  @observable
  bool isLoading = false;

  @observable
  bool isInAppLoading = false;

  // Cache management
  @observable
  bool isDataCached = false;

  @observable
  DateTime? lastCacheTime;

  // User membership data
  @observable
  MembershipModel? userMembership;

  @observable
  bool hasUserMembership = false;

  @observable
  bool membershipHasError = false;

  // Orders data
  @observable
  ObservableList<PmpOrderModel> orderList = ObservableList<PmpOrderModel>();

  @observable
  int orderPage = 1;

  @observable
  bool orderIsLastPage = false;

  @observable
  bool orderHasError = false;

  // Payment dialog state
  @observable
  int? selectedPaymentMethod;

  // Actions for plans
  @action
  void setPlans(List<MembershipModel> plansList) {
    plans.clear();
    plans.addAll(plansList);
    isDataCached = true;
    lastCacheTime = DateTime.now();
  }

  @action
  void setSelectedPlan(MembershipModel? plan) {
    selectedPlan = plan;
  }

  @action
  void setError(bool error) {
    isError = error;
  }

  @action
  void setLoading(bool loading) {
    isLoading = loading;
  }

  @action
  void setInAppLoading(bool loading) {
    isInAppLoading = loading;
  }

  @action
  void setInAppOffering(Offering? offering) {
    inAppOffering = offering;
  }

  @action
  void setSelectedInAppPlan(Package? package) {
    selectedInAppPlan = package;
  }

  @action
  void clearPlans() {
    plans.clear();
  }

  @action
  void resetState() {
    plans.clear();
    selectedPlan = null;
    isError = false;
    selectedInAppPlan = null;
    inAppOffering = null;
    isLoading = false;
    isInAppLoading = false;
    isDataCached = false;
    lastCacheTime = null;
  }

  // User membership actions
  @action
  void setUserMembership(MembershipModel? membership) => userMembership = membership;

  @action
  void setHasUserMembership(bool hasMembership) => hasUserMembership = hasMembership;

  @action
  void setMembershipError(bool hasError) => membershipHasError = hasError;

  // Orders actions
  @action
  void setOrderList(List<PmpOrderModel> orders) {
    orderList.clear();
    orderList.addAll(orders);
  }

  @action
  void addToOrderList(List<PmpOrderModel> orders) {
    orderList.addAll(orders);
  }

  @action
  void setOrderPage(int page) => orderPage = page;

  @action
  void setOrderIsLastPage(bool isLastPage) => orderIsLastPage = isLastPage;

  @action
  void setOrderError(bool hasError) => orderHasError = hasError;

  @action
  void incrementOrderPage() => orderPage++;

  // Payment dialog actions
  @action
  void setSelectedPaymentMethod(int? method) => selectedPaymentMethod = method;

  @action
  void resetUserMembershipState() {
    userMembership = null;
    hasUserMembership = false;
    membershipHasError = false;
  }

  @action
  void resetOrderState() {
    orderList.clear();
    orderPage = 1;
    orderIsLastPage = false;
    orderHasError = false;
  }

  // Cache validation
  bool get isCacheValid {
    if (lastCacheTime == null) return false;
    return DateTime.now().difference(lastCacheTime!).inMinutes < 5; // 5 minutes cache
  }

  bool get shouldRefreshData => !isDataCached || !isCacheValid;

  // Helper methods
  bool isPlanRecommended(MembershipModel plan, List<String>? requiredPlanIds) {
    if (requiredPlanIds == null || requiredPlanIds.isEmpty) {
      return false;
    }
    return requiredPlanIds.contains(plan.id.toString());
  }

  bool isUserCurrentPlan(MembershipModel plan) {
    return appStore.subscriptionPlanId.isNotEmpty && plan.id.toString() == appStore.subscriptionPlanId;
  }

  MembershipModel? getBestRecommendedPlan(List<String>? requiredPlanIds) {
    if (requiredPlanIds == null || requiredPlanIds.isEmpty) {
      return null;
    }

    List<MembershipModel> recommendedPlans = plans.where((plan) => requiredPlanIds.contains(plan.id.toString())).toList();

    if (recommendedPlans.isEmpty) return null;

    recommendedPlans.sort((a, b) => (a.billingAmount ?? 0).compareTo(b.billingAmount ?? 0));

    MembershipModel bestPlan = recommendedPlans.first;
    if (isUserCurrentPlan(bestPlan)) {
      for (MembershipModel plan in recommendedPlans) {
        if (!isUserCurrentPlan(plan)) {
          return plan;
        }
      }
      return null;
    }

    return bestPlan;
  }

  // Computed properties
  @computed
  bool get hasPlans => plans.isNotEmpty;

  @computed
  bool get hasSelectedPlan => selectedPlan != null;

  @computed
  bool get hasError => isError;

  @computed
  bool get isAnyLoading => isLoading || isInAppLoading;

  @computed
  bool get hasInAppOffering => inAppOffering != null;

  @computed
  bool get hasSelectedInAppPlan => selectedInAppPlan != null;

  // Methods for plan selection
  @action
  void selectPlan(MembershipModel plan) {
    if (!isUserCurrentPlan(plan)) {
      selectedPlan = plan;
    }
  }

  @action
  void selectPlanById(String planId) {
    if (planId.isNotEmpty && plans.any((element) => element.productId == planId)) {
      selectedPlan = plans.firstWhere((el) => el.productId == planId);
    }
  }

  @action
  void selectBestRecommendedPlan(List<String>? requiredPlanIds) {
    selectedPlan = getBestRecommendedPlan(requiredPlanIds) ?? (plans.isNotEmpty ? plans.first : null);
  }

  @action
  void findInAppPackageForSelectedPlan() {
    if (inAppOffering?.availablePackages.validate().isNotEmpty == true && selectedPlan != null) {
      String targetIdentifier = isIOS ? selectedPlan!.appStorePlanIdentifier.validate() : selectedPlan!.playStorePlanIdentifier.validate();
      int index = inAppOffering!.availablePackages.validate().indexWhere((element) => element.storeProduct.identifier == targetIdentifier);

      if (index > -1) {
        selectedInAppPlan = inAppOffering!.availablePackages.validate()[index];
      } else {
        selectedInAppPlan = null;
      }
    } else {
      selectedInAppPlan = null;
    }
  }

  @action
  void clearSelectedPlan() {
    selectedPlan = null;
  }

  @action
  void clearSelectedInAppPlan() {
    selectedInAppPlan = null;
  }

  // Validation methods
  bool isSelectedPlanActive() {
    return selectedPlan != null && selectedPlan!.id.toString() == appStore.subscriptionPlanId.trim();
  }

  bool isSelectedPlanFree() {
    return selectedPlan?.initialPayment.validate().toDouble() == 0.0;
  }

  bool isSelectedInAppPlanActive() {
    return selectedInAppPlan != null && appStore.activeSubscriptionIdentifier == selectedInAppPlan!.storeProduct.identifier;
  }
}
