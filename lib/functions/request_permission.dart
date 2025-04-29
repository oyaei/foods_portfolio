import 'package:permission_handler/permission_handler.dart';

Future<bool> RequestStoragePermission() async {
  final status = await Permission.manageExternalStorage.request();
  return status.isGranted;
}
