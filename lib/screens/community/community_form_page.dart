import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/services/community_service.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/common_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/community/community_provider.dart';
import '../../models/global/global_variable.dart';
import '../../models/member/member_info_provider.dart';
import '../../models/member/point_history_provider.dart';

class CommunityFormPage extends StatefulWidget {
  const CommunityFormPage({super.key});

  @override
  State<CommunityFormPage> createState() => _CommunityFormPageState();
}

class _CommunityFormPageState extends State<CommunityFormPage> {
  Timer? _debounce;
  final CommonService storage = CommonService();
  final CommonService commonService = CommonService();
  final CommonWidget commonWidget = CommonWidget();
  final MemberService memberService = MemberService();
  final CommonAlert commonAlert = CommonAlert();

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];
  firebase_storage.FirebaseStorage _storageRef = firebase_storage.FirebaseStorage.instance;
  List<String> _arrImageUrls = [];
  List<String> _arrFileNames = [];
  int uploadItem = 0;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);
    PointHistoryProvider pointHistoryProvider = Provider.of<PointHistoryProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '커뮤니티 글쓰기',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _selectedFiles = [];
            _arrImageUrls = [];
            _arrFileNames = [];

            communityProvider.setTitleController = '';
            communityProvider.setContentController = '';

            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.007, 0, 0),
              child: Text(
                "저장",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              if (communityProvider.getTitleController.text.isEmpty || communityProvider.getTitleController.text == '') {
                return commonAlert.spaceError(context, '제목');
              } else if (communityProvider.getContentController.text.isEmpty || communityProvider.getContentController.text == '') {
                return commonAlert.spaceError(context, '내용');
              } else {
                if (_selectedFiles.isEmpty) {
                  // 사진 없음
                } else {
                  for (int i = 0; i < _selectedFiles.length; i++) {
                    _arrFileNames.add(_selectedFiles[i].name);
                  }
                }

                try {
                  await uploadFunction(_selectedFiles, context);
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  int? memberSeq = memberInfoProvider.getMemberSeq ?? pref.getInt(Glob.memberSeq);
                  String nickname = memberInfoProvider.getNickName.toString();

                  bool result = await CommunityService().setCommunity(memberSeq!, nickname, communityProvider.getTitleController.text, communityProvider.getContentController.text, _arrFileNames);
                  if (result && mounted) {
                    // 성공
                    _selectedFiles = [];
                    _arrImageUrls = [];
                    _arrFileNames = [];

                    communityProvider.setTitleController = '';
                    communityProvider.setContentController = '';

                    pointHistoryProvider.addCommunityWriting();
                    if (pointHistoryProvider.getCommunityWriting >= pointHistoryProvider.getTotalCommunityWriting == false) {
                      await memberService.setPoint('COMMUNITY_WRITING');
                    }

                    if (mounted) {
                      commonWidget.saveSuccessAlert(context);
                    }
                  } else {
                    if (mounted) {
                      return commonAlert.errorAlert(context);
                    }
                  }
                } catch(e) {
                  if (mounted) {
                    return commonAlert.errorAlert(context);
                  }
                }
              }
            },
          )
        ],
      ),
      body: GestureDetector(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '제목',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10,),
                Consumer<CommunityProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: TextField(
                        // 이게 최선이 아님; 화면마다 어떻게 될 줄 알고;;
                        // textAlignVertical: TextAlignVertical(y: -0.5),
                        controller: communityProvider.getTitleController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          commonService.debounce(() {
                            communityProvider.setTitleController = communityProvider.getTitleController.text;
                            communityProvider.callNotify();
                          });
                        },
                      ),
                    );
                  }
                ),
                const SizedBox(height: 10,),
                Text(
                  '내용',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Consumer<CommunityProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      // color: Colors.grey,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: TextField(
                        controller: communityProvider.getContentController,
                        maxLines: 10,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)
                        ),
                        onChanged: (value) {
                          commonService.debounce(() {
                            communityProvider.setContentController = communityProvider.getContentController.text;
                            communityProvider.callNotify();
                          });
                        },
                      ),
                    );
                  }
                ),
                const SizedBox(height: 10,),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '사진 선택하기',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                selectImages(context);
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              label: Text(
                                "사진 선택",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    _selectedFiles.isEmpty ?
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: Center(
                              child: Text(
                                "선택된 이미지가 없어요.",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                              ))),
                          ) :
                      Container(
                        padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.05, 0, 0),
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: GridView.builder(
                          itemCount: _selectedFiles.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 0.0),
                              child: Image.file(
                                File(_selectedFiles[index].path),
                                fit: BoxFit.fitWidth,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }

  uploadFunction(List<XFile> images, BuildContext context) {
    setState(() {
      _isUploading = true;
    });
    for (int i = 0; i < images.length; i++) {
      var imageUrl = uploadFile(images[i], context);
      if (imageUrl.toString() == "false") {
        /// alert 띄우고 빠져나가기
        break;
      } else {
        _arrImageUrls.add(imageUrl.toString());
      }
    }
  }

  Future<String> uploadFile(XFile _image, BuildContext context) async {
    try {
      firebase_storage.Reference reference = _storageRef.ref().child('community').child(_image.name);
      firebase_storage.UploadTask uploadTask = reference.putFile(File(_image.path));
      await uploadTask.whenComplete(() {
        setState(() {
          uploadItem++;
          if (uploadItem == _selectedFiles.length) {
            _isUploading = false;
            uploadItem = 0;
            _arrFileNames.add(_image.name);
            // GlobalAlert().globSaveSuccessAlert(context);
          }
        });
      });
      return await reference.getDownloadURL();
    } catch(e) {
      return "false";
    }
  }

  Future<void> selectImages(BuildContext context) async {
    if (_selectedFiles != null) {
      _selectedFiles.clear();
    }
    try {
      final List<XFile>? imgs = await _picker.pickMultiImage();
      if (imgs!.isNotEmpty && imgs.length <= 3) {
        _selectedFiles.addAll(imgs);
      } else if (imgs.length >= 4) {
        commonAlert.selectedImageError(context);
      } else if (imgs.isEmpty) {
      }
    } catch (e) {
      // print("Something Wrong" + e.toString());
    }

    setState(() {});
  }

  void debounce() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      // print('user finished typing');
    });
  }
}
