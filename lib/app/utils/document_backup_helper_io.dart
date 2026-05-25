import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveDocumentToLocalImpl(List<int> bytes, String filename) async {
  Directory? targetDir;

  if (Platform.isAndroid) {
    targetDir = Directory('/storage/emulated/0/Download');
    if (!await targetDir.exists()) {
      targetDir = await getExternalStorageDirectory();
    }
  } else {
    targetDir = await getApplicationDocumentsDirectory();
  }

  if (targetDir == null) {
    throw const FileSystemException('Folder penyimpanan tidak ditemukan.');
  }

  final safeName = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final file = File('${targetDir.path}/$safeName');
  await file.writeAsBytes(bytes);
  return file.path;
}

Future<bool> deleteDocumentBackupFileImpl(String path) async {
  final file = File(path);

  if (!await file.exists()) {
    return false;
  }

  await file.delete();
  return true;
}

bool canDeleteDocumentBackupFileImpl(String path) {
  return path.trim().isNotEmpty;
}
