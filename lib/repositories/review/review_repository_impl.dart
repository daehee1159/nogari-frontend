import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:nogari/repositories/review/review_repository.dart';

import '../../models/global/global_variable.dart';
import '../../models/member/block.dart';
import '../../models/member/member_info.dart';
import '../../models/review/review_data.dart';
import '../../models/review/review_like.dart';
import '../member/member_repository.dart';
import '../member/member_repository_impl.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final MemberRepository _memberRepository = MemberRepositoryImpl();

  @override
  Future<ReviewData> getReviewList(int page, int size) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewData reviewData = ReviewData.fromJson(jsonData);

    /// 차단회원 글 필터
    List<Block> blockMemberList = await _memberRepository.getBlockMember();
    List<Review> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < reviewData.list.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (reviewData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(reviewData.list[i]);
        }
      }

      reviewData.list.clear();
      reviewData.list.addAll(filteredList);
    }

    if (reviewData.list.isNotEmpty) {
      for (int i = 0; i < reviewData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(reviewData.list[i].memberSeq);
        reviewData.list[i].level = memberInfo.memberSeq;
      }
    }

    return reviewData;
  }

  @override
  Future<ReviewData> getLikeReviewList(int page, int size, int likeCount) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/like/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString(), 'likeCount': likeCount.toString()});
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewData reviewData = ReviewData.fromJson(jsonData);

    /// 차단회원 글 필터
    List<Block> blockMemberList = await _memberRepository.getBlockMember();
    List<Review> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < reviewData.list.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (reviewData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(reviewData.list[i]);
        }
      }

      reviewData.list.clear();
      reviewData.list.addAll(filteredList);
    }

    if (reviewData.list.isNotEmpty) {
      for (int i = 0; i < reviewData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(reviewData.list[i].memberSeq);
        reviewData.list[i].level = memberInfo.memberSeq;
      }
    }

    return reviewData;
  }

  @override
  Future<ReviewData> getNoticeReviewList(int page, int size) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/notice/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    ReviewData reviewData = ReviewData.fromJson(jsonData);

    if (reviewData.list.isNotEmpty) {
      for (int i = 0; i < reviewData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(reviewData.list[i].memberSeq);
        reviewData.list[i].level = memberInfo.memberSeq;
      }
    }

    return reviewData;
  }

  @override
  Future<ReviewData> getSearchReview(String type, String searchCondition, String keyword, int? likeCount, int page, int size) async {
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

    ReviewData reviewData = ReviewData.fromJson(jsonData);

    if (reviewData.list.isNotEmpty) {
      for (int i = 0; i < reviewData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(reviewData.list[i].memberSeq);
        reviewData.list[i].level = memberInfo.memberSeq;
      }
    }
    return reviewData;
  }

  @override
  Future<ReviewData> getMyReview(int page, int size) async {
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

    ReviewData reviewData = ReviewData.fromJson(jsonData);

    return reviewData;
  }

  @override
  Future<Map<int, int>> getCntOfComment(List<int> boardSeqList) async {
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

  @override
  Future<bool> addBoardViewCnt(int boardSeq) async {
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

  @override
  Future<List<ReviewLike>> getBoardLikeCnt(int boardSeq) async {
    final Uri uri = Uri.parse('${Glob.reviewUrl}/like/$boardSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<ReviewLike> fetchData =((json.decode(response.body) as List).map((e) => ReviewLike.fromJson(e)).toList());

    return fetchData;
  }

  @override
  Future<bool> setBoardLike(int boardSeq, int memberSeq) async {
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

  @override
  Future<bool> deleteBoardLike(int boardSeq, int memberSeq) async {
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

  @override
  Future<bool> setReview(int memberSeq, String nickname, String title, String content) async {
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

  @override
  Future<bool> updateReview(int boardSeq, int memberSeq, String nickname, String title, String content) async {
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

  @override
  Future<int> setComment(int boardSeq, int memberSeq, String nickname, String content) async {
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

  @override
  Future<int> setChildComment(int commentSeq, int boardSeq, int memberSeq, String nickname, String content) async {
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

  @override
  Future<bool> deleteReview(String type, int seq) async {
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
