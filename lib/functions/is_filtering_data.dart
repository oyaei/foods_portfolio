import 'dart:ffi';

/// 保管場所データを昇順ソートして出力。
///
/// ★引数
/// 　places：Providerで取得したdataProvider.data["places"]を入力
///
/// ★戻り値
/// 　昇順ソート済みのデータ（Map<String, Map<String, dynamic>>）
Map<String, Map<String, dynamic>> sortPlacesData(places) {
  var _sortedList = places.entries.toList();
  _sortedList
    ?..sort(
        (a, b) => (a.value["sort"] as int).compareTo(b.value["sort"] as int));
  return {for (var entry in _sortedList) entry.key: entry.value};
}

/// 食料データを消費期限順（降順）にソートして出力
///
/// ★引数
/// 　foods：Providerで取得したdataProvider.data["foods"]を入力
///
/// ★戻り値
/// 　消費期限をキーに降順ソート済みのデータ（Map<String, Map<String, dynamic>>）
Map<String, Map<String, dynamic>> sortFoodsDataByExpiryDate(foods) {
  var _sortedList = foods.entries.toList();
  _sortedList
    ?..sort((a, b) =>
        (a.value["expDate"] as String).compareTo(b.value["expDate"] as String));
  return {for (var entry in _sortedList) entry.key: entry.value};
}

/// お気に入りに登録された食料データのみ抽出して出力
///
/// ★引数
/// 　foods：Providerで取得したdataProvider.data["foods"]を入力
///
/// ★戻り値
/// 　抽出済みのデータ（Map<String, Map<String, dynamic>>）
Map<String, Map<String, dynamic>> filterFoodsDataByFavorite(foods) {
  var _entries = foods.entries.toList();
  var _filteredList = _entries?.where(
    (entry) => (entry.value.containsKey("favorite") &&
        entry.value["favorite"] as bool == true),
  );
  return {for (var entry in _filteredList) entry.key: entry.value};
}

/// 特定の文字列を検索し、一致するデータのみ抽出して出力
///
/// ★引数
/// 　foods：Providerで取得したdataProvider.data["foods"]を入力
///   q：検索ワード
///   keys：検索対象のkeyをリストにして入力
///
/// ★戻り値
/// 　抽出済みのデータ（Map<String, Map<String, dynamic>>）
Map<String, Map<String, dynamic>> filterFoodsDataByText(
    foods, String q, List<String> keys) {
  var _entries = foods.entries.toList();
  var _filteredList = _entries?.where(
    (entry) => (keys.indexWhere((key) => (entry.value.containsKey(key) &&
            (entry.value[key] as String).contains(q))) !=
        -1),
  );
  return {for (var entry in _filteredList) entry.key: entry.value};
}

/// 特定の文字列を正規表現で検索し、一致するデータのみ抽出して出力
///
/// ★引数
/// 　foods：Providerで取得したdataProvider.data["foods"]を入力
///   q：検索ワード
///   keys：検索対象のkeyをリストにして入力
///
/// ★戻り値
/// 　抽出済みのデータ（Map<String, Map<String, dynamic>>）
Map<String, Map<String, dynamic>> filterFoodsDataByTextREX(
    foods, String q, List<String> keys) {
  var _entries = foods.entries.toList();
  var _filteredList = _entries?.where(
    (entry) => (keys.indexWhere((key) => (entry.value.containsKey(key) &&
            RegExp('\\$q').hasMatch(entry.value[key] as String))) !=
        -1),
  );
  return {for (var entry in _filteredList) entry.key: entry.value};
}
