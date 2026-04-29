import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      if (!file.existsSync()) throw 'File does not exist: ${file.path}';
      final ref = _storage.ref().child(path);
      // Wait for the task to fully complete before requesting the URL
      final TaskSnapshot snapshot = await ref.putFile(file);
      
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw 'Upload failed with state: ${snapshot.state}';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<FilePickerResult?> pickFile() async {
    return await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
  }
}
