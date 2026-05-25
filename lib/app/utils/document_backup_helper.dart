import 'document_backup_helper_stub.dart'
    if (dart.library.html) 'document_backup_helper_web.dart'
    if (dart.library.io) 'document_backup_helper_io.dart';

Future<String> saveDocumentToLocal(List<int> bytes, String filename) {
  return saveDocumentToLocalImpl(bytes, filename);
}

Future<bool> deleteDocumentBackupFile(String path) {
  return deleteDocumentBackupFileImpl(path);
}

bool canDeleteDocumentBackupFile(String path) {
  return canDeleteDocumentBackupFileImpl(path);
}
