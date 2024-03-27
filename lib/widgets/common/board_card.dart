import 'package:flutter/material.dart';
import 'package:nogari/models/community/community_data_dto.dart';
import 'package:nogari/models/review/review_provider.dart';
import 'package:nogari/screens/community/paging_my_community.dart';
import 'package:nogari/services/community_service.dart';
import 'package:nogari/services/review_service.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_provider.dart';
import '../../models/review/review_data_dto.dart';
import '../../screens/community/community_detail_page.dart';

class BoardCard extends StatelessWidget {
  final String widgetTitle;
  final String type;

  const BoardCard({super.key, required this.type, required this.widgetTitle});

  @override
  Widget build(BuildContext context) {
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    return FutureBuilder(
      future: (type == 'community') ? CommunityService().getMyCommunity(communityProvider.getCurrentPage, communityProvider.getSize) : ReviewService().getMyReview(reviewProvider.getCurrentPage, reviewProvider.getSize),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xff33D679),)
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else {
          if (type == 'community') {
            CommunityDataDto communityData = snapshot.data;
            communityProvider.setCommunityData = communityData;
            communityProvider.setTotalPages = communityData.pages;
            communityProvider.setMyCommunityList = communityData.list;
            Future.microtask(() => communityProvider.callNotify());

            return Consumer<CommunityProvider>(
              builder: (context, provider, _) {
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          widgetTitle,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (communityProvider.getMyCommunityList.isEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: Center(
                            child: Text(
                              '데이터가 없습니다.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: communityProvider.getMyCommunityList.length >= 5 ? 5 : communityProvider.getMyCommunityList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  communityProvider.getMyCommunityList[index].title
                                ),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: communityProvider.getMyCommunityList[index])));
                                },
                              ),
                              (index == communityProvider.getMyCommunityList.length -1) ? const SizedBox() : const CustomDivider(height: 1, color: Colors.grey),
                            ],
                          );
                        },
                      ),
                      if (communityProvider.getMyCommunityList.length > 5)
                        InkWell(
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                '더 보기',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PagingMyCommunity()));
                          },
                        ),
                    ],
                  ),
                );
              }
            );
          } else {
            ReviewDataDto reviewData = snapshot.data;
            reviewProvider.setReviewData = reviewData;
            reviewProvider.setMyReviewList = reviewData.list;
            Future.microtask(() => communityProvider.callNotify());

            return Consumer<ReviewProvider>(
                builder: (context, provider, _) {
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            widgetTitle,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (reviewProvider.getMyReviewList.isEmpty)
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: Center(
                              child: Text(
                                '데이터가 없습니다.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviewProvider.getMyReviewList.length >= 5 ? 5 : reviewProvider.getMyReviewList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    reviewProvider.getMyReviewList[index].title
                                  ),
                                  onTap: () {
                                  },
                                ),
                                (index == reviewProvider.getMyReviewList.length -1) ? const SizedBox() : const CustomDivider(height: 1, color: Colors.grey),
                              ],
                            );
                          },
                        ),
                        if (reviewProvider.getMyReviewList.length > 5)
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  '더 보기',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PagingMyCommunity()));
                            },
                          ),
                      ],
                    ),
                  );
                }
            );
          }
        }
      }
    );
  }
}
