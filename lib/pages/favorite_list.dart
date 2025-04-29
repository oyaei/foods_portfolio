import 'package:flutter/material.dart';
import 'package:foopo/functions/is_filtering_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data_provider.dart';
import 'add_data.dart';
import 'edit_data.dart';
import '../functions/generate_foods_list.dart';

class FavoriteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime _today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final _dataProvider = Provider.of<DataProvider>(context);

    // ＝＝＝＝表示するリストを生成＝＝＝＝
    var _filteredData = sortFoodsDataByExpiryDate(
                filterFoodsDataByFavorite(_dataProvider.data["foods"]) ?? [])
            ?.entries
            .toList() ??
        [];
    final List<Widget> _list =
        generateFoodsList(context, _dataProvider, _filteredData); // リスト

// ＝＝＝＝メイン＝＝＝＝
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          title: Text(
            "お気に入り",
            style: TextStyle(fontSize: 20),
          ),
          // actions: [
          //   IconButton(
          //     icon: Icon(
          //       _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
          //     ),
          //     tooltip: _favorite ? "お気に入りを解除" : "お気に入りに登録",
          //     onPressed: () {
          //       setState(() {
          //         _favorite = !_favorite;
          //       });
          //     },
          //   )
          // ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: (_list.length == 0)
                ? Center(
                    child: const Text("お気に入りに食料品を登録しましょう！"),
                  )
                : Column(
                    children: [
                      ..._list,
                      const SizedBox(height: 64),
                    ],
                  ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   shape: const CircleBorder(),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => AddData()),
        //     );
        //   },
        //   tooltip: "食材・料理を追加",
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }
}
