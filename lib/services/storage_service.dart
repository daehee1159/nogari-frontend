import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  Future<bool> uploadFile(String filePath, String fileName, String uploadPath) async {
    try {
      firebase_storage.Reference reference = storage.ref().child(uploadPath).child(fileName);
      firebase_storage.UploadTask uploadTask = reference.putFile(File(filePath));
      await uploadTask.whenComplete(() async {
        String filePath = await reference.getDownloadURL();
      });
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<firebase_storage.ListResult> listFiles(String uploadPath) async {
    firebase_storage.ListResult results = await storage.ref(uploadPath).listAll();

    // results.items.forEach((firebase_storage.Reference ref) {
    //   print('Found file: $ref');
    // });

    return results;
  }

  Future<String> downloadURL(String imageName, String uploadPath) async {
    try {
      if (imageName == "" || imageName == "null") {
        String downloadURL = "null";
        return downloadURL;
      } else {
        String downloadURL = await storage.ref('$uploadPath/$imageName').getDownloadURL();
        return downloadURL;
      }
    } catch(e) {
      return "null";
    }

  }

  Future<bool> deleteFile(List<String> imageList, String uploadPath) async {
    try {
      for (int i = 0; i < imageList.length; i++) {
        firebase_storage.Reference reference = storage.ref().child(uploadPath).child(imageList[i]);
        await reference.delete();
      }
      return true;
    } catch(e) {
      return false;
    }
  }
}
