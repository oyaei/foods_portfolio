import 'package:flutter/material.dart';
import 'package:foopo/pages/places.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'pages/expiry_date.dart';
import 'pages/places.dart';
import 'functions/export_data.dart';
import 'pages/favorite_list.dart';
import 'pages/search.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// class Data {
//   int _data1;
//   String _data2;
//   Data(this._data1, this._data2) : super();

//   @override
//   String toString(){
//     return
//   }
// }

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // タブのラベル一覧
  static const List<Tab> tabs = <Tab>[
    Tab(text: "消費期限"),
    Tab(text: "保管場所"),
    Tab(text: "買い物リスト"),
  ];
// タブコントローラ
  late TabController _tabController;
// データファイルのパス
  final _filePath = "portfolio_data.json";

  @override

  // タブコントローラの初期化
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  Widget build(BuildContext context) {
    final _dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            children: [
              ListTile(
                leading: Icon(Icons.download_rounded),
                title: const Text("インポート"),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.upload_file_rounded),
                title: const Text("エクスポート"),
                onTap: () async => ExportData(_dataProvider.data),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          title: Center(
            child: Text(
              "FooPO",
              style: TextStyle(fontSize: 20),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.star_rounded),
              tooltip: "お気に入り",
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FavoriteList()));
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "検索",
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchFoodData()));
              },
            ),
          ],
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Container(
                // color: Theme.of(context).colorScheme.primary,
                child: TabBar(
                  // ＝＝色の設定＝＝
                  dividerColor:
                      Theme.of(context).colorScheme.surface, // タブとビューの境界線
                  // dividerColor:
                  //     Theme.of(context).colorScheme.primary, // タブとビューの境界線
                  // indicatorColor:
                  //     Theme.of(context).colorScheme.onPrimary, // 選択中のタブのインジケータ
                  // labelColor:
                  //     Theme.of(context).colorScheme.onPrimary, // 選択タブのラベル
                  // unselectedLabelColor:
                  //     Theme.of(context).colorScheme.onSurface, // 未選択タブのラベル
                  // ＝＝その他デザイン＝＝
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ), // 選択タブのラベルのフォント
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ), // 未選択タブのラベルのフォント
                  indicatorWeight: 4.0, // インジケータの太さ
                  indicatorSize: TabBarIndicatorSize.tab, // インジケータの横幅
                  // ＝＝タブの根幹＝＝
                  controller: _tabController, // コントローラ
                  tabs: tabs, // タブの選択肢
                ),
              ))),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ＝＝「消費期限」のコンテンツ＝＝
          ExpiryDate(),
          // ＝＝「保管場所」のコンテンツ＝＝
          Places(),
          // ＝＝「買い物リスト」のコンテンツ＝＝
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text("買い物リストのコンテンツです"),
          ),
        ],
      ),
    );
  }
}
