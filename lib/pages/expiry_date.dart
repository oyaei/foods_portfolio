import 'package:flutter/material.dart';
import 'package:foopo/functions/is_filtering_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data_provider.dart';
import 'add_data.dart';
import 'edit_data.dart';
import '../functions/generate_foods_list.dart';

class ExpiryDate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime _today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final _dataProvider = Provider.of<DataProvider>(context);

    // ＝＝＝＝表示するリストを生成＝＝＝＝
    // var _convertedData =
    //     _dataProvider.data["foods"]?.entries.toList(); // リスト化した食料品データ
    // var _sortedData = _convertedData
    //   ?..sort((a, b) => (a.value["expDate"] as String)
    //       .compareTo(b.value["expDate"] as String)); // 消費期限の日付順にソート
    var _sortedData = sortFoodsDataByExpiryDate(_dataProvider.data["foods"])
            ?.entries
            .toList() ??
        [];

    final List<Widget> _list =
        generateFoodsList(context, _dataProvider, _sortedData); // リスト

// ＝＝＝＝メイン＝＝＝＝
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: (_dataProvider.data["foods"].length == 0)
              ? Center(
                  child: const Text("食料品がありません"),
                )
              : Column(
                  children: [
                    ..._list,
                    const SizedBox(height: 64),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddData()),
          );
        },
        tooltip: "食材・料理を追加",
        child: const Icon(Icons.add),
      ),
    );
  }
}
