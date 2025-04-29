import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/edit_data.dart';

List<Widget> generateFoodsList(context, _dataProvider, data) {
  DateTime _today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final List<Widget> _list = []; // リスト
  // リストにウィジェットを追加
  if (data.length > 0) {
    String _lastDate = "";
    for (final v in data) {
      DateTime _day = DateTime.parse(v.value["expDate"]); // 消費期限をDateTime型に変換
      int _difference = _day.difference(_today).inDays; // 今日と消費期限の差分を取得
      // 消費期限が直前のデータと異なる場合は、日付をリストに追加
      if (_lastDate != v.value["expDate"]) {
        _lastDate = v.value["expDate"];
        // 日付をリストに追加
        _list.add(Padding(
          padding: EdgeInsets.only(top: 16, bottom: 4, left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (_difference < 0) // 消費期限が過ぎている場合
                Text(
                  "${-_difference}日超過",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
              else if (_difference == 0) // 消費期限が今日の場合
                Text(
                  "今日",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              else // 消費期限はまだの場合
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "残り",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _difference <= 7
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    Text(
                      "${_difference}日",
                      style: TextStyle(
                        fontSize: _difference <= 30 ? 24 : 16,
                        fontWeight: FontWeight.bold,
                        color: _difference <= 7
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              Text(
                "（${DateFormat("yyyy/MM/dd").format(_day)})",
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _difference < 0
                      ? Colors.red
                      : (_difference <= 7
                          ? Theme.of(context).colorScheme.primary
                          : null),
                ),
              )
            ],
          ),
        ));
      }
      // 食料品データをリストに追加
      _list.add(Card(
        color: _difference < 0
            ? Colors.red[50]
            : (_difference <= 7 ? Colors.yellow[50] : null),
        child: ListTile(
          title: Text(v.value["name"]),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${v.value["quantity"]}${v.value["unit"]}"),
              Text(_dataProvider.data["places"][v.value["place"]]?["name"] ??
                  "未分類"),
            ],
          ),
          // trailing: IconButton(icon:Icon(Icons.star_rounded),onPressed: ()=>{},),

          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditData(data: v)));
          },
        ),
      ));
    }
  }

  return _list;
}
