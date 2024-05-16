import 'package:nogari/models/community/comment.dart';

import '../../models/community/child_comment.dart';

abstract class CommunityCommentRepository {
  Future<List<Comment>> getCommentList(int boardSeq);
  Future<List<ChildComment>> getChildCommentList(List<Comment> list);
}
