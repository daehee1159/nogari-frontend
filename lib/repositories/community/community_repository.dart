import 'package:flutter/material.dart';

import '../../models/community/community_data.dart';
import '../../models/community/community_like.dart';

abstract class CommunityRepository {
  Future<CommunityData> getCommunityList(int page, int size);
  Future<CommunityData> getLikeCommunityList(int page, int size, int likeCount);
  Future<CommunityData> getNoticeCommunityList(int page, int size);
  Future<CommunityData> getSearchCommunity(String type, String searchCondition, String keyword, int? likeCount, int page, int size);
  Future<Map<int, int>> getCntOfComment(List<int> boardSeqList);
  Future<CommunityData> getMyCommunity(int page, int size);
  Future<bool> addBoardViewCnt(int boardSeq);

  Future<List<CommunityLike>> getBoardLikeCnt(int boardSeq);
  Future<bool> setBoardLike(int boardSeq, int memberSeq);
  Future<bool> deleteBoardLike(int boardSeq, int memberSeq);

  Future<bool> setCommunity(int memberSeq, String nickname, String title, String content, List<String> fileNameList);
  Future<bool> updateCommunity(int boardSeq, int memberSeq, String nickname, String title, String content, List<String> fileNameList);

  Future<int> setComment(int boardSeq, int memberSeq, String nickname, String content);

  Future<int> setChildComment(int commentSeq, int boardSeq, int memberSeq, String nickname, String content);

  Future<bool> deleteCommunity(String type, int seq);
}
