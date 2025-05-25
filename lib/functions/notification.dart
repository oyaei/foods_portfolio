import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'request_permission.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleDailyNotification(int hour, int minute) async {
  final granted = await RequestNotificationPermission();
  if (!granted) {
    print("Permission denied");
    return;
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    hour * 100 + minute, // IDは重複しないように
    'お知らせ',
    'これは毎日送られる通知です',
    _nextInstanceOfTime(hour, minute),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_notif_channel_id',
        '毎日の通知',
        channelDescription: '毎日決まった時間に通知を送ります',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // 毎日同じ時刻
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}
