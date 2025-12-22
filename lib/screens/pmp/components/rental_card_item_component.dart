import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/pmp_models/pay_per_view_orders_model.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class RentalCardItemComponent extends StatelessWidget {
  final OrderData rental;
  final VoidCallback? onInvoiceTap;
  final VoidCallback? onCardTap;

  const RentalCardItemComponent({Key? key, required this.rental, this.onInvoiceTap, this.onCardTap}) : super(key: key);

  /// Formats date string to 'Month Day, Year'
  String _formatDate(String? dateString) {
    if (dateString.validate().isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString!);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      log('Date formatting error: $e');
      return dateString!;
    }
  }

  Widget detailItem({required IconData icon, required String label, Widget? valueWidget, String? valueText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: textSecondaryColorGlobal),
            4.width,
            Text(label, style: secondaryTextStyle(size: textPrimarySizeGlobal.toInt())),
          ],
        ),
        6.height,
        Padding(padding: EdgeInsets.only(left: 2), child: valueWidget ?? Text(valueText ?? '', style: boldTextStyle(size: textPrimarySizeGlobal.toInt()))),
      ],
    );
  }

  Widget paymentStatusWidget(context) {
    bool isPaid = rental.status.validate().toLowerCase() == PaymentStatus.success;
    return Text(isPaid ? language.paid : language.unpaid, style: boldTextStyle(color: isPaid ? rentColor : context.primaryColor, size: textSecondarySizeGlobal.toInt()));
  }

  Widget activeStatusWidget({String text = 'Active', Color backgroundColor = rentColor, Color textColor = Colors.white, TextStyle? textStyle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomLeft: Radius.circular(6))),
      child: Text(text, style: textStyle ?? TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = !(rental.validityStatus.validate().toLowerCase() == ValidityStatus.available || rental.validityStatus.validate().toLowerCase() == ValidityStatus.lifetimeAccess);
    final String statusText = isExpired ? language.expired : language.active;
    final Color statusColor = isExpired ? context.primaryColor : rentColor;

    return GestureDetector(
      onTap: onCardTap,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: appBackground, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Top Section: Image, Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Content Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImageWidget(url: rental.contentImage.validate(value: appStore.sliderDefaultImage.validate()), fit: BoxFit.cover, height: 70, width: 70),
                    ),
                    12.width,

                    /// Content Name & Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rental.contentName.validate(), style: boldTextStyle(size: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                        4.height,
                        Text(getPostTypeString(rental.contentType).capitalizeFirstLetter(), style: primaryTextStyle(size: textSecondarySizeGlobal.toInt(), color: context.primaryColor)),
                      ],
                    ).expand(),
                  ],
                ).paddingAll(16),

                /// Middle Section: Details Grid
                Column(
                  children: [
                    Row(
                      children: [
                        detailItem(icon: Icons.calendar_today_outlined, label: language.purchased, valueText: _formatDate(rental.purchaseDate)).expand(),
                        16.width,
                        detailItem(
                          icon: Icons.timer_off_outlined,
                          label: language.expiry,
                          valueText: rental.validityStatus.validate().toLowerCase() == ValidityStatus.lifetimeAccess ? language.lifetime : _formatDate(rental.expireAt),
                        ).expand(),
                      ],
                    ),
                    20.height,
                    Row(
                      children: [
                        detailItem(icon: Icons.credit_card_outlined, label: language.payment, valueWidget: paymentStatusWidget(context)).expand(),
                        16.width,
                        detailItem(icon: Icons.monetization_on_outlined, label: language.amount, valueText: '${parseHtmlString(coreStore.pmProCurrency)}${rental.total ?? '0.00'}').expand(),
                      ],
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16),
                16.height,

                /// Bottom Section: Invoice Button
                AppButton(
                  text: language.downloadInvoice,
                  color: context.primaryColor,
                  height: 48,
                  width: double.infinity,
                  onTap: onInvoiceTap,
                  textStyle: boldTextStyle(color: white),
                  shapeBorder: RoundedRectangleBorder(borderRadius: radius(8)),
                  elevation: 0,
                ).paddingSymmetric(horizontal: 16, vertical: 16),
              ],
            ),
          ),

          /// UPDATED: Dynamic status widget positioned at the top right.
          Positioned(
            top: 0,
            right: 0,
            child: activeStatusWidget(text: statusText.capitalizeFirstLetter(), backgroundColor: statusColor),
          ),
        ],
      ),
    );
  }
}
