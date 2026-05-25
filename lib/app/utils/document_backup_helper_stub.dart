Future<String> saveDocumentToLocalImpl(List<int> bytes, String filename) async {
  throw UnsupportedError('Backup lokal tidak didukung pada platform ini.');
}

Future<bool> deleteDocumentBackupFileImpl(String path) async {
  return false;
}

bool canDeleteDocumentBackupFileImpl(String path) {
  return false;
}
