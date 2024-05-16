import 'package:html/parser.dart' as html_parser;

import 'package:flutter/material.dart';
import 'package:nogari/models/common/news.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCard extends StatelessWidget {
  final News news;
  const NewsCard({required this.news, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
      padding: EdgeInsets.zero,
      width: MediaQuery.of(context).size.width * 1.0,
      height: MediaQuery.of(context).size.height * 0.20,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(),
                      height: MediaQuery.of(context).size.height * 0.13,
                      child: ClipRect(
                        child: Image.network(
                          news.imgUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 7,
                    child: InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            html_parser.parse(news.title).body!.text,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            html_parser.parse(news.description).body!.text,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse(news.link))) {
                          await launchUrl(Uri.parse(news.link));
                        } else {
                          throw 'Could not launch url';
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
