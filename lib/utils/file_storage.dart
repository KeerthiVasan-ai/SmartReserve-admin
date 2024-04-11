import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory directory = Directory("");
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Download");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final exPath = directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> writeCounter(Uint8List bytes,String name) async {
    final path = await _localPath;
    File file= File('$path/$name');
    print("Save file");

    return await file.writeAsBytes(bytes);
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
