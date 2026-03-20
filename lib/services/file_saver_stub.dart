import 'dart:typed_data';

Future<void> saveFileImpl(String fileName, String content) async {
  throw UnsupportedError('Cannot save file without web or io libraries');
}

Future<void> saveFileBytesImpl(String fileName, Uint8List bytes) async {
  throw UnsupportedError('Cannot save file without web or io libraries');
}
