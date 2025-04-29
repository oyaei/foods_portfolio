import 'package:flutter/material.dart';
import 'my_home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 非同期処理を正しく実行するために必要
  final _dataProvider = DataProvider();
  await _dataProvider.loadData(); // 初期データを読み込む

  runApp(
    ChangeNotifierProvider(
      create: (context) => _dataProvider,
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "foopo",
      home: MyHomePage(),
      // ==テーマを設定==
      theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFFF19C1F),
            onPrimary: Color(0xFFfcfcfc),
            primaryContainer: Color(0xFFf19c1f),
            onPrimaryContainer: Color(0xFFfcfcfc),
            secondary: Color(0xFF00a1e9),
            onSecondary: Color(0xFFfcfcfc),
            error: Color(0xFFf66a7a),
            onError: Color(0xFFfcfcfc),
            surface: Color(0xFFfcfcfc),
            onSurface: Color(0xFF666666),
          ),
          dividerColor: Colors.transparent
          // primarySwatch: Colors.amber,
          // primaryColor: Colors.amber,
          // canvasColor: const Color(0xFFfcfcfc),
          ),
      // ==言語設定==
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en"),
        const Locale("ja"),
      ],
      locale: Locale('ja', 'JP'),
// ＝＝デバッグモードのバナーを削除＝＝
      debugShowCheckedModeBanner: false,
    );
  }
}
