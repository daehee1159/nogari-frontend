import 'package:nogari/models/review/review_child_comment.dart';
import 'package:nogari/models/review/review_comment.dart';

abstract class ReviewCommentRepository {
  Future<List<ReviewComment>> getCommentList(int boardSeq);
  Future<List<ReviewChildComment>> getChildCommentList(List<ReviewComment> list);
}
