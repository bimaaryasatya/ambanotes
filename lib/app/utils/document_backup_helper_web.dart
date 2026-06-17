// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<String> saveDocumentToLocalImpl(List<int> bytes, String filename) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return 'Unduhan dimulai untuk $filename';
}

Future<bool> deleteDocumentBackupFileImpl(String path) async {
  return false;
}

bool canDeleteDocumentBackupFileImpl(String path) {
  return false;
}
