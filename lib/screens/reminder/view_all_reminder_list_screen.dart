import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/common_list_item_component.dart';
import 'package:streamit_flutter/components/common_list_item_shimmer_component.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/models/notification_reminder_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/movie_episode/screens/movie_detail_screen.dart';
import 'package:streamit_flutter/screens/tv_show/tv_show_detail_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ViewAllReminderListScreen extends StatefulWidget {
  @override
  _ViewAllReminderListScreenState createState() => _ViewAllReminderListScreenState();
}

class _ViewAllReminderListScreenState extends State<ViewAllReminderListScreen> with TickerProviderStateMixin {
  late TabController tabController;
  late List<_ReminderTabConfig> tabConfigs;
  Map<PostType, _ReminderTabState> tabStates = {};

  bool didInitialize = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    tabConfigs = [
      _ReminderTabConfig(title: language.movies, postType: PostType.MOVIE, itemsPerRow: 3, isLandscape: false),
      _ReminderTabConfig(title: language.videos, postType: PostType.VIDEO, itemsPerRow: 3, isLandscape: false),
      _ReminderTabConfig(title: language.tVShows, postType: PostType.TV_SHOW, itemsPerRow: 3, isLandscape: false),
      _ReminderTabConfig(title: language.episodes, postType: PostType.EPISODE, itemsPerRow: 2, isLandscape: true),
    ];

    tabController = TabController(length: tabConfigs.length, vsync: this)
      ..addListener(() {
        setState(() {});
      });

    init();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);

    try {
      final response = await getReminderList();
      final reminders = response.reminderList ?? [];

      final Map<PostType, List<ReminderList>> grouped = {};
      for (final reminder in reminders) {
        final postType = reminder.postType ?? PostType.NONE;
        grouped.putIfAbsent(postType, () => []).add(reminder);
      }

      setState(() {
        fragmentStore.setReminderList(reminders);
        errorMessage = null;
        didInitialize = true;
        tabStates = _createTabStates(grouped);
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        errorMessage = e.toString();
        didInitialize = true;
        tabStates.clear();
      });
    } finally {
      if (showLoader) appStore.setLoading(false);
    }
  }

  Map<PostType, _ReminderTabState> _createTabStates(Map<PostType, List<ReminderList>> grouped) {
    final Map<PostType, _ReminderTabState> states = {};
    for (final config in tabConfigs) {
      final source = grouped[config.postType] ?? [];
      final converted = source.map(reminderDataToCommonData).toList();
      states[config.postType] = _ReminderTabState(allItems: converted);
    }
    return states;
  }

  void _loadNextPage(PostType postType) {
    final state = tabStates[postType];
    if (state == null || state.isLastPage) return;

    setState(() {
      state.loadNextPage();
    });
  }

  CommonDataListModel reminderDataToCommonData(ReminderList reminderData) {
    return CommonDataListModel(
      id: reminderData.id,
      title: reminderData.title,
      image: reminderData.image,
      portraitImage: reminderData.image,
      postType: reminderData.postType ?? PostType.NONE,
    );
  }

  void handleContentTap(BuildContext context, CommonDataListModel data) {
    LiveStream().emit(PauseVideo);

    if (data.postType == PostType.EPISODE) {
      final parentShow = CommonDataListModel(
        id: data.id,
        postType: PostType.TV_SHOW,
        title: data.title,
      );
      appStore.setTrailerVideoPlayer(false);
      TvShowDetailScreen(showData: parentShow).launch(context);
    } else if (data.postType == PostType.TV_SHOW) {
      appStore.setTrailerVideoPlayer(false);
      TvShowDetailScreen(showData: data).launch(context);
    } else {
      appStore.setTrailerVideoPlayer(false);
      MovieDetailScreen(movieData: data).launch(context);
    }
  }

  Widget chipButton(String title, int index) {
    final isSelected = tabController.index == index;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? colorPrimary : appBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? colorPrimary : borderColor, width: 1),
      ),
      child: Text(
        title,
        style: boldTextStyle(size: textSecondarySizeGlobal.toInt(), color: isSelected ? Colors.white : Colors.white),
      ),
    );
  }

  bool _shouldShowShimmer(PostType postType) {
    if (!didInitialize) return true;
    if (appStore.isLoading && (tabStates[postType]?.visibleItems.isEmpty ?? true)) return true;
    return false;
  }

  double _calculateItemWidth(BuildContext context, _ReminderTabConfig config) {
    final totalSpacing = 12 * (config.itemsPerRow - 1);
    final availableWidth = context.width() - (16 * 2) - totalSpacing;
    return max(0.0, availableWidth / config.itemsPerRow);
  }

  Widget _buildShimmerGrid(BuildContext context, _ReminderTabConfig config, double itemWidth) {
    final shimmerCount = config.itemsPerRow * 2;

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(shimmerCount, (_) {
          return SizedBox(
            width: itemWidth,
            child: config.isLandscape ? CommonListItemShimmer(isLandscape: true, width: itemWidth) : CommonListItemShimmer(isVerticalList: true, isViewAll: true),
          );
        }),
      ),
    );
  }

  _ReminderTabConfig _configFor(PostType postType) {
    return tabConfigs.firstWhere(
      (config) => config.postType == postType,
      orElse: () => tabConfigs.first,
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final horizontalPadding = context.width() > 400 ? 24.0 : 16.0;
    final labelSpacing = context.width() > 400 ? 16.0 : 12.0;

    return Container(
      color: appBackground,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: TabBar(
          controller: tabController,
          isScrollable: true,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          tabAlignment: TabAlignment.start,
          labelPadding: EdgeInsets.only(right: labelSpacing),
          tabs: List.generate(tabConfigs.length, (index) => chipButton(tabConfigs[index].title, index)),
        ),
      ),
    );
  }

  Widget _buildTabContent(PostType postType) {
    if (!didInitialize) {
      return SizedBox();
    }

    if (errorMessage.validate().isNotEmpty) {
      return NoDataWidget(
        imageWidget: noDataImage(),
        title: errorMessage,
        subTitle: language.somethingWentWrong,
        retryText: language.refresh,
        onRetry: () {
          init();
        },
      ).center();
    }

    final tabConfig = _configFor(postType);
    final itemWidth = _calculateItemWidth(context, tabConfig);

    if (_shouldShowShimmer(postType)) {
      return _buildShimmerGrid(context, tabConfig, itemWidth);
    }

    final state = tabStates[postType];
    if (state == null || state.visibleItems.isEmpty) {
      return NoDataWidget(
        imageWidget: noDataImage(),
        title: language.notFound,
        retryText: language.refresh,
        onRetry: () {
          init(showLoader: false);
        },
      ).center();
    }

    return AnimatedScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 8),
      physics: AlwaysScrollableScrollPhysics(),
      refreshIndicatorColor: colorPrimary,
      onSwipeRefresh: () => init(showLoader: false),
      onNextPage: () => _loadNextPage(postType),
      children: [
        AnimatedWrap(
          spacing: 12,
          runSpacing: 12,
          itemCount: state.visibleItems.length,
          itemBuilder: (p0, index) {
            final data = state.visibleItems[index];
            return SizedBox(
              width: itemWidth,
              child: CommonListItemComponent(
                data: data,
                width: itemWidth,
                isLandscape: tabConfig.isLandscape,
                isVerticalList: !tabConfig.isLandscape,
                isViewAll: !tabConfig.isLandscape,
                onTap: () => handleContentTap(context, data),
              ),
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(language.yourReminders, style: primaryTextStyle(color: Colors.white, size: 22)),
        centerTitle: false,
        backgroundColor: appBackground,
        bottom: PreferredSize(preferredSize: Size(context.width(), 70), child: _buildTabBar(context)),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: tabConfigs.map((config) => _buildTabContent(config.postType)).toList(),
          ),
          Observer(
            builder: (_) => LoadingDotsWidget().center().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}

class _ReminderTabConfig {
  final String title;
  final PostType postType;
  final int itemsPerRow;
  final bool isLandscape;

  const _ReminderTabConfig({required this.title, required this.postType, required this.itemsPerRow, required this.isLandscape});
}

class _ReminderTabState {
  final List<CommonDataListModel> allItems;
  late List<CommonDataListModel> visibleItems;
  int page;

  _ReminderTabState({required this.allItems}) : page = 1 {
    visibleItems = _slice(allItems, page);
  }

  bool get isLastPage => visibleItems.length >= allItems.length;

  void loadNextPage() {
    if (isLastPage) return;
    page += 1;
    visibleItems = _slice(allItems, page);
  }

  static List<CommonDataListModel> _slice(List<CommonDataListModel> source, int page) {
    if (source.isEmpty) return [];
    final endIndex = min(page * postPerPage, source.length);
    return source.take(endIndex).toList();
  }
}
