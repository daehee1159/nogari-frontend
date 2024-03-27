import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/global/global_variable.dart';
import '../models/member/block_dto.dart';
import '../models/member/member_info_dto.dart';
import '../models/review/review_data_dto.dart';
import '../models/review/review_like_dto.dart';
import 'member_service.dart';

class ReviewService {
  // 커뮤니티 전체 게시글 조회 (백엔드에서 페이징해서 리턴)
  getReviewList(int page, int size) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewDataDto reviewDataDto = ReviewDataDto.fromJson(jsonData);

    /// 차단회원 글 필터
    List<BlockDto> blockMemberList = await MemberService().getBlockMember();
    List<Review> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < reviewDataDto.list.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (reviewDataDto.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(reviewDataDto.list[i]);
        }
      }

      reviewDataDto.list.clear();
      reviewDataDto.list.addAll(filteredList);
    }

    if (reviewDataDto.list.isNotEmpty) {
      for (int i = 0; i < reviewDataDto.list.length; i++) {
        Map<String, dynamic> memberResult = await MemberService().getMemberInfo(reviewDataDto.list[i].memberSeq);
        MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
        reviewDataDto.list[i].level = memberInfoDto.memberSeq;
      }
    }

    return reviewDataDto;
  }

  getLikeReviewList(int page, int size, int likeCount) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/like/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString(), 'likeCount': likeCount.toString()});
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewDataDto reviewDataDto = ReviewDataDto.fromJson(jsonData);

    /// 차단회원 글 필터
    List<BlockDto> blockMemberList = await MemberService().getBlockMember();
    List<Review> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < reviewDataDto.list.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (reviewDataDto.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(reviewDataDto.list[i]);
        }
      }

      reviewDataDto.list.clear();
      reviewDataDto.list.addAll(filteredList);
    }

    if (reviewDataDto.list.isNotEmpty) {
      for (int i = 0; i < reviewDataDto.list.length; i++) {
        Map<String, dynamic> memberResult = await MemberService().getMemberInfo(reviewDataDto.list[i].memberSeq);
        MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
        reviewDataDto.list[i].level = memberInfoDto.memberSeq;
      }
    }

    return reviewDataDto;
  }

  getNoticeReviewList(int page, int size) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/notice/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewDataDto reviewDataDto = ReviewDataDto.fromJson(jsonData);

    if (reviewDataDto.list.isNotEmpty) {
      for (int i = 0; i < reviewDataDto.list.length; i++) {
        Map<String, dynamic> memberResult = await MemberService().getMemberInfo(reviewDataDto.list[i].memberSeq);
        MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
        reviewDataDto.list[i].level = memberInfoDto.memberSeq;
      }
    }

    return reviewDataDto;
  }

  getSearchReview(String type, String searchCondition, String keyword, int? likeCount, int page, int size) async {
    Uri uri;

    switch (type) {
      case 'all':
        uri = Uri.parse('${Glob.reviewUrl}/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
        break;
      case 'like':
        uri = Uri.parse('${Glob.reviewUrl}/like/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString(), 'likeCount': likeCount.toString()});
        break;
      case 'notice':
        uri = Uri.parse('${Glob.reviewUrl}/notice/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
        break;
      default:
        uri = Uri.parse('${Glob.reviewUrl}/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
        break;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewDataDto reviewDataDto = ReviewDataDto.fromJson(jsonData);

    if (reviewDataDto.list.isNotEmpty) {
      for (int i = 0; i < reviewDataDto.list.length; i++) {
        Map<String, dynamic> memberResult = await MemberService().getMemberInfo(reviewDataDto.list[i].memberSeq);
        MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
        reviewDataDto.list[i].level = memberInfoDto.memberSeq;
      }
    }
    return reviewDataDto;
  }

  /// 내가 쓴 리뷰 리스트 조회
  getMyReview(int page, int size) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    final Uri uri = Uri.parse('${Glob.reviewUrl}/my/$memberSeq').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewDataDto reviewData = ReviewDataDto.fromJson(jsonData);

    return reviewData;
  }

  getCntOfComment(List<int> boardSeqList) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/comment/cnt').replace(queryParameters: {'boardSeqList' : boardSeqList.map((e) => e.toString()).join(',')});

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    Map<int, int> result = {};

    jsonData.forEach((key, value) {
      result[int.parse(key)] = value;
    });

    if (response.statusCode == 200) {
      // 필요한 형식으로 데이터 변환 후 반환
      return result;
    } else {
      // 오류 발생 시 예외 처리
      throw Exception('Failed to load data');
    }
  }

  addBoardViewCnt(int boardSeq) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/view/$boardSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  getBoardLikeCnt(int boardSeq) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/like/$boardSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<ReviewLikeDto> fetchData =((json.decode(response.body) as List).map((e) => ReviewLikeDto.fromJson(e)).toList());

    return fetchData;
  }

  setBoardLike(int boardSeq, int memberSeq) async {
    var url = Uri.parse('${Glob.reviewUrl}/like');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'boardSeq': boardSeq,
      'memberSeq': memberSeq,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  deleteBoardLike(int boardSeq, int memberSeq) async {
    var url = Uri.parse('${Glob.reviewUrl}/like');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'boardSeq': boardSeq,
      'memberSeq': memberSeq,
    });

    http.Response response = await http.delete(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  /// 리뷰 글쓰기
  setReview (int memberSeq, String nickname, String title, String content) async {
    var url = Uri.parse(Glob.reviewUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var saveData = jsonEncode({
      'memberSeq': memberSeq,
      'nickname': nickname,
      'title': title,
      'content': content,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  /// 리뷰 글 수정
  updateReview(int boardSeq, int memberSeq, String nickname, String title, String content) async {
    var url = Uri.parse(Glob.communityUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var saveData = jsonEncode({
      'boardSeq': boardSeq,
      'memberSeq': memberSeq,
      'nickname': nickname,
      'title': title,
      'content': content,
    });

    http.Response response = await http.patch(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  /// 댓글 쓰기
  setComment(int boardSeq, int memberSeq, String nickname, String content) async {
    var url = Uri.parse('${Glob.reviewUrl}/comment');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'boardSeq': boardSeq,
      'memberSeq': memberSeq,
      'nickname': nickname,
      'content': content,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  /// 대댓글 쓰기
  setChildComment(int commentSeq, int boardSeq, int memberSeq, String nickname, String content) async {
    var url = Uri.parse('${Glob.reviewUrl}/child/comment');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'commentSeq': commentSeq,
      'boardSeq': boardSeq,
      'memberSeq': memberSeq,
      'nickname': nickname,
      'content': content,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  /// 게시글, 댓글, 대댓글 삭제
  deleteReview(String type, int seq) async {
    var url;

    if (type == 'board') {
      url = Uri.parse('${Glob.reviewUrl}/$seq');
    } else if (type == 'comment') {
      url = Uri.parse('${Glob.reviewUrl}/comment/$seq');
    } else if (type == 'childComment') {
      url = Uri.parse('${Glob.reviewUrl}/child/comment/$seq');
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.delete(
      url,
      headers: headers,
    );

    return jsonDecode(response.body);
  }
}
