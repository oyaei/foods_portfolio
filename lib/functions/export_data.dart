import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'request_permission.dart';

Future<void> ExportData(Map<String, dynamic> data) async {
  final granted = await RequestStoragePermission();
  if (!granted) {
    print("Permission denied");
    return;
  }

  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    print('フォルダ選択がキャンセルされました');
    return;
  }

  // 2. ファイル名と保存先のパスを作成
  final fileName = 'FooPO_mydata.json';
  final filePath = '$selectedDirectory/$fileName';

  // 3. JSONを書き込み
  final file = File(filePath);
  await file.writeAsString(jsonEncode(data));

  print('データを保存しました: $filePath');
}
