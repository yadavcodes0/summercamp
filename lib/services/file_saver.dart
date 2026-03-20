import 'dart:typed_data';

import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

abstract class FileSaver {
  static Future<void> saveFile(String fileName, String content) {
    return saveFileImpl(fileName, content);
  }

  static Future<void> saveFileBytes(String fileName, Uint8List bytes) {
    return saveFileBytesImpl(fileName, bytes);
  }
}
