enum BoardType {
  community,
  review,
  communityComment,
  reviewComment,
  communityChildComment,
  reviewChildComment
}

extension BoardTypeExtension on BoardType {
  String get value {
    switch (this) {
      case BoardType.community:
        return 'community';
      case BoardType.review:
        return 'review';
      case BoardType.communityComment:
        return 'communityComment';
      case BoardType.reviewComment:
        return 'reviewComment';
      case BoardType.communityChildComment:
        return 'communityChildComment';
      case BoardType.reviewChildComment:
        return 'reviewChildComment';
    }
  }

  String toJson() => value;
}
