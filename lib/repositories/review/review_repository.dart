import '../../models/review/review_data.dart';
import '../../models/review/review_like.dart';

abstract class ReviewRepository {
  Future<ReviewData> getReviewList(int page, int size);
  Future<ReviewData> getLikeReviewList(int page, int size, int likeCount);
  Future<ReviewData> getNoticeReviewList(int page, int size);

  Future<ReviewData> getSearchReview(String type, String searchCondition, String keyword, int? likeCount, int page, int size);

  Future<ReviewData> getMyReview(int page, int size);

  Future<Map<int, int>> getCntOfComment(List<int> boardSeqList);

  Future<bool> addBoardViewCnt(int boardSeq);

  Future<List<ReviewLike>> getBoardLikeCnt(int boardSeq);
  Future<bool> setBoardLike(int boardSeq, int memberSeq);
  Future<bool> deleteBoardLike(int boardSeq, int memberSeq);

  Future<bool> setReview(int memberSeq, String nickname, String title, String content);
  Future<bool> updateReview(int boardSeq, int memberSeq, String nickname, String title, String content);

  Future<int> setComment(int boardSeq, int memberSeq, String nickname, String content);
  Future<int> setChildComment(int commentSeq, int boardSeq, int memberSeq, String nickname, String content);
  Future<bool> deleteReview(String type, int seq);
}
