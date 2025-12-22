import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/sources.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class SourcesDataWidget extends StatelessWidget {
  final List<Sources>? sourceList;
  final Function(Sources)? onLinkTap;

  SourcesDataWidget({this.sourceList, this.onLinkTap});

  bool _hasValidData(String? data) => data != null && data.trim().isNotEmpty;

  Map<String, bool> _getAvailableFields() {
    if (sourceList == null || sourceList!.isEmpty) {
      return {'quality': false, 'language': false, 'date': false};
    }
    return {
      'quality': sourceList!.any((s) => _hasValidData(s.quality)),
      'language': sourceList!.any((s) => _hasValidData(s.language)),
      'date': sourceList!.any((s) => _hasValidData(s.dateAdded)),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (sourceList == null || sourceList!.isEmpty) return const SizedBox.shrink();

    Map<String, bool> availableFields = _getAvailableFields();
    bool hasAnyField = availableFields.values.any((e) => e);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasAnyField) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            child: Row(
              children: [
                if (availableFields['quality']!)
                  Expanded(child: Text(language.quality, style: boldTextStyle(color: colorPrimary, size: 13))),
                if (availableFields['language']!)
                  Expanded(child: Text(language.language, style: boldTextStyle(color: colorPrimary, size: 13))),
                if (availableFields['date']!)
                  Expanded(child: Text(language.date, style: boldTextStyle(color: colorPrimary, size: 13))),
                Text(language.links, style: boldTextStyle(color: colorPrimary, size: 13)),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade700, height: 1),
        ],

        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: sourceList!.length,
          itemBuilder: (_, index) {
            Sources source = sourceList![index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  if (availableFields['quality']! && _hasValidData(source.quality))
                    Expanded(child: Text(source.quality.validate(), style: primaryTextStyle(size: 13), overflow: TextOverflow.ellipsis)),

                  if (availableFields['language']! && _hasValidData(source.language))
                    Expanded(child: Text(source.language.validate(), style: primaryTextStyle(size: 13), overflow: TextOverflow.ellipsis)),

                  if (availableFields['date']! && _hasValidData(source.dateAdded))
                    Expanded(
                      child: Text(
                        source.dateAdded.validate(),
                        style: primaryTextStyle(size: 12, color: Colors.grey.shade400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  Icon(Icons.open_in_new, size: 18, color: colorPrimary).onTap(() async {
                    if (source.isAffiliate ?? false) {
                      appLaunchUrl(source.link.validate());
                    } else {
                      onLinkTap?.call(source);
                    }
                  }),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => Divider(color: Colors.grey.shade700, height: 1),
        ),
      ],
    );
  }
}
