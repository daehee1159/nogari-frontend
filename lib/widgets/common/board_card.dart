import 'package:flutter/material.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/views/community/paging_my_community.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_data.dart';
import '../../models/review/review_data.dart';
import '../../views/community/community_detail_page.dart';

class BoardCard extends StatelessWidget {
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final String widgetTitle;
  final String type;

  BoardCard({super.key, required this.type, required this.widgetTitle});

  @override
  Widget build(BuildContext context) {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);

    return FutureBuilder(
      future: (type == 'community') ? _communityRepository.getMyCommunity(communityViewModel.getCurrentPage, communityViewModel.getSize) : _reviewRepository.getMyReview(reviewViewModel.getCurrentPage, reviewViewModel.getSize),
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
            CommunityData communityData = snapshot.data;
            communityViewModel.setCommunityData = communityData;
            communityViewModel.setTotalPages = communityData.pages;
            communityViewModel.setMyCommunityList = communityData.list;
            Future.microtask(() => communityViewModel.callNotify());

            return Consumer<CommunityViewModel>(
              builder: (context, viewModel, _) {
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
                      if (viewModel.getMyCommunityList.isEmpty)
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
                        itemCount: viewModel.getMyCommunityList.length >= 5 ? 5 : viewModel.getMyCommunityList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                    viewModel.getMyCommunityList[index].title
                                ),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: viewModel.getMyCommunityList[index])));
                                },
                              ),
                              (index == viewModel.getMyCommunityList.length -1) ? const SizedBox() : const CustomDivider(height: 1, color: Colors.grey),
                            ],
                          );
                        },
                      ),
                      if (viewModel.getMyCommunityList.length > 5)
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
            ReviewData reviewData = snapshot.data;
            reviewViewModel.setReviewData = reviewData;
            reviewViewModel.setMyReviewList = reviewData.list;
            Future.microtask(() => reviewViewModel.callNotify());

            return Consumer<ReviewViewModel>(
                builder: (context, viewModel, _) {
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
                        if (viewModel.getMyReviewList.isEmpty)
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
                          itemCount: viewModel.getMyReviewList.length >= 5 ? 5 : viewModel.getMyReviewList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                      viewModel.getMyReviewList[index].title
                                  ),
                                  onTap: () {
                                  },
                                ),
                                (index == viewModel.getMyReviewList.length -1) ? const SizedBox() : const CustomDivider(height: 1, color: Colors.grey),
                              ],
                            );
                          },
                        ),
                        if (viewModel.getMyReviewList.length > 5)
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
