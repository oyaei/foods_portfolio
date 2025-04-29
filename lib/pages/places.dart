import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data_provider.dart';
import '../functions/is_filtering_data.dart';
import 'places_reorderable_list.dart';

class Places extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: (_dataProvider.data["places"].length == 0)
            ? SingleChildScrollView(
                child: Center(
                  child: Text("保管場所がありません"),
                ),
              )
            : PlacesReorderableList(),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        tooltip: "保管場所を作成",
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.add_business_rounded),
        onPressed: () => _showNewPlaceDialog(context, _dataProvider),
      ),
    );
  }

  void _showNewPlaceDialog(BuildContext context, _dataProvider) async {
    final _placeController = TextEditingController();

    return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("新しい保管場所を追加"),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: "保管場所の名前を入力してください",
              ),
              maxLength: 16,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("キャンセル"),
            onPressed: () => Navigator.pop(context, "cancel"),
          ),
          TextButton(
            child: Text("追加"),
            onPressed: () {
              if (_placeController.text.isNotEmpty) {
                // ＝＝フォーム送信処理＝＝
                // ユニークなキーを取得
                final _uuid = Uuid().v4();
                // placesのデータ全体を取得
                final newData = _dataProvider.data["places"];
                // 既存のソートの値をすべて１増やす
                newData?.forEach((key, v) {
                  newData[key]["sort"]++;
                });
                // 新しい保管場所を追加
                newData[_uuid] = {"name": _placeController.text, "sort": 0};
                // Provider経由でupdateDataへアクセスし、データを更新および保存
                context.read<DataProvider>().updateData("places", newData);

                Navigator.pop(context, "submit");
              }
            },
          ),
        ],
      ),
    );
  }
}
