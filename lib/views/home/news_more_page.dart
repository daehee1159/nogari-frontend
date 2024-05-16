import 'package:html/parser.dart' as html_parser;

import 'package:flutter/material.dart';
import 'package:nogari/widgets/common/custom.divider.dart';

import '../../models/common/news.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsMorePage extends StatefulWidget {
  final List<News> newsList;
  const NewsMorePage({required this.newsList, super.key});

  @override
  State<NewsMorePage> createState() => _NewsMorePageState();
}

class _NewsMorePageState extends State<NewsMorePage> {
  late ScrollController _scrollController;
  int visibleNewsCount = 10; // 현재 화면에 보이는 뉴스 개수
  bool loading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    visibleNewsCount = 10;
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange && !_scrollController.position.outOfRange) {
      // Reach the bottom of the list
      if (_hasMoreData) {
        _loadMoreNews();
      }
    }
  }

  void _loadMoreNews() async {
    if (!loading && _hasMoreData) {
      setState(() {
        loading = true;
      });

      // Simulate loading more items, replace this with your actual data fetching logic
      await Future.delayed(const Duration(seconds: 2));

      bool hasMoreData = widget.newsList.length > visibleNewsCount;

      setState(() {
        if (hasMoreData) {
          visibleNewsCount += 10;
        } else {
          _hasMoreData = false;
        }
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<News> visibleNewsList = widget.newsList.take(visibleNewsCount).toList();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '뉴스 더 보기',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: visibleNewsList.length + (_hasMoreData ? 1 : 0), // +1 for loading indicator
          itemBuilder: (context, index) {
            if (index < visibleNewsList.length) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: MediaQuery.of(context).size.height * 0.19,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                            child: ClipRect(
                              child: Image.network(
                                widget.newsList[index].imgUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  html_parser.parse(widget.newsList[index].title).body!.text,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  html_parser.parse(widget.newsList[index].description).body!.text,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (await canLaunchUrl(Uri.parse(widget.newsList[index].link))) {
                                await launchUrl(Uri.parse(widget.newsList[index].link));
                              } else {
                                throw 'Could not launch url';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    const CustomDivider(height: 1, color: Colors.grey)
                  ],
                ),
              );
            } else {
              return Center(
                child: loading ? const CircularProgressIndicator(color: Color(0xff33D679),) : const SizedBox(),
              );
            }
          },
        ),
      ),
    );
  }
}
