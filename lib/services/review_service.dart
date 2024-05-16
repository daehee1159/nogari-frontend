import '../enums/search_condition.dart';

class ReviewService {
  String getConditionLabel(SearchCondition condition) {
    switch (condition) {
      case SearchCondition.title:
        return '제목';
      case SearchCondition.titleContent:
        return '제목 + 내용';
      case SearchCondition.content:
        return '내용';
      case SearchCondition.nickname:
        return '닉네임';
    }
  }
}
