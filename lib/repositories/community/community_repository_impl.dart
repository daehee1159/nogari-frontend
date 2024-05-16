import 'dart:convert';

import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/community/community_data.dart';
import '../../models/community/community_like.dart';
import '../../models/global/global_variable.dart';

import 'package:http/http.dart' as http;

import '../../models/member/block.dart';
import '../../models/member/member_info.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final MemberRepository _memberRepository = MemberRepositoryImpl();

  @override
  Future<CommunityData> getCommunityList(int page, int size) async {
    final Uri uri = Uri.parse('${Glob.communityUrl}/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    CommunityData communityData = CommunityData.fromJson(jsonData);

    /// 차단회원 글 필터
    List<Block> blockMemberList = await _memberRepository.getBlockMember();
    List<Community> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < communityData.list.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (communityData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(communityData.list[i]);
        }
      }

      communityData.list.clear();
      communityData.list.addAll(filteredList);
    }

    if (communityData.list.isNotEmpty) {
      for (int i = 0; i < communityData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(communityData.list[i].memberSeq);
        communityData.list[i].level = memberInfo.memberSeq;
      }
    }

    return communityData;
  }

  @override
  Future<CommunityData> getLikeCommunityList(int page, int size, int likeCount) async {
    final Uri uri = Uri.parse('${Glob.communityUrl}/like/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString(), 'likeCount': likeCount.toString()});
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    CommunityData communityData = CommunityData.fromJson(jsonData);

    /// 차단회원 글 필터
    List<Block> blockMemberList = await _memberRepository.getBlockMember();
    List<Community> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < communityData.list.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (communityData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(communityData.list[i]);
        }
      }

      communityData.list.clear();
      communityData.list.addAll(filteredList);
    }

    if (communityData.list.isNotEmpty) {
      for (int i = 0; i < communityData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(communityData.list[i].memberSeq);
        communityData.list[i].level = memberInfo.memberSeq;
      }
    }

    return communityData;
  }

  @override
  Future<CommunityData> getNoticeCommunityList(int page, int size) async {
    final Uri uri = Uri.parse('${Glob.communityUrl}/notice/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    CommunityData communityData = CommunityData.fromJson(jsonData);

    if (communityData.list.isNotEmpty) {
      for (int i = 0; i < communityData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(communityData.list[i].memberSeq);
        communityData.list[i].level = memberInfo.memberSeq;
      }
    }

    return communityData;
  }

  @override
  Future<CommunityData> getSearchCommunity(String type, String searchCondition, String keyword, int? likeCount, int page, int size) async {
    Uri uri;

    switch (type) {
      case 'all':
        uri = Uri.parse('${Glob.communityUrl}/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
        break;
      case 'like':
        uri = Uri.parse('${Glob.communityUrl}/like/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString(), 'likeCount': likeCount.toString()});
        break;
      case 'notice':
        uri = Uri.parse('${Glob.communityUrl}/notice/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
        break;
      default:
        uri = Uri.parse('${Glob.communityUrl}/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
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

    CommunityData communityData = CommunityData.fromJson(jsonData);

    /// 차단회원 글 필터
    List<Block> blockMemberList = await _memberRepository.getBlockMember();
    List<Community> filteredList = [];

    if (blockMemberList.isNotEmpty) {
      for (int i = 0; i < communityData.list.length; i++) {
        bool isBlocked = false;
        for (int j = 0; j < blockMemberList.length; j++) {
          if (communityData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
            isBlocked = true;
            break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
          }
        }
        if (!isBlocked) {
          filteredList.add(communityData.list[i]);
        }
      }

      communityData.list.clear();
      communityData.list.addAll(filteredList);
    }

    if (communityData.list.isNotEmpty) {
      for (int i = 0; i < communityData.list.length; i++) {
        MemberInfo memberInfo = await _memberRepository.getMemberInfo(communityData.list[i].memberSeq);
        communityData.list[i].level = memberInfo.memberSeq;
      }
    }

    return communityData;
  }

  @override
  Future<Map<int, int>> getCntOfComment(List<int> boardSeqList) async {
    final Uri uri = Uri.parse('${Glob.communityUrl}/comment/cnt').replace(queryParameters: {'boardSeqList' : boardSeqList.map((e) => e.toString()).join(',')});

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
  Future<CommunityData> getMyCommunity(int page, int size) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    final Uri uri = Uri.parse('${Glob.communityUrl}/my/$memberSeq').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    CommunityData communityData = CommunityData.fromJson(jsonData);

    if (communityData.list.isNotEmpty) {
      MemberInfo memberInfo = await _memberRepository.getMemberInfo(communityData.list[0].memberSeq);
      for (int i = 0; i < communityData.list.length; i++) {
        communityData.list[i].level = memberInfo.memberSeq;
      }
    }

    return communityData;
  }

  @override
  Future<bool> addBoardViewCnt(int boardSeq) async {
    final Uri uri = Uri.parse('${Glob.communityUrl}/view/$boardSeq');

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
  Future<List<CommunityLike>> getBoardLikeCnt(int boardSeq) async {
    final Uri uri = Uri.parse('${Glob.communityUrl}/like/$boardSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<CommunityLike> fetchData =((json.decode(response.body) as List).map((e) => CommunityLike.fromJson(e)).toList());

    return fetchData;
  }

  @override
  Future<bool> setBoardLike(int boardSeq, int memberSeq) async {
    var url = Uri.parse('${Glob.communityUrl}/like');

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
    var url = Uri.parse('${Glob.communityUrl}/like');

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
  Future<bool> setCommunity(int memberSeq, String nickname, String title, String content, List<String> fileNameList) async {
    var url = Uri.parse(Glob.communityUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var saveData;

    switch (fileNameList.length) {
      case 0:
        saveData = jsonEncode({
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': null,
          'fileName2': null,
          'fileName3': null,
        });
        break;
      case 1:
        saveData = jsonEncode({
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': fileNameList[0]
        });
        break;
      case 2:
        saveData = jsonEncode({
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': fileNameList[0],
          'fileName2': fileNameList[1]
        });
        break;
      case 3:
        saveData = jsonEncode({
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': fileNameList[0],
          'fileName2': fileNameList[1],
          'fileName3': fileNameList[2],
        });
        break;
    }

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  @override
  Future<bool> updateCommunity(int boardSeq, int memberSeq, String nickname, String title, String content, List<String> fileNameList) async {
    var url = Uri.parse(Glob.communityUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var saveData;

    switch (fileNameList.length) {
      case 0:
        saveData = jsonEncode({
          'boardSeq': boardSeq,
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': null,
          'fileName2': null,
          'fileName3': null,
        });
      case 1:
        saveData = jsonEncode({
          'boardSeq': boardSeq,
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': fileNameList[0]
        });
        break;
      case 2:
        saveData = jsonEncode({
          'boardSeq': boardSeq,
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': fileNameList[0],
          'fileName2': fileNameList[1]
        });
        break;
      case 3:
        saveData = jsonEncode({
          'boardSeq': boardSeq,
          'memberSeq': memberSeq,
          'nickname': nickname,
          'title': title,
          'content': content,
          'fileName1': fileNameList[0],
          'fileName2': fileNameList[1],
          'fileName3': fileNameList[2],
        });
        break;
    }

    http.Response response = await http.patch(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  @override
  Future<int> setComment(int boardSeq, int memberSeq, String nickname, String content) async {
    var url = Uri.parse('${Glob.communityUrl}/comment');

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
    var url = Uri.parse('${Glob.communityUrl}/child/comment');

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
  Future<bool> deleteCommunity(String type, int seq) async {
    var url;

    if (type == 'board') {
      url = Uri.parse('${Glob.communityUrl}/$seq');
    } else if (type == 'comment') {
      url = Uri.parse('${Glob.communityUrl}/comment/$seq');
    } else if (type == 'childComment') {
      url = Uri.parse('${Glob.communityUrl}/child/comment/$seq');
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
