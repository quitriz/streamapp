import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ReleaseDateBadge extends StatelessWidget {
  final DateTime? releaseDate;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const ReleaseDateBadge({
    Key? key,
    required this.releaseDate,
    this.backgroundColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  }) : super(key: key);

  String _formatted(DateTime date) {
    return DateFormat(DATE_FORMAT_5).format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (releaseDate == null) return SizedBox.shrink();

    final bg = backgroundColor ?? subscriptionColor.withValues(alpha: 0.3);

    final txtStyle = textStyle ?? primaryTextStyle(color: subscriptionColor, size: 13);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: subscriptionColor, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, color: subscriptionColor, size: 16),
          8.width,
          Flexible(
            child: Text(
              '${language.releases} ${_formatted(releaseDate!)}',
              style: txtStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
