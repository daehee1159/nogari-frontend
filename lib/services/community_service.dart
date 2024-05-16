// import 'dart:convert';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../models/global/global_variable.dart';
// import 'member_service.dart';
//
// class CommunityService {
//   // 커뮤니티 전체 게시글 조회 (백엔드에서 페이징해서 리턴)
//   getCommunityList(int page, int size) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     Map<String, dynamic> jsonData = jsonDecode(response.body);
//
//     CommunityDataDto communityData = CommunityDataDto.fromJson(jsonData);
//
//     /// 차단회원 글 필터
//     List<BlockDto> blockMemberList = await MemberService().getBlockMember();
//     List<Community> filteredList = [];
//
//     if (blockMemberList.isNotEmpty) {
//       for (int i = 0; i < communityData.list.length; i++) {
//         bool isBlocked = false;
//         for (int j = 0; j < blockMemberList.length; j++) {
//           if (communityData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
//             isBlocked = true;
//             break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
//           }
//         }
//         if (!isBlocked) {
//           filteredList.add(communityData.list[i]);
//         }
//       }
//
//       communityData.list.clear();
//       communityData.list.addAll(filteredList);
//     }
//
//     if (communityData.list.isNotEmpty) {
//       for (int i = 0; i < communityData.list.length; i++) {
//         Map<String, dynamic> memberResult = await MemberService().getMemberInfo(communityData.list[i].memberSeq);
//         MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
//         communityData.list[i].level = memberInfoDto.memberSeq;
//       }
//     }
//
//     return communityData;
//   }
//
//   getLikeCommunityList(int page, int size, int likeCount) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/like/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString(), 'likeCount': likeCount.toString()});
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     Map<String, dynamic> jsonData = jsonDecode(response.body);
//
//     CommunityDataDto communityData = CommunityDataDto.fromJson(jsonData);
//
//     /// 차단회원 글 필터
//     List<BlockDto> blockMemberList = await MemberService().getBlockMember();
//     List<Community> filteredList = [];
//
//     if (blockMemberList.isNotEmpty) {
//       for (int i = 0; i < communityData.list.length; i++) {
//         bool isBlocked = false;
//         for (int j = 0; j < blockMemberList.length; j++) {
//           if (communityData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
//             isBlocked = true;
//             break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
//           }
//         }
//         if (!isBlocked) {
//           filteredList.add(communityData.list[i]);
//         }
//       }
//
//       communityData.list.clear();
//       communityData.list.addAll(filteredList);
//     }
//
//     if (communityData.list.isNotEmpty) {
//       for (int i = 0; i < communityData.list.length; i++) {
//         Map<String, dynamic> memberResult = await MemberService().getMemberInfo(communityData.list[i].memberSeq);
//         MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
//         communityData.list[i].level = memberInfoDto.memberSeq;
//       }
//     }
//
//     return communityData;
//   }
//
//   getNoticeCommunityList(int page, int size) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/notice/page').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     Map<String, dynamic> jsonData = jsonDecode(response.body);
//
//     CommunityDataDto communityData = CommunityDataDto.fromJson(jsonData);
//
//     if (communityData.list.isNotEmpty) {
//       for (int i = 0; i < communityData.list.length; i++) {
//         Map<String, dynamic> memberResult = await MemberService().getMemberInfo(communityData.list[i].memberSeq);
//         MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
//         communityData.list[i].level = memberInfoDto.memberSeq;
//       }
//     }
//
//     return communityData;
//   }
//
//   getSearchCommunity(String type, String searchCondition, String keyword, int? likeCount, int page, int size) async {
//     Uri uri;
//
//     switch (type) {
//       case 'all':
//         uri = Uri.parse('${Glob.communityUrl}/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
//         break;
//       case 'like':
//         uri = Uri.parse('${Glob.communityUrl}/like/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString(), 'likeCount': likeCount.toString()});
//         break;
//       case 'notice':
//         uri = Uri.parse('${Glob.communityUrl}/notice/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
//         break;
//       default:
//         uri = Uri.parse('${Glob.communityUrl}/search').replace(queryParameters: {'searchCondition': searchCondition, 'keyword': keyword, 'p': page.toString(), 'size': size.toString()});
//         break;
//     }
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     Map<String, dynamic> jsonData = jsonDecode(response.body);
//
//     CommunityDataDto communityData = CommunityDataDto.fromJson(jsonData);
//
//     /// 차단회원 글 필터
//     List<BlockDto> blockMemberList = await MemberService().getBlockMember();
//     List<Community> filteredList = [];
//
//     if (blockMemberList.isNotEmpty) {
//       for (int i = 0; i < communityData.list.length; i++) {
//         bool isBlocked = false;
//         for (int j = 0; j < blockMemberList.length; j++) {
//           if (communityData.list[i].memberSeq == blockMemberList[j].blockMemberSeq) {
//             isBlocked = true;
//             break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
//           }
//         }
//         if (!isBlocked) {
//           filteredList.add(communityData.list[i]);
//         }
//       }
//
//       communityData.list.clear();
//       communityData.list.addAll(filteredList);
//     }
//
//     if (communityData.list.isNotEmpty) {
//       for (int i = 0; i < communityData.list.length; i++) {
//         Map<String, dynamic> memberResult = await MemberService().getMemberInfo(communityData.list[i].memberSeq);
//         MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
//         communityData.list[i].level = memberInfoDto.memberSeq;
//       }
//     }
//
//     return communityData;
//
//   }
//
//   getCntOfComment(List<int> boardSeqList) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/comment/cnt').replace(queryParameters: {'boardSeqList' : boardSeqList.map((e) => e.toString()).join(',')});
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     Map<String, dynamic> jsonData = jsonDecode(response.body);
//
//     Map<int, int> result = {};
//
//     jsonData.forEach((key, value) {
//       result[int.parse(key)] = value;
//     });
//
//     if (response.statusCode == 200) {
//       // 필요한 형식으로 데이터 변환 후 반환
//       return result;
//     } else {
//       // 오류 발생 시 예외 처리
//       throw Exception('Failed to load data');
//     }
//   }
//
//   getCommunityBySeq(int boardSeq) async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     var memberSeq = pref.getInt(Glob.memberSeq);
//     final Uri uri = Uri.parse('${Glob.communityUrl}/$boardSeq');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   /// 내가 쓴 커뮤니티 리스트 조회
//   getMyCommunity(int page, int size) async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     var memberSeq = pref.getInt(Glob.memberSeq);
//
//     final Uri uri = Uri.parse('${Glob.communityUrl}/my/$memberSeq').replace(queryParameters: {'p': page.toString(), 'size': size.toString()});
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     Map<String, dynamic> jsonData = jsonDecode(response.body);
//
//     CommunityDataDto communityData = CommunityDataDto.fromJson(jsonData);
//
//     if (communityData.list.isNotEmpty) {
//       Map<String, dynamic> memberResult = await MemberService().getMemberInfo(communityData.list[0].memberSeq);
//       MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(memberResult);
//       for (int i = 0; i < communityData.list.length; i++) {
//         communityData.list[i].level = memberInfoDto.memberSeq;
//       }
//     }
//
//     return communityData;
//   }
//
//   addBoardViewCnt(int boardSeq) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/view/$boardSeq');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   getBoardLikeCnt(int boardSeq) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/like/$boardSeq');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.get(
//       uri,
//       headers: headers,
//     );
//
//     List<CommunityLikeDto> fetchData =((json.decode(response.body) as List).map((e) => CommunityLikeDto.fromJson(e)).toList());
//
//     return fetchData;
//   }
//
//   setBoardLike(int boardSeq, int memberSeq) async {
//     var url = Uri.parse('${Glob.communityUrl}/like');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     final saveData = jsonEncode({
//       'boardSeq': boardSeq,
//       'memberSeq': memberSeq,
//     });
//
//     http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: saveData
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   deleteBoardLike(int boardSeq, int memberSeq) async {
//     var url = Uri.parse('${Glob.communityUrl}/like');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     final saveData = jsonEncode({
//       'boardSeq': boardSeq,
//       'memberSeq': memberSeq,
//     });
//
//     http.Response response = await http.delete(
//         url,
//         headers: headers,
//         body: saveData
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   /// 커뮤니티 글쓰기
//   setCommunity (int memberSeq, String nickname, String title, String content, List<String> fileNameList) async {
//     var url = Uri.parse(Glob.communityUrl);
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     var saveData;
//
//     switch (fileNameList.length) {
//       case 0:
//         saveData = jsonEncode({
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': null,
//           'fileName2': null,
//           'fileName3': null,
//         });
//         break;
//       case 1:
//         saveData = jsonEncode({
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': fileNameList[0]
//         });
//         break;
//       case 2:
//         saveData = jsonEncode({
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': fileNameList[0],
//           'fileName2': fileNameList[1]
//         });
//         break;
//       case 3:
//         saveData = jsonEncode({
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': fileNameList[0],
//           'fileName2': fileNameList[1],
//           'fileName3': fileNameList[2],
//         });
//         break;
//     }
//
//     http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: saveData
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   /// 커뮤니티 글 수정
//   updateCommunity(int boardSeq, int memberSeq, String nickname, String title, String content, List<String> fileNameList) async {
//     var url = Uri.parse(Glob.communityUrl);
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     var saveData;
//
//     switch (fileNameList.length) {
//       case 0:
//         saveData = jsonEncode({
//           'boardSeq': boardSeq,
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': null,
//           'fileName2': null,
//           'fileName3': null,
//         });
//       case 1:
//         saveData = jsonEncode({
//           'boardSeq': boardSeq,
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': fileNameList[0]
//         });
//         break;
//       case 2:
//         saveData = jsonEncode({
//           'boardSeq': boardSeq,
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': fileNameList[0],
//           'fileName2': fileNameList[1]
//         });
//         break;
//       case 3:
//         saveData = jsonEncode({
//           'boardSeq': boardSeq,
//           'memberSeq': memberSeq,
//           'nickname': nickname,
//           'title': title,
//           'content': content,
//           'fileName1': fileNameList[0],
//           'fileName2': fileNameList[1],
//           'fileName3': fileNameList[2],
//         });
//         break;
//     }
//
//     http.Response response = await http.patch(
//         url,
//         headers: headers,
//         body: saveData
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   /// 댓글 쓰기
//   setComment(int boardSeq, int memberSeq, String nickname, String content) async {
//     var url = Uri.parse('${Glob.communityUrl}/comment');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     final saveData = jsonEncode({
//       'boardSeq': boardSeq,
//       'memberSeq': memberSeq,
//       'nickname': nickname,
//       'content': content,
//     });
//
//     http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: saveData
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   /// 대댓글 쓰기
//   setChildComment(int commentSeq, int boardSeq, int memberSeq, String nickname, String content) async {
//     var url = Uri.parse('${Glob.communityUrl}/child/comment');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     final saveData = jsonEncode({
//       'commentSeq': commentSeq,
//       'boardSeq': boardSeq,
//       'memberSeq': memberSeq,
//       'nickname': nickname,
//       'content': content,
//     });
//
//     http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: saveData
//     );
//
//     return jsonDecode(response.body);
//   }
//
//   /// 게시글, 댓글, 대댓글 삭제
//   deleteCommunity(String type, int seq) async {
//     var url;
//
//     if (type == 'board') {
//       url = Uri.parse('${Glob.communityUrl}/$seq');
//     } else if (type == 'comment') {
//       url = Uri.parse('${Glob.communityUrl}/comment/$seq');
//     } else if (type == 'childComment') {
//       url = Uri.parse('${Glob.communityUrl}/child/comment/$seq');
//     }
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
//
//     http.Response response = await http.delete(
//       url,
//       headers: headers,
//     );
//
//     return jsonDecode(response.body);
//   }
// }
