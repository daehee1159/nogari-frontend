import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:nogari/models/community/community_data.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/common_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';

class CommunityUpdateFormPage extends StatefulWidget {
  final Community postDetail;

  const CommunityUpdateFormPage({super.key, required this.postDetail});

  @override
  State<CommunityUpdateFormPage> createState() => _CommunityUpdateFormPageState();
}

class _CommunityUpdateFormPageState extends State<CommunityUpdateFormPage> {
  Timer? _debounce;
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  final CommonService _commonService = CommonService();
  final CommonWidget _commonWidget = CommonWidget();
  final CommonAlert _commonAlert = CommonAlert();

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];
  final firebase_storage.FirebaseStorage _storageRef = firebase_storage.FirebaseStorage.instance;
  List<String> _arrImageUrls = [];
  List<String> _arrFileNames = [];
  int uploadItem = 0;
  bool isUploading = false;
  List<String> existingImg = [];
  List<String> existingImgName = [];

  @override
  void initState() {
    super.initState();
    /// build 이후에 setController 를 하게 되면 텍스트를 수정 후에도 계속 이전 텍스트로 돌아가서 어쩔수없이 여기서 처음에만 set해줌
    Future.delayed(
      Duration.zero,
        () {
          final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
          communityViewModel.setTitleController = widget.postDetail.title;
          communityViewModel.setContentController = widget.postDetail.content;
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);

    Future.microtask(() => communityViewModel.callNotify());

    existingImg = [widget.postDetail.fileUrl1, widget.postDetail.fileUrl2, widget.postDetail.fileUrl3].where((element) => element != null).cast<String>().toList();
    existingImgName = [widget.postDetail.fileName1, widget.postDetail.fileName2, widget.postDetail.fileName3].where((element) => element != null).cast<String>().toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '수정하기',
          style: Theme.of(context).textTheme.headlineSmall
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _selectedFiles = [];
            _arrImageUrls = [];
            _arrFileNames = [];

            communityViewModel.setTitleController = '';
            communityViewModel.setContentController = '';
            communityViewModel.callNotify();

            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.007, 0, 0),
              child: Text(
                "수정",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              if (communityViewModel.getTitleController.text == widget.postDetail.title && communityViewModel.getContentController.text == widget.postDetail.content ) {
                return _commonAlert.duplicateAlert(context);
              }

              if (communityViewModel.getTitleController.text.isEmpty || communityViewModel.getTitleController.text == '') {
                return _commonAlert.spaceError(context, '제목');
              } else if (communityViewModel.getContentController.text.isEmpty || communityViewModel.getContentController.text == '') {
                return _commonAlert.spaceError(context, '내용');
              } else {
                SharedPreferences pref = await SharedPreferences.getInstance();
                int? memberSeq = memberViewModel.getMemberSeq ?? pref.getInt(Glob.memberSeq);
                String nickname = memberViewModel.getNickName.toString();

                try {
                  if (_selectedFiles.isEmpty) {
                    // 선택된 사진이 없는 경우, 딱히 할 일 없을듯

                  } else {
                    for (int i = 0; i < _selectedFiles.length; i++) {
                      _arrFileNames.add(_selectedFiles[i].name);
                    }

                    if (mounted) {
                      await uploadFunction(_selectedFiles, context);
                    }
                  }

                  bool result = await _communityRepository.updateCommunity(widget.postDetail.boardSeq, memberSeq!, nickname, communityViewModel.getTitleController.text, communityViewModel.getContentController.text, _arrFileNames);
                  if (result && mounted) {
                    // 성공

                    /// 기존 파일을 지우기 전, 현재 담긴 파일과 같은 파일이 있다면 제외
                    existingImgName.removeWhere((element) => _arrFileNames.contains(element));

                    /// 기존 파일 지우기, 만약 실패한다해도 이미 저장에 성공했기 때문에 그냥 두고 대신 로그를 남기기
                    /// 이거는 좀 더 고려후에 추후 배포하는걸로
                    /// 유저가 한개의 사진을 여러 게시글에 썼으면 해당 게시글에 영향이 있을 수 있으므로 더 생각 해봐야함
                    // bool deleteResult = await storage.deleteFile(existingImgName, 'community');

                    // 업로드, 저장 모두 성공
                    _selectedFiles = [];
                    _arrImageUrls = [];
                    _arrFileNames = [];

                    communityViewModel.setTitleController = '';
                    communityViewModel.setContentController = '';
                    communityViewModel.callNotify();

                    _commonWidget.updateSuccessAlert(context);
                  } else {
                    // 업로드 성공, 저장 실패
                  }
                } catch(e) {
                  if (mounted) {
                    return _commonAlert.errorAlert(context);
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
                Consumer<CommunityViewModel>(
                  builder: (context, viewModel, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: TextField(
                        controller: viewModel.getTitleController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          _commonService.debounce(() {
                            viewModel.setTitleController = value;
                            viewModel.callNotify();
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
                Consumer<CommunityViewModel>(
                  builder: (context, viewModel, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: TextField(
                        controller: viewModel.getContentController,
                        maxLines: 10,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)
                        ),
                        onChanged: (value) {
                          _commonService.debounce(() {
                            viewModel.setContentController = value;
                            viewModel.callNotify();
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
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "기존 이미지",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                itemCount: existingImg.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.network(
                                      existingImg[index],
                                      fit: BoxFit.fitWidth,
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        )
                      ),
                    ) :
                    Container(
                      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.05, 0, 0),
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: GridView.builder(
                        itemCount: _selectedFiles.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,),
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
      isUploading = true;
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

  Future<String> uploadFile(XFile image, BuildContext context) async {
    try {
      firebase_storage.Reference reference = _storageRef.ref().child('community').child(image.name);
      firebase_storage.UploadTask uploadTask = reference.putFile(File(image.path));
      await uploadTask.whenComplete(() {
        setState(() {
          uploadItem++;
          if (uploadItem == _selectedFiles.length) {
            isUploading = false;
            uploadItem = 0;
            _arrFileNames.add(image.name);
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
        _commonAlert.selectedImageError(context);
      } else if (imgs.isEmpty) {
        // print('empty');
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
    });
  }
}
