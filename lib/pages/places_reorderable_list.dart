import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data_provider.dart';
import '../functions/is_filtering_data.dart';

class PlacesReorderableList extends StatefulWidget {
  const PlacesReorderableList({super.key});

  @override
  State<PlacesReorderableList> createState() => _PlacesReorderableList();
}

class _PlacesReorderableList extends State<PlacesReorderableList> {
  late List<int> _items;

  @override
  void initState() {
    super.initState();

    final _dataProvider = Provider.of<DataProvider>(context, listen: false);

    setState(() {
      _items = List<int>.generate(
          _dataProvider.data["places"].length, (int index) => index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _dataProvider = Provider.of<DataProvider>(context);
    // 表示するリスト;
    final List<Card> _list = [];
    sortPlacesData(_dataProvider.data["places"])
        ?.entries
        .toList()
        .asMap()
        .entries
        .forEach((entry) => _list.add(Card(
              key: Key("${entry.key}"),
              child: ListTile(
                title: Text(entry.value.value["name"]),
                trailing: Wrap(children: [
                  if (entry.value.value["edit"] ?? true)
                    IconButton(
                      icon: Icon(Icons.edit_rounded),
                      onPressed: () => _showEditPlaceDialog(
                          context, _dataProvider, entry.value.key),
                    ),
                  // SizedBox(
                  //   width: 12,
                  // ),
                  ReorderableDragStartListener(
                    index: entry.key,
                    child: IconButton(
                      icon: Icon(Icons.drag_handle_rounded),
                      onPressed: null,
                    ),
                  )
                ]),
                onTap: () {},
              ),
            )));

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(1, 6, animValue)!;
          final double scale = lerpDouble(1, 1.02, animValue)!;
          return Transform.scale(
            scale: scale,
            // Create a Card based on the color and the content of the dragged one
            // and set its elevation to the animated value.
            child: Card(
                elevation: elevation,
                color: _list[index].color,
                child: _list[index].child),
          );
        },
        child: child,
      );
    }

    return ReorderableListView(
        children: _list,
        buildDefaultDragHandles: false,
        proxyDecorator: proxyDecorator,
        onReorder: (int oldIndex, int newIndex) {
          print(oldIndex.toString() + " → " + newIndex.toString());
          // placesのデータ全体を取得
          final newData = _dataProvider.data["places"];
          //  下位に移動した場合
          if (oldIndex < newIndex) {
            newData?.forEach((key, v) {
              if (oldIndex < v["sort"] && v["sort"] <= newIndex - 1) {
                newData[key]["sort"]--;
              } else if (v["sort"] == oldIndex) {
                newData[key]["sort"] = newIndex - 1;
              }
            });
          } else //  上位に移動した場合
          if (oldIndex > newIndex) {
            newData?.forEach((key, v) {
              if (newIndex <= newData[key]["sort"] &&
                  newData[key]["sort"] < oldIndex) {
                newData[key]["sort"]++;
              } else if (newData[key]["sort"] == oldIndex) {
                newData[key]["sort"] = newIndex;
              }
            });
          }

          // Provider経由でupdateDataへアクセスし、データを更新および保存
          // context.read<DataProvider>().updateData("places", newData);

          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final int item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        });
  }

// 編集ダイアログ
  void _showEditPlaceDialog(BuildContext context, _dataProvider, key) async {
    final _placeController =
        TextEditingController(text: _dataProvider.data["places"][key]["name"]);

    return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("保管場所を編集"),
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
            child: Text("削除"),
            onPressed: () async {
              // 確認ダイアログを表示
              final bool? shouldDelete =
                  await _showConfirmDeleteDialog(context);
              // 削除が押されたら削除処理を実行
              if (shouldDelete ?? false) {
                // ＝＝フォーム送信処理＝＝
                // foodsのデータ全体を取得
                final newData = _dataProvider.data["places"];
                newData.remove(key);
                // Provider経由でupdateDataへアクセスし、データを更新および保存
                context.read<DataProvider>().updateData("places", newData);

                // 前の画面に戻る
                Navigator.pop(context, "cancel");
              }
            },
          ),
          TextButton(
            child: Text("更新"),
            onPressed: () {
              if (_placeController.text.isNotEmpty) {
                // 表示しているリストのためのインデックスを更新

                // placesのデータ全体を取得
                final newData = _dataProvider.data["places"];
                // 新しい保管場所を追加
                newData[key] = {"name": _placeController.text, "sort": 0};
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

  // 削除の確認ダイアログ
  Future<bool> _showConfirmDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                ),
                Text("確認")
              ],
            ),
            content: Text("一度削除すると元に戻せません。\n本当に削除しますか？"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("キャンセル"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("削除"),
              ),
            ],
          ),
        ) ??
        false; // ダイアログ外をタップした場合は false
  }
}
