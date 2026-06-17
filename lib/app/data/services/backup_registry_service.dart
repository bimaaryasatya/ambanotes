import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BackupRegistryService extends GetxService {
  static const _storageKey = 'document_backup_paths';

  final GetStorage _storage = GetStorage();

  Map<String, dynamic> _readRaw() {
    return Map<String, dynamic>.from(_storage.read(_storageKey) ?? {});
  }

  List<String> getBackupPaths(String docId) {
    final raw = _readRaw();
    final value = raw[docId];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return [];
  }

  Future<void> registerBackupPath(String docId, String path) async {
    if (docId.isEmpty || path.trim().isEmpty) return;

    final raw = _readRaw();
    final paths = getBackupPaths(docId).toSet()..add(path);
    raw[docId] = paths.toList();
    await _storage.write(_storageKey, raw);
  }

  Future<void> removeBackupPath(String docId, String path) async {
    final raw = _readRaw();
    final paths = getBackupPaths(docId)..remove(path);

    if (paths.isEmpty) {
      raw.remove(docId);
    } else {
      raw[docId] = paths;
    }

    await _storage.write(_storageKey, raw);
  }

  Future<void> clearBackupPaths(String docId) async {
    final raw = _readRaw()..remove(docId);
    await _storage.write(_storageKey, raw);
  }
}
