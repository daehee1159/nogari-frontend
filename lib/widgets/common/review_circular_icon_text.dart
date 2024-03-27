import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_provider.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_provider.dart';
import '../../models/review/review_data_dto.dart';

class ReviewCircularIconText extends StatelessWidget {
  final IconData icon;
  final int cnt;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final Review review;

  const ReviewCircularIconText({
    required this.icon,
    required this.cnt,
    this.size = 60.0,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.green,
    required this.review,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    bool isMyPress = reviewProvider.getReviewList.firstWhere((review) => review.boardSeq == this.review.boardSeq, orElse: () => reviewProvider.getReview).isMyPress;

    return Column(
      children: [
        Consumer<CommunityProvider>(
            builder: (context, provider, _) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  color: (isMyPress) ? backgroundColor : Colors.grey,
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.8, // 아이콘 크기의 비율로 조절
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: iconColor,
                        size: size * 0.5,
                      ),
                      // SizedBox(height: 2.0),
                      Text(
                        reviewProvider.getReviewList.firstWhere((review) => review.boardSeq == this.review.boardSeq, orElse: () => reviewProvider.getReview).likeCnt.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        ),
      ],
    );
  }
}
