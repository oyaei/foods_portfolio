import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import '../data_provider.dart';
import '../functions/is_filtering_data.dart';

class AddData extends StatefulWidget {
  @override
  State<AddData> createState() => _AddData();
}

class _AddData extends State<AddData> {
// ＝＝＝各入力フォームの値管理用変数を定義＝＝＝
  var _place = "***";
  final _nameController = TextEditingController(); // 食品名
  DateTime _addDate = DateTime.now(); // 追加日
  DateTime _expDate = DateTime.now().add(Duration(days: 10)); // 消費期限
  final _quantityController = TextEditingController(); // 数量
  var _unit = "個"; // 数量の単位
  var _customUnit = ""; // 数量のカスタム単位
  final _noteController = TextEditingController(); // メモ
  var _favorite = false;

// ＝＝＝入力の監視＝＝＝＝
  ValueNotifier<bool> _isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    // 保管場所の初期値を設定
    var _dataProvider = Provider.of<DataProvider>(context, listen: false);
    List<String> _placeKeysList = _dataProvider.data["places"].keys.toList();
    setState(() {
      _place = _placeKeysList.firstWhereOrNull(
              (key) => _dataProvider.data["places"][key]?["sort"] == 0) ??
          "***";
    });

    // 食品名の入力値が変わったらチェックするリスナーを追加
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // メモリリーク防止のためリスナーを削除
    _nameController.removeListener(_validateForm);
    _isFormValid.dispose();
    super.dispose();
  }

  // 入力チェック
  void _validateForm() {
    bool isValid = _nameController.text.isNotEmpty;
    _isFormValid.value = isValid; // 判定を変更
  }

// ＝＝＝メイン＝＝＝
  @override
  Widget build(BuildContext context) {
    final _dataProvider = Provider.of<DataProvider>(context);
    // ---表示するリスト---
    final List<DropdownMenuItem<String>> _placeList = [];
    sortPlacesData(_dataProvider.data["places"])?.forEach((key, v) =>
        _placeList.add(DropdownMenuItem(value: key, child: Text(v["name"]))));

    return PopScope(
      canPop: false, // 戻るキーで戻る動作を無効化
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // 既にポップされていたら何もしない

        final bool? shouldPop =
            await _showConfirmDialog(context); // ダイアログで戻るか確認
        if (shouldPop ?? false) {
          Navigator.pop(context); // 戻るを選択した場合のみpopを明示的に呼ぶ
        }
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            title: Text(
              "食材・料理を追加",
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                ),
                tooltip: _favorite ? "お気に入りを解除" : "お気に入りに登録",
                onPressed: () {
                  setState(() {
                    _favorite = !_favorite;
                  });
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //====フォームはじめ====

                  // ＝＝保管場所＝＝
                  const SizedBox(height: 0), // スペース
                  const Text("保管場所*"), // ラベル
                  DropdownButton(
                    value: _place,
                    items: _placeList,
                    onChanged: (value) {
                      setState(() {
                        _place = value ?? "not selected";
                      });
                    },
                  ),

                  // ＝＝食品名＝＝
                  const SizedBox(height: 24),
                  const Text("食品名*"),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "食品名を入力してください",
                    ),
                  ),

                  // ＝＝追加日（購入日・調理日）＝＝

                  const SizedBox(height: 24),
                  const Text("購入日／調理日*"),
                  TextField(
                    controller: TextEditingController(
                        text: DateFormat("yyyy/MM/dd")
                            .format(_addDate)), // カレンダーで選んだ日付を表示
                    decoration: const InputDecoration(
                      // カレンダーアイコンを右端に表示
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    inputFormatters: [
                      // 手打ちを禁止するために、手打ちされたら値を変更前のものに強制的に戻す
                      TextInputFormatter.withFunction(
                          (oldValue, newValue) => oldValue)
                    ],
                    // フィールドが押されたらカレンダーから日付を選択
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _addDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _addDate = picked;
                        });
                      }
                    },
                  ),

                  // ＝＝消費期限＝＝
                  const SizedBox(height: 24),
                  const Text("消費期限／賞味期限*"),
                  TextField(
                    controller: TextEditingController(
                        text: DateFormat("yyyy/MM/dd")
                            .format(_expDate)), // カレンダーで選んだ日付を表示
                    decoration: const InputDecoration(
                      // カレンダーアイコンを右端に表示
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    inputFormatters: [
                      // 手打ちを禁止するために、手打ちされたら値を変更前のものに強制的に戻す
                      TextInputFormatter.withFunction(
                          (oldValue, newValue) => oldValue)
                    ],
                    // フィールドが押されたらカレンダーから日付を選択
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _expDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(_expDate.year + 50),
                      );
                      if (picked != null) {
                        setState(() {
                          _expDate = picked;
                        });
                      }
                    },
                  ),

                  // ＝＝数量＝＝
                  const SizedBox(height: 24),
                  const Text("数量"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _quantityController,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            hintText: "数量を入力してください",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12), // スペース
                      Expanded(
                        flex: 1,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: _unit,
                            items: [
                              const DropdownMenuItem(
                                  value: "個", child: Text("個")),
                              const DropdownMenuItem(
                                  value: "パック", child: Text("パック")),
                              const DropdownMenuItem(
                                  value: "本", child: Text("本")),
                              const DropdownMenuItem(
                                  value: "食", child: Text("食")),
                              const DropdownMenuItem(
                                  value: "皿", child: Text("皿")),
                              const DropdownMenuItem(
                                  value: "杯", child: Text("杯")),
                              const DropdownMenuItem(
                                  value: "g", child: Text("g")),
                              const DropdownMenuItem(
                                  value: "ml", child: Text("ml")),
                              const DropdownMenuItem(
                                  value: "(単位なし)", child: Text("(単位なし)")),
                              DropdownMenuItem(
                                  value: "カスタム",
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.edit_rounded),
                                        Text(_customUnit.isNotEmpty
                                            ? _customUnit
                                            : "カスタム単位"),
                                      ])),
                            ],
                            onChanged: (value) {
                              if (value != "カスタム") {
                                // プリセットの単位が選択された場合
                                setState(() {
                                  _unit = value ?? "not selected";
                                });
                              } else {
                                // カスタム単位が選択された場合
                                var _customUnitController =
                                    TextEditingController(text: _customUnit);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: Text("カスタム単位"),
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _customUnitController,
                                          decoration: InputDecoration(
                                            hintText: "単位を入力してください",
                                          ),
                                          maxLength: 6,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text("キャンセル"),
                                        onPressed: () =>
                                            Navigator.pop(context, "cancel"),
                                      ),
                                      TextButton(
                                        child: Text("決定"),
                                        onPressed: () =>
                                            Navigator.pop(context, "submit"),
                                      ),
                                    ],
                                  ),
                                ).then((value) => {
                                      // ボタン操作後の処理
                                      if (value == "submit")
                                        {
                                          setState(() {
                                            _unit = "カスタム";
                                            _customUnit =
                                                _customUnitController.text;
                                          })
                                        }
                                    });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ＝＝メモ＝＝
                  const SizedBox(height: 48),
                  const Text("メモ"),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: "メモがあれば自由に書いてください",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: null,
                  ),

                  const SizedBox(height: 0),
                  //====フォーム終わり====
                ],
              ),
            ),
          ),

          // 画面下部の決定ボタン
          bottomNavigationBar: ValueListenableBuilder(
              valueListenable: _isFormValid,
              builder: (context, isValid, child) {
                return RawMaterialButton(
                  fillColor: isValid
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "追加",
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: isValid
                      ? () {
                          // ＝＝フォーム送信処理＝＝
                          // ユニークなキーを取得
                          final _uuid = Uuid().v4();
                          // foodsのデータ全体を取得
                          final newData = _dataProvider.data["foods"];
                          // _uuidをキーにしてfoodsに新しいデータを追加
                          newData[_uuid] = {
                            "place": _place,
                            "name": _nameController.text,
                            "addDate":
                                DateFormat("yyyy-MM-dd").format(_addDate),
                            "expDate":
                                DateFormat("yyyy-MM-dd").format(_expDate),
                            "quantity": _quantityController.text,
                            "unit": _unit != "カスタム" ? _unit : _customUnit,
                            "note": _noteController.text,
                            "favorite": _favorite
                          };
                          // Provider経由でupdateDataへアクセスし、データを更新および保存
                          context
                              .read<DataProvider>()
                              .updateData("foods", newData);
                          // 前の画面に戻る
                          Navigator.pop(context);
                        }
                      : null, // 無効時は押せないようにする,
                );
              }),
        ),
      ),
    );
  }

// 画面を戻る際の確認ダイアログ
  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("確認"),
            content: const Text("入力中のデータは保存されません。\n本当に戻りますか？"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("キャンセル"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("OK"),
              ),
            ],
          ),
        ) ??
        false; // ダイアログ外をタップした場合は false
  }
}
