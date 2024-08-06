import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ImageFirebaseData {

  Future<String> uploadImage(File imageFile) async{
    try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('meals/${DateTime.now().toIso8601String()}');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print('Error uploading image: $e');
        return '';
      }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
      print('Image deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }


}