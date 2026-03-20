import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveFileImpl(String fileName, String content) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(content);

  // Use share_plus to allow the user to save or share the file
  await Share.shareXFiles([XFile(file.path)], text: 'Exported Data');
}

Future<void> saveFileBytesImpl(String fileName, Uint8List bytes) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes);

  // Use share_plus to allow the user to save or share the file
  await Share.shareXFiles([XFile(file.path)], text: 'Exported Data');
}

