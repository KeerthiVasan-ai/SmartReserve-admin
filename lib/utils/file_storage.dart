import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorage {
  /// Gets the public Downloads directory for saving files
  /// Uses proper scoped storage approach based on Android version
  static Future<String> getPublicDownloadsPath() async {
    if (Platform.isAndroid) {
      // For Android, use the standard Downloads path
      // Android 10+ (API 29+) allows writing to Downloads without special permissions
      // Android 9 and below need WRITE_EXTERNAL_STORAGE (handled in manifest with maxSdkVersion)
      
      // Check if we need storage permission (only for Android 9 and below)
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          // If permission denied, fall back to app documents directory
          final directory = await getApplicationDocumentsDirectory();
          return directory.path;
        }
      }
      
      // Use the standard Downloads path
      const downloadsPath = '/storage/emulated/0/Download';
      final directory = Directory(downloadsPath);
      
      // Check if directory exists and is accessible
      if (await directory.exists()) {
        print("Saved Path: $downloadsPath");
        return downloadsPath;
      } else {
        // Fallback to app documents if Downloads is not accessible
        final appDir = await getApplicationDocumentsDirectory();
        print("Fallback Path: ${appDir.path}");
        return appDir.path;
      }
    } else {
      // iOS - use app documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  static Future<String> get _localPath async {
    return await getPublicDownloadsPath();
  }

  /// Writes bytes to a file in the Downloads folder and returns the File
  static Future<File> writeCounter(Uint8List bytes, String name) async {
    final path = await _localPath;
    File file = File('$path/$name');
    print("Save file: ${file.path}");
    return await file.writeAsBytes(bytes);
  }

  /// Shares a file using the system share sheet
  static Future<void> shareFile(File file, {String? subject}) async {
    final xFile = XFile(file.path);
    await Share.shareXFiles(
      [xFile],
      subject: subject,
    );
  }

  /// Opens a file by sharing it - allows user to choose which app to use
  static Future<void> openFile(File file) async {
    await shareFile(file);
  }
}
