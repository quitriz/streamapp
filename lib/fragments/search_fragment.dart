import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/home/recent_search_list.dart';
import 'package:streamit_flutter/screens/search/search_card_component.dart';
import 'package:streamit_flutter/screens/search/voice_search_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

import '../components/loader_widget.dart';

class SearchFragment extends StatefulWidget {
  static String tag = '/SearchFragment';

  @override
  SearchFragmentState createState() => SearchFragmentState();
}

class SearchFragmentState extends State<SearchFragment> {
  TextEditingController searchController = TextEditingController();
  StreamController<String> searchStream = StreamController();

  @override
  void initState() {
    super.initState();
    // Initialize with recent searches only
    init(isLoading: false);
    searchStream.stream.debounce(Duration(milliseconds: 500)).listen((s) {
      if (s.trim().isNotEmpty) {
        fragmentStore.setSearchQuery(s);
        fragmentStore.setSearchPage(1);
        init(isLoading: false);
      }
    });
  }

  Future<void> init({bool isLoading = false}) async {
    final query = searchController.text.trim();
    fragmentStore.setSearchQuery(query);

    if (query.isEmpty) {
      // Show recent searches
      final rf = recentListFetch(recentList: fragmentStore.recentSearches.toList()).then((value) {
        fragmentStore.setRecentSearches(value, isRefresh: true);
        return value;
      });
      fragmentStore.setRecentFuture(rf);
      fragmentStore.setSearchFuture(null);
    } else {
      // Perform search
      final sf =
          searchMovie(query, page: fragmentStore.searchPage, movies: fragmentStore.searchMovies, isLoading: isLoading);
      fragmentStore.setSearchFuture(sf);
      fragmentStore.setRecentFuture(null);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.black,
        leading: CachedImageWidget(url: appLogo, height: 32, width: 32, fit: BoxFit.contain),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fragmentStore.setSearchPage(1);
          init(isLoading: false);
          return await 2.seconds.delay;
        },
        child: Stack(
          children: [
            AnimatedScrollView(
              padding: EdgeInsets.only(bottom: 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              onNextPage: () {
                if (!fragmentStore.isSearchLastPage) {
                  fragmentStore.setSearchPage(fragmentStore.searchPage + 1);
                  init(isLoading: true);
                }
              },
              children: [
                Container(
                  color: black,
                  padding: EdgeInsets.only(left: spacing_standard_new, right: spacing_standard),
                  child: Row(
                    children: <Widget>[
                      CachedImageWidget(url: ic_search, fit: BoxFit.fitHeight, color: white, height: 16, width: 16),
                      8.width,
                      Expanded(
                        child: TextFormField(
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
                          decoration: InputDecoration(
                            hintText: '${language.searchHere}..',
                            hintStyle: TextStyle(
                              color: Theme.of(context).textTheme.titleSmall!.color,
                            ),
                            border: InputBorder.none,
                            filled: false,
                          ),
                          onChanged: (s) {
                            setState(() {});
                            searchStream.add(s);
                          },
                          onFieldSubmitted: (s) {
                            fragmentStore.setSearchPage(1);
                            if (s.isNotEmpty) init(isLoading: true);
                            addRecent(s);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          fragmentStore.setSearchPage(1);
                          setState(() {
                            searchController.clear();
                          });
                          hideKeyboard(context);
                          init();
                        },
                        icon: Icon(Icons.clear, color: colorPrimary, size: 20),
                        tooltip: 'Clear search',
                      ).visible(searchController.text.isNotEmpty),
                      IconButton(
                        onPressed: () {
                          VoiceSearchScreen().launch(context).then((value) {
                            if (value != null) {
                              setState(() {
                                searchController.text = value;
                              });
                              addRecent(value);

                              hideKeyboard(context);
                              fragmentStore.setSearchPage(1);
                              init();
                            }
                          });
                        },
                        icon: CachedImageWidget(url: ic_voice, color: rememberMeColor, height: 20, width: 20),
                      ).visible(searchController.text.isEmpty),
                    ],
                  ),
                ).paddingSymmetric(horizontal: 16),
                Observer(
                  builder: (_) {
                    if (searchController.text.isEmpty) {
                      return SnapHelperWidget(
                          future: fragmentStore.recentFuture,
                          errorBuilder: (e) {
                            return SizedBox(
                              height: context.height() * 0.7,
                              child: NoDataWidget(
                                title: language.pleaseLoginToSearch,
                                retryText: language.login,
                                onRetry: () {
                                  SignInScreen().launch(context);
                                },
                              ),
                            );
                          },
                          loadingWidget: Offstage(),
                          onSuccess: (data) {
                            return RecentSearchList(
                              list: data,
                              onItemTap: (value) {
                                setState(() {
                                  searchController.text = value;
                                });
                                fragmentStore.setSearchPage(1);
                                init();
                              },
                              onRemoveRecent: (id) async {
                                final res = await removeRecent(id);
                                if (res.success.validate(value: true)) {
                                  fragmentStore.removeRecentById(id);
                                  // Update the future with current local list to avoid triggering loader
                                  fragmentStore.setRecentFuture(Future.value(fragmentStore.recentSearches.toList()));
                                } else {
                                  toast(res.message.validate());
                                }
                              },
                            );
                          });
                    } else {
                      if (fragmentStore.searchFuture == null) {
                        return SizedBox.shrink();
                      }

                      return SnapHelperWidget<List<CommonDataListModel>>(
                        future: fragmentStore.searchFuture,
                        errorBuilder: (e) {
                          return SizedBox(
                            height: context.height() * 0.7,
                            child: NoDataWidget(
                              imageWidget: noDataImage(),
                              title: e.toString(),
                              onRetry: () {
                                fragmentStore.setSearchPage(1);
                                init();
                              },
                            ),
                          );
                        },
                        loadingWidget: Offstage(),
                        onSuccess: (data) {
                          if (data.validate().isEmpty) {
                            return SizedBox(
                              height: context.height() * 0.7,
                              child: NoDataWidget(
                                imageWidget: noDataImage(),
                                title: language.noContentFound,
                                subTitle: language.theContentHasNot,
                              ).center(),
                            );
                          }

                          log('Displaying search results');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              16.height,
                              Text(
                                language.resultFor + " \'" + searchController.text + "\'",
                                style: primaryTextStyle(size: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).paddingSymmetric(horizontal: 16),
                              SearchCardComponent(list: data),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ).makeRefreshable,
            Observer(
              builder: (_) {
                if (fragmentStore.searchPage == 1) {
                  return LoaderWidget().center().visible(appStore.isLoading);
                } else {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: LoadingDotsWidget(),
                  ).visible(appStore.isLoading);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
