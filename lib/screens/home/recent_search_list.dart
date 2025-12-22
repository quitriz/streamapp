import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';

class RecentSearchList extends StatelessWidget {
  final List<RecentSearchListModel> list;
  final Function(String) onItemTap;
  final Function(int) onRemoveRecent;

  const RecentSearchList({super.key, required this.list, required this.onItemTap, required this.onRemoveRecent});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final recentSearchItem = list[index];

        return ListTile(
          leading: Icon(Icons.history, color: Colors.grey.shade600),
          title: Text(recentSearchItem.term!, style: secondaryTextStyle(size: 16)),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade600),
            tooltip: language.removeFromHistory,
            onPressed: () {
              if (recentSearchItem.id != null) {
                onRemoveRecent(recentSearchItem.id!);
              }
            },
          ),
          onTap: () {
            onItemTap(recentSearchItem.term!);
          },
        );
      },
    );
  }
}
