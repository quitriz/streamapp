import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/pmp_models/pmp_order_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/pmp/screens/all_orders_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/order_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

class PastInvoicesComponent extends StatefulWidget {
  const PastInvoicesComponent({Key? key}) : super(key: key);

  @override
  State<PastInvoicesComponent> createState() => _PastInvoicesComponentState();
}

class _PastInvoicesComponentState extends State<PastInvoicesComponent> {
  late Future<List<PmpOrderModel>> future;

  @override
  void initState() {
    membershipStore.resetOrderState();
    future = getOrders();
    super.initState();
  }

  Future<List<PmpOrderModel>> getOrders({String? status}) async {
    await pmpOrders().then((value) {
      membershipStore.setOrderList(value);
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    return membershipStore.orderList;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (membershipStore.orderList.isNotEmpty)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          30.height,
          Text(language.pastInvoices, style: boldTextStyle()),
          16.height,
          Table(
            border: TableBorder.all(color: dividerDarkColor, style: BorderStyle.solid, width: 2),
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  Text(language.date, style: boldTextStyle()).center().paddingSymmetric(vertical: 8),
                  Text(language.plan, style: boldTextStyle()).center().paddingSymmetric(vertical: 8),
                  Text(language.amount, style: boldTextStyle()).center().paddingSymmetric(vertical: 8),
                ],
              ),
              ...membershipStore.orderList.take(5).map((e) {
                return TableRow(
                  children: [
                    Text(
                      DateFormat(dateFormatPmp).format(
                        DateTime.fromMillisecondsSinceEpoch(e.timestamp.validate().toString().toInt() * 1000),
                      ),
                      style: secondaryTextStyle(color: context.primaryColor),
                    ).center().paddingSymmetric(horizontal: 8, vertical: 8).onTap(() {
                      OrderDetailScreen(orderDetail: e).launch(context);
                    }),
                    Text(e.membershipName.validate(), style: primaryTextStyle(size: 14)).center().paddingSymmetric(vertical: 8),
                    Text('${parseHtmlString(coreStore.pmProCurrency)}${e.total.validate()}', style: primaryTextStyle(size: 14)).center().paddingSymmetric(vertical: 8),
                  ],
                );
              }).toList(),
            ],
          ),
          if (membershipStore.orderList.length > 5)
            TextButton(
              onPressed: () {
                AllOrdersScreen().launch(context);
              },
              child: Text(
                language.viewAllInvoices,
                style: primaryTextStyle(color: context.primaryColor),
              ),
            )
        ],
      );
      else
        return Offstage();
    });
  }
}
