// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';

Future<void> saveFileImpl(String fileName, String content) async {
  final bytes = utf8.encode(content);
  await saveFileBytesImpl(fileName, Uint8List.fromList(bytes));
}

Future<void> saveFileBytesImpl(String fileName, Uint8List bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

