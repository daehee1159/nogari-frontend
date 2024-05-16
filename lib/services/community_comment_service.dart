// import 'dart:convert';
//
// import 'package:nogari/services/member_service.dart';
// import 'package:http/http.dart' as http;
//
// import '../models/global/global_variable.dart';
//
// class CommunityCommentService {
//   getCommentList(int boardSeq) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/comment/$boardSeq');
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
//     List<CommentDto> result =((json.decode(response.body) as List).map((e) => CommentDto.fromJson(e)).toList());
//
//     /// 차단회원 글 필터
//     List<BlockDto> blockMemberList = await MemberService().getBlockMember();
//     List<CommentDto> filteredList = [];
//
//     if (blockMemberList.isNotEmpty) {
//       for (int i = 0; i < result.length; i++) {
//         bool isBlocked = false;
//         for (int j = 0; j < blockMemberList.length; j++) {
//           if (result[i].memberSeq == blockMemberList[j].blockMemberSeq) {
//             CommentDto commentDto = CommentDto(
//                 commentSeq: result[i].commentSeq,
//                 boardSeq: result[i].boardSeq, memberSeq: result[i].memberSeq, nickname: result[i].nickname,
//                 content: '차단된 회원의 댓글입니다.',
//                 deleteYN: result[i].deleteYN, regDt: result[i].regDt
//             );
//             filteredList.add(commentDto);
//             isBlocked = true;
//             break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
//           }
//         }
//         if (!isBlocked) {
//           filteredList.add(result[i]);
//         }
//       }
//
//       result.clear();
//       result.addAll(filteredList);
//     }
//
//     // 여기서 level 가져옴 (추후 닉네임도 빼버리고 여기서 한번에 가져오는걸로)
//     if (result.isNotEmpty) {
//       for (int i = 0; i < result.length; i++) {
//         Map<String, dynamic> rankResponse = await MemberService().getLevelAndPoint(result[i].memberSeq);
//         LevelDto levelDto = LevelDto.fromJson(rankResponse);
//         result[i].level = levelDto.level;
//       }
//     }
//     return result;
//   }
//
//   getChildComment(int boardSeq, int commentSeq) async {
//     final Uri uri = Uri.parse('${Glob.communityUrl}/child/comment/$boardSeq/$commentSeq');
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
//     List<ChildCommentDto> result =((json.decode(response.body) as List).map((e) => ChildCommentDto.fromJson(e)).toList());
//
//     /// 차단회원 글 필터
//     List<BlockDto> blockMemberList = await MemberService().getBlockMember();
//     List<ChildCommentDto> filteredList = [];
//
//     if (blockMemberList.isNotEmpty) {
//       for (int i = 0; i < result.length; i++) {
//         bool isBlocked = false;
//         for (int j = 0; j < blockMemberList.length; j++) {
//           if (result[i].memberSeq == blockMemberList[j].blockMemberSeq) {
//             ChildCommentDto childCommentDto = ChildCommentDto(
//                 childCommentSeq: result[i].childCommentSeq,
//                 commentSeq: result[i].commentSeq,
//                 boardSeq: result[i].boardSeq, memberSeq: result[i].memberSeq, nickname: result[i].nickname,
//                 content: '차단된 회원의 댓글입니다.',
//                 deleteYN: result[i].deleteYN, regDt: result[i].regDt,
//             );
//             filteredList.add(childCommentDto);
//             isBlocked = true;
//             break; // 블록된 회원을 발견했으므로 추가 반복은 불필요
//           }
//         }
//         if (!isBlocked) {
//           filteredList.add(result[i]);
//         }
//       }
//
//       result.clear();
//       result.addAll(filteredList);
//     }
//
//     if (result.isNotEmpty) {
//       for (int i = 0; i < result.length; i++) {
//         Map<String, dynamic> rankResponse = await MemberService().getLevelAndPoint(result[i].memberSeq);
//         LevelDto levelDto = LevelDto.fromJson(rankResponse);
//         result[i].level = levelDto.level;
//       }
//     }
//
//     return result;
//   }
//
//   /// 댓글 리스트를 가지고 대댓글의 총 리스트를 만듬
//   getChildCommentList(List<CommentDto> list) async {
//     List<ChildCommentDto> allList = [];
//
//     for (int i = 0; i < list.length; i++) {
//       int boardSeq = list[i].boardSeq;
//       int commentSeq = list[i].commentSeq;
//
//       final Uri uri = Uri.parse('${Glob.communityUrl}/child/comment/$boardSeq/$commentSeq');
//
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//       };
//
//       http.Response response = await http.get(
//         uri,
//         headers: headers,
//       );
//       List<ChildCommentDto> result =((json.decode(response.body) as List).map((e) => ChildCommentDto.fromJson(e)).toList());
//
//       if (result.isNotEmpty) {
//         for (int i = 0; i < result.length; i++) {
//           Map<String, dynamic> rankResponse = await MemberService().getLevelAndPoint(result[i].memberSeq);
//           LevelDto levelDto = LevelDto.fromJson(rankResponse);
//           result[i].level = levelDto.level;
//         }
//       }
//
//       allList = allList + result;
//     }
//     return allList;
//   }
// }
