import 'dart:convert';

import 'package:nogari/models/community/comment.dart';
import 'package:nogari/repositories/community/community_comment_repository.dart';
import 'package:http/http.dart' as http;

import '../../models/community/child_comment.dart';
import '../../models/global/global_variable.dart';
import '../../models/member/block.dart';
import '../../models/member/level.dart';
import '../member/member_repository.dart';
import '../member/member_repository_impl.dart';

class CommunityCommentRepositoryImpl implements CommunityCommentRepository {
  final MemberRepository _memberRepository = MemberRepositoryImpl();

  @override
  Future<List<Comment>> getCommentList(int boardSeq) async {
    final Uri uri = Uri.parse('${Glob.communityUrl}/comment/$boardSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<Comment> result =((json.decode(response.body) as List).map((e) => Comment.fromJson(e)).toList());

    /// 차단회원 글 필터
    List<Block> blockMemberList = await _memberRepository.getBlockMember();
    List<Comment> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < result.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (result[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            Comment comment = Comment(
                commentSeq: result[i].commentSeq,
                boardSeq: result[i].boardSeq, memberSeq: result[i].memberSeq, nickname: result[i].nickname,
                content: '차단된 회원의 댓글입니다.',
                deleteYN: result[i].deleteYN, regDt: result[i].regDt
            );
            filteredList.add(comment);
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(result[i]);
        }
      }

      result.clear();
      result.addAll(filteredList);
    }

    // 여기서 level 가져옴 (추후 닉네임도 빼버리고 여기서 한번에 가져오는걸로)
    if (result.isNotEmpty) {
      for (int i = 0; i < result.length; i++) {
        Level level = await _memberRepository.getLevelAndPoint(result[i].memberSeq);
        result[i].level = level.level;
      }
    }
    return result;
  }

  @override
  Future<List<ChildComment>> getChildCommentList(List<Comment> list) async {
    List<ChildComment> allList = [];

    for (int i = 0; i < list.length; i++) {
      int boardSeq = list[i].boardSeq;
      int commentSeq = list[i].commentSeq;

      final Uri uri = Uri.parse('${Glob.communityUrl}/child/comment/$boardSeq/$commentSeq');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      http.Response response = await http.get(
        uri,
        headers: headers,
      );
      List<ChildComment> result =((json.decode(response.body) as List).map((e) => ChildComment.fromJson(e)).toList());

      if (result.isNotEmpty) {
        for (int i = 0; i < result.length; i++) {
          Level level = await _memberRepository.getLevelAndPoint(result[i].memberSeq);
          result[i].level = level.level;
        }
      }

      allList = allList + result;
    }
    return allList;
  }
}
