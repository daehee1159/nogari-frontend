import 'package:flutter/material.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../models/review/review_data.dart';

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
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    bool isMyPress = reviewViewModel.getReviewList.firstWhere((review) => review.boardSeq == this.review.boardSeq, orElse: () => reviewViewModel.getReview).isMyPress;

    return Column(
      children: [
        Consumer<ReviewViewModel>(
            builder: (context, viewModel, _) {
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
                        viewModel.getReviewList.firstWhere((review) => review.boardSeq == this.review.boardSeq, orElse: () => viewModel.getReview).likeCnt.toString(),
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
