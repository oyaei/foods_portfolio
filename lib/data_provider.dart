// ChatGPTで生成したソースコードを一部改変
import 'package:flutter/material.dart';
import 'file_helper.dart';

class DataProvider extends ChangeNotifier {
  Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;

  /// **📌 JSON からデータを読み込む**
  Future<void> loadData() async {
    _data = await FileHelper.readJson();
    notifyListeners();
  }

  /// **📌 既存のデータを更新**
  Future<void> updateData(String key, dynamic value) async {
    _data[key] = value;
    await FileHelper.writeJson(_data);
    notifyListeners();
  }

  /// **📌 新しいキーと値を追加**
  Future<void> addData(String key, dynamic value) async {
    if (!_data.containsKey(key)) {
      _data[key] = value;
      await FileHelper.writeJson(_data);
      notifyListeners();
    }
  }

  /// **📌 キーごと削除**
  Future<void> removeData(String key) async {
    if (_data.containsKey(key)) {
      _data.remove(key);
      await FileHelper.writeJson(_data);
      notifyListeners();
    }
  }
}
