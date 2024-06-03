import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Logger {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/app_logs.txt');
  }

  static Future<void> log(String message) async {
    final file = await _localFile;
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final logMessage = '$timestamp: $message\n';
    await file.writeAsString(logMessage, mode: FileMode.append);
  }
}
