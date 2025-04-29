// ChatGPTで生成したソースコードを一部改変
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static const String _fileName = "portfolio_data.json";

  /// **📌 JSON ファイルのパスを取得**
  static Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$_fileName";
  }

  /// **📌 JSON を読み込む（なければデフォルトデータを返す）**
  static Future<Map<String, dynamic>> readJson() async {
    try {
      final path = await getFilePath();
      final file = File(path);

      if (await file.exists()) {
        String jsonString = await file.readAsString();
        return json.decode(jsonString);
      } else {
        return _defaultData(); // デフォルトデータを返す
      }
    } catch (e) {
      print("読み込みエラー: $e");
      return _defaultData();
    }
  }

  /// **📌 JSON を書き込む**
  static Future<void> writeJson(Map<String, dynamic> data) async {
    try {
      final path = await getFilePath();
      final file = File(path);
      await file.writeAsString(json.encode(data), mode: FileMode.write);
    } catch (e) {
      print("書き込みエラー: $e");
    }
  }

  /// **📌 デフォルトデータ**
  static Map<String, dynamic> _defaultData() {
    return {
      "foods": {},
      "places": {
        "***": {
          "name": "未分類", // 名前
          "sort": 1, // ソート用のキー（数が小さいほうが上位となる）
          "edit": false, // ユーザによる編集権限なし
        },
        "0": {
          "name": "冷蔵庫",
          "sort": 0,
        },
      }
    };
  }
}
