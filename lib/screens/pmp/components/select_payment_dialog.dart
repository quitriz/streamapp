import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class SelectPaymentDialog extends StatefulWidget {
  final Function(int paymentMethodIndex) paymentMethod;

  const SelectPaymentDialog({required this.paymentMethod});

  @override
  State<SelectPaymentDialog> createState() => _SelectPaymentDialogState();
}

class _SelectPaymentDialogState extends State<SelectPaymentDialog> {
  @override
  void initState() {
    super.initState();
    membershipStore.setSelectedPaymentMethod(null);
  }

  Widget paymentOptionWidget() {
    return Observer(builder: (context) {
      return Column(
        children: [
          Row(
            children: [
              Icon(membershipStore.selectedPaymentMethod == 0 ? Icons.radio_button_checked : Icons.circle_outlined, color: context.iconColor, size: 18),
              8.width,
              Text(language.pmpPayment, style: primaryTextStyle()),
            ],
          ).onTap(
            () {
              membershipStore.setSelectedPaymentMethod(0);
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          16.height,
          Row(
            children: [
              Icon(membershipStore.selectedPaymentMethod == 1 ? Icons.radio_button_checked : Icons.circle_outlined, color: context.iconColor, size: 18),
              8.width,
              Text(language.wooCommerce, style: primaryTextStyle()),
            ],
          ).onTap(
            () {
              membershipStore.setSelectedPaymentMethod(1);
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        20.height,
          AppButton(
            onTap: () async {
              if (membershipStore.selectedPaymentMethod != null)
                widget.paymentMethod.call(membershipStore.selectedPaymentMethod!);
            else
              toast(language.pleaseChoosePaymentMethod);
          },
          width: context.width(),
          color: colorPrimary,
          splashColor: colorPrimary,
          child: Text(language.makePayment, style: boldTextStyle(color: Colors.white)),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(language.paymentBy, style: boldTextStyle(size: 20, color: Colors.red)),
        20.height,
        paymentOptionWidget(),
      ],
    );
  }
}
