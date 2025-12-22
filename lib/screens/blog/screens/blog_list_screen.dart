import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/components/loading_dot_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/blog/wp_post_response.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/blog/components/blog_card_component.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  ScrollController _controller = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    appStore.setBlogFuture(getBlogs());

    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        if (!appStore.blogIsLastPage) {
          appStore.setBlogPage(appStore.blogPage + 1);
          appStore.setBlogFuture(getBlogs());
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        appStore.setBlogHasShowClearTextIcon(false);
      }
    });
  }

  void showClearTextIcon() {
    if (!appStore.blogHasShowClearTextIcon) {
      appStore.setBlogHasShowClearTextIcon(true);
    }
  }

  Future<List<WpPostResponse>> getBlogs() async {
    appStore.setLoading(true);

    await getBlogList(page: appStore.blogPage, searchText: searchController.text.trim()).then((value) {
      appStore.setBlogIsLastPage(value.length != postPerPage);
      appStore.setBlogList(value, isRefresh: appStore.blogPage == 1);

      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setBlogIsError(true);
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return appStore.blogList.toList();
  }

  Future<void> onRefresh() async {
    appStore.setBlogIsError(false);
    appStore.setBlogPage(1);
    appStore.setBlogFuture(getBlogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.blogs, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: [
            Container(
              width: context.width() - 32,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(color: search_edittext_color, borderRadius: radius(defaultRadius)),
              child: AppTextField(
                controller: searchController,
                textFieldType: TextFieldType.USERNAME,
                onFieldSubmitted: (text) {
                  appStore.setBlogPage(1);
                  appStore.setBlogFuture(getBlogs());
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: language.search,
                  hintStyle: secondaryTextStyle(),
                  prefixIcon: Image.asset(
                    ic_search,
                    height: 16,
                    width: 16,
                    fit: BoxFit.cover,
                    color: textColorThird,
                  ).paddingAll(16),
                  suffixIcon: appStore.blogHasShowClearTextIcon
                      ? IconButton(
                          icon: Icon(Icons.cancel, color: textColorThird, size: 18),
                          onPressed: () {
                            hideKeyboard(context);
                            appStore.setBlogHasShowClearTextIcon(false);
                            searchController.clear();
                            appStore.setBlogPage(1);
                            appStore.setBlogFuture(getBlogs());
                          },
                        )
                      : null,
                ),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                FutureBuilder<List<WpPostResponse>>(
                  future: appStore.blogFuture,
                  builder: (ctx, snap) {
                    if (snap.hasError) {
                      return SizedBox(
                        height: context.height() - kToolbarHeight - 100,
                        child: Center(
                          child: NoDataWidget(
                            imageWidget: noDataImage(),
                            title: appStore.blogIsError ? language.somethingWentWrong : language.noData,
                          ),
                        ),
                      );
                    }

                    if (snap.hasData) {
                      if (snap.data.validate().isEmpty) {
                        return SizedBox(
                          height: context.height() - kToolbarHeight - 100,
                          child: Center(
                            child: NoDataWidget(
                              imageWidget: noDataImage(),
                              title: appStore.blogIsError ? language.somethingWentWrong : '${language.noBlogsFound} ${searchController.text}',
                            ),
                          ),
                        );
                      } else {
                        return AnimatedListView(
                          slideConfiguration: SlideConfiguration(
                            delay: 80.milliseconds,
                            verticalOffset: 300,
                          ),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                          itemCount: appStore.blogList.length,
                          itemBuilder: (context, index) {
                            WpPostResponse data = appStore.blogList[index];
                            return BlogCardComponent(data: data);
                          },
                        );
                      }
                    }
                    return Offstage();
                  },
                ),
                Observer(
                  builder: (_) {
                    if (appStore.isLoading) {
                      if (appStore.blogPage != 1) {
                        return Positioned(
                          bottom: 10,
                          child: LoadingDotsWidget(),
                        );
                      } else {
                        return LoaderWidget().center();
                      }
                    } else {
                      return Offstage();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}