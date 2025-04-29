import 'package:flutter/material.dart';
import 'package:foopo/functions/is_filtering_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data_provider.dart';
import 'add_data.dart';
import 'edit_data.dart';
import '../functions/generate_foods_list.dart';

class SearchFoodData extends StatefulWidget {
  final MapEntry<String, dynamic>? data; // 前の画面から受け取る値
  SearchFoodData({this.data});

  @override
  State<SearchFoodData> createState() => _SearchFoodData();
}

class _SearchFoodData extends State<SearchFoodData> {
  // ＝＝＝＝表示するリストを生成＝＝＝＝
  List<Widget> _list = []; // リスト

  // 検索窓のフォーム
  final _wordController = TextEditingController(text: "");

// 検索範囲「食品名」のチェックボックス
  bool _isChecked_name = true;

// 検索範囲「メモ」のチェックボックス
  bool _isChecked_note = false;

  // 正規表現検索のスイッチボタン
  bool _isSwitched_rex = false;

  @override
  Widget build(BuildContext context) {
    DateTime _today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final _dataProvider = Provider.of<DataProvider>(context);

// 検索窓のフォーカス状態の管理
    var _focus = FocusNode();

// 検索ワードが確定した際の処理
    void submitSearchWord(text) {
      var _filteredData = [];

      // 検索ワードが空白でない場合のみ検索を実施
      if (text != "") {
        if (!_isSwitched_rex) {
          _filteredData = sortFoodsDataByExpiryDate(filterFoodsDataByText(
                          _dataProvider.data["foods"], text, [
                        _isChecked_name ? "name" : "",
                        _isChecked_note ? "note" : ""
                      ]) ??
                      [])
                  ?.entries
                  .toList() ??
              [];
        } else {
          _filteredData = sortFoodsDataByExpiryDate(filterFoodsDataByTextREX(
                          _dataProvider.data["foods"], text, [
                        _isChecked_name ? "name" : "",
                        _isChecked_note ? "note" : ""
                      ]) ??
                      [])
                  ?.entries
                  .toList() ??
              [];
        }
      }

      setState(() {
        _list = generateFoodsList(context, _dataProvider, _filteredData); // リスト
      });
    }

// ＝＝＝＝メイン＝＝＝＝
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          title: TextField(
            controller: _wordController,
            autofocus: true,
            focusNode: _focus,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: "検索ワードを入力",
            ),
            onTapOutside: (event) {
              _focus.unfocus();
            },
            onSubmitted: (text) => submitSearchWord(text),
          ),
          actions: [
            TextButton(
              child: Text("検索"),
              onPressed: () => submitSearchWord(_wordController.text),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ExpansionTile(
                  title: const Text('高度な検索'),
                  onExpansionChanged: (bool changed) {},
                  backgroundColor: Color(0xfff0f0f0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("検索対象"),
                            Row(
                              children: [
                                const SizedBox(width: 20),
                                const Text("食品名"),
                                Checkbox(
                                  value: _isChecked_name,
                                  onChanged: (value) {
                                    setState(() {
                                      _isChecked_name = value!;
                                    });
                                  },
                                ),
                                // SizedBox(width: 0),
                                const Text("メモ"),
                                Checkbox(
                                  value: _isChecked_note,
                                  onChanged: (value) {
                                    setState(() {
                                      _isChecked_note = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("正規表現で検索"),
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.75,
                                  child: Switch(
                                    value: _isSwitched_rex,
                                    onChanged: (value) {
                                      setState(() {
                                        _isSwitched_rex = value!;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // const Divider(),
                const SizedBox(height: 20),
                const Text(
                  "検索結果",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    // color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                (_list.length == 0)
                    ? Center(
                        child: const Text("該当の食料品は見つかりませんでした"),
                      )
                    : Column(
                        children: [
                          ..._list,
                          const SizedBox(height: 64),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
