import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nogari/screens/home/news_more_page.dart';
import 'package:nogari/screens/home/point_page.dart';
import 'package:nogari/screens/home/scientificCalCulator.dart';
import 'package:nogari/widgets/common/banner_ad_widget.dart';
import 'package:provider/provider.dart';

import '../../models/common/news_provider.dart';
import '../../widgets/common/circularIcon.dart';
import '../../widgets/common/news_card.dart';
import '../home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InterstitialAd? myInterstitial;
  String url = 'https://www.ajunews.com/view/20240115103709546';

  PageController _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.9
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NewsProvider newsProvider = Provider.of<NewsProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'images/nogari_icon.png',
                  height: MediaQuery.of(context).size.height * 0.13,
                  fit: BoxFit.contain,
                ),
                Text(
                  '우리들의 노가다 이야기',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            // SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            Container(
              height: MediaQuery.of(context).size.height * 0.14,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: const CircularIcon(
                      icon: Icons.star,
                      text: '공수달력'
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 2,)));
                    },
                  ),
                  InkWell(
                    child: const CircularIcon(
                      icon: Icons.star,
                      text: '커뮤니티'
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
                    },
                  ),
                  InkWell(
                    child: const CircularIcon(
                      icon: Icons.star,
                      text: '업체리뷰'
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 3,)));
                    },
                  ),
                  InkWell(
                    child: const CircularIcon(
                      icon: Icons.star,
                      text: '공학용\n계산기'
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScientificCalculator()));

                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            Container(
              height: MediaQuery.of(context).size.height * 0.14,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: const CircularIcon(
                      icon: Icons.star,
                      text: '포인트\n적립하기'
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PointPage()));
                    },
                  ),
                  const CircularIcon(icon: Icons.star, text: '준비중'),
                  // InkWell(
                  //   child: const CircularIcon(
                  //     icon: Icons.star,
                  //     text: '경품\n응모하기'
                  //   ),
                  //   onTap: () {
                  //
                  //   },
                  // ),
                  const CircularIcon(icon: Icons.star, text: '준비중'),
                  const CircularIcon(icon: Icons.star, text: '준비중'),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
            Container(
              padding: EdgeInsets.zero,
              width: MediaQuery.of(context).size.width * 1.0,
              height: MediaQuery.of(context).size.height * 0.20,
              child: PageView.builder(
                controller: _pageController,
                itemCount: newsProvider.getRandomNewsList.length + 1,
                itemBuilder: (context, index) {
                  if (index < newsProvider.getRandomNewsList.length) {
                    return NewsCard(newsDto: newsProvider.getRandomNewsList[index]);
                  } else {
                    return GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Card(
                          color: Colors.grey,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '더 보기',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewsMorePage(newsList: newsProvider.getNewsList,))
                        );
                      },
                    );
                  }

                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
            const BannerAdWidget()
          ],
        ),
      ),
    );
  }
}
