import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/pmp_models/membership_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/web_view_screen.dart';
import 'package:streamit_flutter/screens/woo_commerce/woo_commerce_screen.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class MembershipPlansScreen extends StatefulWidget {
  final String? selectedPlanId;
  final List<String>? requiredPlanIds;

  const MembershipPlansScreen({Key? key, this.selectedPlanId, this.requiredPlanIds}) : super(key: key);

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  @override
  void initState() {
    super.initState();
    if (membershipStore.shouldRefreshData) {
      membershipStore.resetState();
    }
    _preloadData();
  }

  Future<void> _preloadData() async {
    getPlansList();
    if (coreStore.isInAppPurchaseEnabled) {
      getInAppPlan();
    }
  }

  ///Helper methods to determine plan status
  bool _isPlanRecommended(MembershipModel plan) {
    return membershipStore.isPlanRecommended(plan, widget.requiredPlanIds);
  }

  ///Helper method to check if the user is on the current plan
  bool _isUserCurrentPlan(MembershipModel plan) {
    return membershipStore.isUserCurrentPlan(plan);
  }

  ///Helper method to check if plan has recurring billing
  bool _hasRecurringBilling(MembershipModel plan) {
    return (plan.billingAmount != null && plan.billingAmount!.validate().toDouble() > 0) ||
        (plan.cycleNumber != null && plan.cycleNumber!.validate().isNotEmpty && plan.cycleNumber!.validate() != "0") ||
        (plan.cyclePeriod != null && plan.cyclePeriod!.validate().isNotEmpty && plan.cyclePeriod!.validate() != "0") ||
        (plan.billingLimit != null && plan.billingLimit!.validate().isNotEmpty && plan.billingLimit!.validate() != "0");
  }

  ///Helper method to check if expiry data exists (both expirationNumber and expirationPeriod are non-empty)
  bool _hasExpiryData(MembershipModel plan) {
    String expirationNumber = plan.expirationNumber.validate();
    String expirationPeriod = plan.expirationPeriod.validate();
    return expirationNumber.isNotEmpty && expirationNumber != "0" && 
           expirationPeriod.isNotEmpty && expirationPeriod != "0";
  }

  Future<void> getInAppPlan() async {
    membershipStore.setInAppLoading(true);
    try {
      final offering = await InAppPurchaseService.getMembershipPlanList();
      if (offering.current != null) {
        membershipStore.setInAppOffering(offering.current!);
      }
    } catch (e) {
      log('Error loading in-app plans: ${e.toString()}');
    } finally {
      membershipStore.setInAppLoading(false);
    }
  }

  Future<void> getInAppPackageForSelectedPlan() async {
    try {
      // Check if in-app offering is loaded
      if (!membershipStore.hasInAppOffering) {
        // Try to load in-app offering first
        await getInAppPlan();
      }

      membershipStore.findInAppPackageForSelectedPlan();

      if (membershipStore.hasSelectedInAppPlan) {
        if (membershipStore.isSelectedInAppPlanActive()) {
          toast(language.thisPlanIsAlreadyActive);
        } else {
          InAppPurchaseService.buySubscriptionPlan(context, planToPurchase: membershipStore.selectedInAppPlan!, levelId: membershipStore.selectedPlan!.id.validate());
        }
      } else {
        // No in-app package found - show error and fallback to web payment
        if (!membershipStore.hasInAppOffering) {
          toast(language.noOfferingsFound);
        } else {
          toast('${language.revenueCatIdentifierMissMach}');
        }
        // Fallback to web payment if in-app purchase is not available
        log('In-app package not found - inAppOffering: ${membershipStore.hasInAppOffering}, selectedPlan: ${membershipStore.hasSelectedPlan}. Falling back to web payment.');
        // Only fallback to web payment if checkout URL is available
        if (membershipStore.selectedPlan?.checkoutUrl.validate().isNotEmpty == true) {
          pmpPayment();
        }
      }
    } catch (e) {
      log('Error in getInAppPackageForSelectedPlan: ${e.toString()}');
      toast('${language.pleaseTryAgain}: ${e.toString()}');
      // Fallback to web payment on error if checkout URL is available
      if (membershipStore.selectedPlan?.checkoutUrl.validate().isNotEmpty == true) {
        pmpPayment();
      }
    }
  }

  Future<void> getPlansList() async {
    if (membershipStore.isDataCached && membershipStore.isCacheValid) {
      _selectInitialPlan();
      return;
    }

    membershipStore.setLoading(true);
    try {
      await Future.delayed(Duration(milliseconds: 100));

      final value = await getLevelsList();
      membershipStore.setPlans(value);

      if (membershipStore.hasPlans) {
        _selectInitialPlan();
      }
    } catch (e) {
      membershipStore.setError(true);
      log('Error loading plans: ${e.toString()}');
    } finally {
      membershipStore.setLoading(false);
    }
  }

  void _selectInitialPlan() {
    if (widget.selectedPlanId.validate().isNotEmpty) {
      final selectedPlan = membershipStore.plans.firstWhere(
        (element) => element.productId == widget.selectedPlanId.validate(),
        orElse: () => membershipStore.plans.first,
      );
      membershipStore.setSelectedPlan(selectedPlan);
    } else if (widget.selectedPlanId == null) {
      membershipStore.selectBestRecommendedPlan(widget.requiredPlanIds);
    }
  }

  Future<void> pmpPayment() async {
    await WebViewScreen(url: membershipStore.selectedPlan!.checkoutUrl.validate() + '&web_view_nonce=${appStore.userNonce}&user_id=${appStore.userId}', title: language.payment)
        .launch(context)
        .then((x) async {
      appStore.setLoading(true);
      await getMembershipLevelForUser(userId: appStore.userId.validate()).then((membershipPlan) {
        if (membershipPlan != null) {
          MembershipModel membership = MembershipModel.fromJson(membershipPlan);

          if (membership.id != appStore.subscriptionPlanId) {
            logout(logoutFromAll: true, isNewTask: true, context: context);
          }
        }
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        log('Error: ${e.toString()}');
      });
    });
  }

  Future<void> configurePaymentMethod(int index) async {
    if (!membershipStore.isSelectedPlanActive()) {
      if (appStore.isLoading) return;

      if (membershipStore.isSelectedPlanFree()) {
        InAppPurchaseService.buySubscriptionPlan(context, planToPurchase: null, levelId: membershipStore.selectedPlan!.id.validate(), isFreePlan: true);
        return;
      }

      if (index == 0) {
        finish(context, true);
        pmpPayment();
      } else if (index == 1) {
        finish(context, true);
        WooCommerceScreen(orderId: membershipStore.selectedPlan!.productId.validate()).launch(context);
      } else if (index == 2) {
        getInAppPackageForSelectedPlan();
      }
    } else {
      toast(language.selectedSubscriptionPlanIsAlreadyActive);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (appStore.isLoading) appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        title: Text(language.allSubscription, style: boldTextStyle()),
      ),
      body: Observer(
        builder: (_) => RefreshIndicator(
          onRefresh: () async {
            membershipStore.resetState();
            await getPlansList();
            if (coreStore.isInAppPurchaseEnabled) {
              await getInAppPlan();
            }
          },
          child: Stack(
            children: [
              if (membershipStore.hasPlans)
                ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: membershipStore.plans.length,
                  itemBuilder: (ctx, index) {
                    MembershipModel plan = membershipStore.plans[index];
                    bool isRecommended = _isPlanRecommended(plan);
                    bool isCurrentPlan = _isUserCurrentPlan(plan);
                    return _buildPlanCard(plan, isCurrentPlan, isRecommended);
                  },
                ),
              if (!membershipStore.hasPlans && !membershipStore.isAnyLoading && !membershipStore.hasError)
                NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.noData,
                ).center(),
              if (membershipStore.hasError && !membershipStore.isAnyLoading)
                NoDataWidget(
                  imageWidget: noDataImage(),
                  title: language.somethingWentWrong,
                ).center(),
              if (membershipStore.isAnyLoading) LoaderWidget().center(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Observer(
        builder: (_) {
          if (membershipStore.hasSelectedPlan && !membershipStore.isAnyLoading) {
            final plan = membershipStore.selectedPlan!;
            final isFree = (plan.initialPayment.validate().toDouble() == 0.0);
            final currency = parseHtmlString(coreStore.pmProCurrency);
            final price = "$currency${plan.initialPayment.validate()}";

            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Left side: Free text or Pay text and price
                    if (isFree)
                      Text(
                        language.free,
                        style: boldTextStyle(color: Colors.white, size: 20),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            language.pay,
                            style: secondaryTextStyle(color: Colors.white70, size: 14),
                          ),
                          4.height,
                          Text(
                            price,
                            style: boldTextStyle(color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    Spacer(),
                    // Right side: Next button
                    AppButton(
                      text: language.next,
                      color: context.primaryColor,
                      padding: EdgeInsets.zero,
                      height: 42,
                      width: 120,
                      onTap: () async {
                        if (membershipStore.isSelectedPlanFree()) {
                          InAppPurchaseService.buySubscriptionPlan(context, planToPurchase: null, levelId: membershipStore.selectedPlan!.id.validate(), isFreePlan: true);
                          return;
                        }

                        if (coreStore.isInAppPurchaseEnabled) {
                          configurePaymentMethod(2);
                        } else {
                          pmpPayment();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPlanCard(MembershipModel plan, bool isCurrentPlan, bool isRecommended) {
    return Observer(
      builder: (_) {
        bool isSelected = membershipStore.selectedPlan == plan;
        String cyclePeriod = plan.cyclePeriod.validate();
        String expirationNumber = plan.expirationNumber.validate();
        String expirationPeriod = plan.expirationPeriod.validate();
        
        // Lifetime: both cyclePeriod and expiry data must be empty
        bool isLifetimeCycle = (cyclePeriod.isEmpty || cyclePeriod == "0") && 
                               (expirationPeriod.isEmpty || expirationPeriod == "0") && 
                               (expirationNumber.isEmpty || expirationNumber == "0");
        
        // Display cycle period: if cyclePeriod is empty but expiry exists, show expiry format
        String displayCyclePeriod;
        if (isLifetimeCycle) {
          displayCyclePeriod = language.lifetime;
        } else if ((cyclePeriod.isEmpty || cyclePeriod == "0") && _hasExpiryData(plan)) {
          String pluralizedPeriod = pluralizeExpiryPeriod(expirationNumber, expirationPeriod);
          displayCyclePeriod = "$expirationNumber $pluralizedPeriod";
        } else {
          displayCyclePeriod = cyclePeriod;
        }
        
        final currency = parseHtmlString(coreStore.pmProCurrency);

        return GestureDetector(
          onTap: () {
            if (!isCurrentPlan) {
              membershipStore.selectPlan(plan);
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? context.primaryColor.withValues(alpha: 0.1) : appBackground,
              border: Border.all(
                color: isSelected ? context.primaryColor : Colors.transparent,
                width: 0.5,
              ),
              borderRadius: radius(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(plan.name.validate(), style: boldTextStyle(color: Colors.white, size: 16)),
                    Spacer(),
                    8.width,
                    Row(
                      children: [
                        if (isRecommended)
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryColor,
                              borderRadius: radius(4),
                            ),
                            child: Text(language.recommended, style: boldTextStyle(color: Colors.white, size: 12)),
                          ),
                        if (isCurrentPlan)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: radius(4),
                            ),
                            child: Text(language.yourPlan, style: boldTextStyle(color: black, size: 12)),
                          ),
                      ],
                    ),
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? colorPrimary : Colors.white,
                    ).visible(isCurrentPlan == false),
                  ],
                ),

                8.height,

                Row(
                  children: [
                    if ((plan.initialPayment == null || plan.initialPayment.validate().toDouble() == 0.0) && isLifetimeCycle)
                      Text(
                        displayCyclePeriod,
                        style: boldTextStyle(color: context.primaryColor, size: 20),
                      )
                    else if (plan.initialPayment.validate().toDouble() == 0.0)
                      Text(
                        displayCyclePeriod,
                        style: boldTextStyle(color: context.primaryColor, size: 20),
                      )
                    else ...[
                      Text(
                        "$currency${plan.initialPayment.validate()}",
                        style: boldTextStyle(color: context.primaryColor, size: 20),
                      ),
                      4.width,
                      Text(
                        "/ ${displayCyclePeriod}",
                        style: secondaryTextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),

                // Recurring billing information - only show if initialPayment and billingAmount are different
                if (_hasRecurringBilling(plan) &&
                    plan.initialPayment.validate().toDouble() > 0 &&
                    plan.billingAmount != null &&
                    plan.initialPayment.validate().toDouble() != plan.billingAmount!.validate().toDouble())
                  Row(
                    children: [
                      Text(
                        "${language.then} ",
                        style: secondaryTextStyle(color: Colors.white70, size: 14),
                      ),
                      Text(
                        "$currency${plan.billingAmount.validate()}",
                        style: secondaryTextStyle(color: Colors.white70, size: 14),
                      ),
                      if (!isLifetimeCycle && cyclePeriod.isNotEmpty)
                        Text(
                          "/${cyclePeriod.toLowerCase()}",
                          style: secondaryTextStyle(color: Colors.white70, size: 14),
                        )
                      else if (isLifetimeCycle)
                        Text(
                          "/${language.lifetime}",
                          style: secondaryTextStyle(color: Colors.white70, size: 14),
                        ),
                      if (plan.billingLimit.validate().isNotEmpty && plan.billingLimit.validate() != "0")
                        Text(
                          " ${language.forText} ${plan.billingLimit.validate()} ${plan.billingLimit.validate() == "1" ? "month" : "months"}",
                          style: secondaryTextStyle(color: Colors.white70, size: 14),
                        ),
                    ],
                  ),

                12.height,

                /// Features list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: plan.features!.map((e) => _feature(e.type == "include", e.text.validate())).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Feature row widget
  Widget _feature(bool enabled, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: enabled ? Colors.white54 : context.primaryColor,
            size: 18,
          ),
          8.width,
          Text(
            text,
            style: TextStyle(
              color: enabled ? Colors.white54 : Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
