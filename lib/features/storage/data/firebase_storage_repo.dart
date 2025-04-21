import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photographers/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  /*
  PROFILE IMAGE UPLOAD
  */

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'profile_image');
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List filebytes, String fileName) {
    return _uploadFileBytes(filebytes, fileName, 'profile_image');
  }

  /*

  POST file Upload
  */
  @override
  Future<String?> uploadPostImageWeb(Uint8List filebytes, String fileName) {
    return _uploadFileBytes(filebytes, fileName, 'Post_image');
  }

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'Post_image');
  }

  /*
    Helper Method to used to upload files to storage

    */

  //mobile  platform (files)

  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      //get file
      final file = File(path);

      //find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      //upload
      final uploadTask = await storageRef.putFile(file);

      //get image download
      final downloadurl = await uploadTask.ref.getDownloadURL();
      return downloadurl;
    } catch (e) {
      return null;
    }
  }

  //web platform
  Future<String?> _uploadFileBytes(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      //find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      //upload
      final uploadTask = await storageRef.putData(fileBytes);

      //get image download url
      final downloadurl = await uploadTask.ref.getDownloadURL();
      return downloadurl;
    } catch (e) {
      return null;
    }
  }
}
